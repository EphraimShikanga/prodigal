"""End-to-end image verification orchestration.

The :class:`ImageVerifier` ties together detection, recognition, embedding
persistence/indexing, duplicate detection (exact SHA-256 + perceptual dHash) and
a Gemini-backed natural-language summary into a single ``verify`` call returning
a structured result dict. It also exposes ``describe_image`` for the search
endpoint. Everything works offline with the stub engine, the in-memory database
and the Gemini fallback summary.
"""

from __future__ import annotations

import logging

from models.face_detector import FaceDetector
from models.face_recognizer import FaceRecognizer
from services.database_service import ImageDatabase
from services.embedding_service import EmbeddingService
from services.gemini_service import GeminiSummaryService
from utils.image_processing import (
    decode_image,
    hamming_distance,
    perceptual_hash,
    sha256_hex,
    validate_image,
)
from utils.similarity import to_percent

logger = logging.getLogger(__name__)

# Maximum upload size (MB) when ``settings`` does not specify one.
_DEFAULT_MAX_MB = 25


class ImageVerifier:
    """Verify an uploaded image against the stored image/person corpus."""

    def __init__(
        self,
        detector: FaceDetector,
        recognizer: FaceRecognizer,
        embedding_service: EmbeddingService,
        db: ImageDatabase,
        gemini: GeminiSummaryService,
        settings,
    ) -> None:
        """Initialise the verifier.

        Args:
            detector: Face detector wrapping the app engine.
            recognizer: Face recognizer for embedding extraction + identify.
            embedding_service: Service that persists/indexes embeddings.
            db: Image/embedding/person database backend.
            gemini: Summary service (always returns a string).
            settings: Settings object with thresholds and limits.
        """
        self.detector = detector
        self.recognizer = recognizer
        self.embedding_service = embedding_service
        self.db = db
        self.gemini = gemini
        self.settings = settings

    # -- helpers ---------------------------------------------------------

    def _max_mb(self) -> int:
        """Return the configured maximum upload size in MB."""
        return int(getattr(self.settings, "max_upload_mb", _DEFAULT_MAX_MB) or _DEFAULT_MAX_MB)

    def _phash_duplicate(self, phash: str) -> float:
        """Return the best phash similarity (0..1) against stored phashes.

        Compares ``phash`` to every stored image phash and returns the highest
        bit-similarity for any pair within the configured Hamming threshold;
        ``0.0`` if none qualify.
        """
        max_hamming = int(getattr(self.settings, "phash_duplicate_max_hamming", 6))
        best = 0.0
        try:
            pairs = self.db.list_image_phashes()
        except Exception as exc:
            logger.warning("Could not list stored phashes: %s", exc)
            return 0.0
        for _image_id, existing in pairs:
            if not existing:
                continue
            try:
                dist = hamming_distance(phash, existing)
            except (ValueError, TypeError):
                continue
            if dist <= max_hamming:
                similarity = 1.0 - (dist / 64.0)
                best = max(best, similarity)
        return best

    # -- public API ------------------------------------------------------

    def verify(
        self,
        data: bytes,
        persist: bool = True,
        person_name: str | None = None,
    ) -> dict:
        """Verify an uploaded image and (optionally) persist it.

        Pipeline: validate -> decode -> hash (SHA-256 + dHash) -> exact &
        near-duplicate detection -> face detection + embedding extraction ->
        per-face identification -> optional persistence (image + embeddings,
        plus person enrollment when ``person_name`` is given) -> Gemini summary.

        Args:
            data: Raw encoded image bytes.
            persist: Whether to store new (non-exact-duplicate) images/faces.
            person_name: When set, enrol this name and link the strongest face.

        Returns:
            A result dict with keys: ``success``, ``image_id``, ``image_exists``,
            ``duplicate_image``, ``duplicate_probability``, ``faces_detected``,
            ``known_faces``, ``unknown_faces``, ``matches`` and
            ``gemini_summary``.

        Raises:
            ValueError: If the payload is empty, too large or undecodable.
        """
        validate_image(data, self._max_mb())
        image = decode_image(data)
        sha = sha256_hex(data)
        phash = perceptual_hash(image)

        # -- duplicate detection -----------------------------------------
        exact = self.db.find_image_by_hash(sha)
        phash_similarity = self._phash_duplicate(phash)
        phash_dup = phash_similarity > 0.0
        image_exists = bool(exact) or phash_dup

        # -- face extraction + identification ----------------------------
        face_results = self.recognizer.extract(image)
        faces_detected = len(face_results)

        duplicate_threshold = float(getattr(self.settings, "duplicate_threshold", 0.97))
        best_face_sim = 0.0
        known_faces: list[dict] = []
        matches: list[dict] = []
        unknown_faces = 0
        identifications = []

        for face in face_results:
            ident = self.recognizer.identify(face.embedding)
            identifications.append((face, ident))
            best_face_sim = max(best_face_sim, float(ident.similarity))
            if ident.label == "known" and ident.person_name:
                pct = to_percent(ident.similarity)
                known_faces.append({"name": ident.person_name, "confidence": pct})
                matches.append({"person": ident.person_name, "similarity": pct})
            else:
                unknown_faces += 1

        best_face_sim_pct = to_percent(best_face_sim)

        # -- duplicate decision ------------------------------------------
        duplicate_image = (
            bool(exact)
            or best_face_sim >= duplicate_threshold
        )
        duplicate_probability = max(
            round(phash_similarity * 100, 1),
            best_face_sim_pct,
            100.0 if exact else 0.0,
        )

        # -- persistence -------------------------------------------------
        image_id: str | None = exact.id if exact else None
        if persist and not exact:
            try:
                record = self.db.add_image(
                    image_path=None, image_hash=sha, phash=phash
                )
                image_id = record.id

                # Enrol a person and find the strongest face to link.
                person_id: str | None = None
                strongest_idx = -1
                if person_name:
                    person = self.db.add_person(person_name, image_id)
                    person_id = person.id
                    if identifications:
                        strongest_idx = max(
                            range(len(identifications)),
                            key=lambda i: identifications[i][0].confidence,
                        )

                for idx, (face, _ident) in enumerate(identifications):
                    x1, y1, x2, y2 = (float(c) for c in face.bbox)
                    bbox = {"x1": x1, "y1": y1, "x2": x2, "y2": y2}
                    link_person = person_id if idx == strongest_idx else None
                    self.embedding_service.add_embedding(
                        image_id=image_id,
                        embedding=face.embedding,
                        person_id=link_person,
                        bbox=bbox,
                        det_score=face.confidence,
                    )
            except Exception as exc:
                logger.warning("Failed to persist image/embeddings: %s", exc)

        # -- assemble result ---------------------------------------------
        results: dict = {
            "success": True,
            "image_id": image_id,
            "image_exists": bool(exact) or phash_dup,
            "duplicate_image": bool(duplicate_image),
            "duplicate_probability": float(duplicate_probability),
            "faces_detected": int(faces_detected),
            "known_faces": known_faces,
            "unknown_faces": int(unknown_faces),
            "matches": matches,
        }

        results["gemini_summary"] = self.gemini.summarize(results)
        return results

    def describe_image(self, image_id: str) -> dict:
        """Describe a stored image plus its faces and linked persons.

        Args:
            image_id: The image id to look up.

        Returns:
            A dict with the image details, its face embeddings, matching person
            records and a Gemini summary. Returns ``{}`` when no such image.
        """
        image = self.db.get_image(image_id)
        if image is None:
            return {}

        try:
            embeddings = self.db.embeddings_for_image(image_id)
        except Exception as exc:
            logger.warning("Could not load embeddings for %s: %s", image_id, exc)
            embeddings = []

        faces: list[dict] = []
        matches: list[dict] = []
        seen_persons: set[str] = set()
        for emb in embeddings:
            faces.append(
                {
                    "embedding_id": emb.id,
                    "bbox": emb.bbox,
                    "det_score": emb.det_score,
                    "person_id": emb.person_id,
                }
            )
            if emb.person_id and emb.person_id not in seen_persons:
                seen_persons.add(emb.person_id)
                try:
                    person = self.db.get_person(emb.person_id)
                except Exception as exc:
                    logger.warning("Could not resolve person %s: %s", emb.person_id, exc)
                    person = None
                if person is not None:
                    matches.append({"person_id": person.id, "name": person.name})

        known_faces = [{"name": m["name"], "confidence": 100.0} for m in matches]
        summary_input = {
            "faces_detected": len(faces),
            "known_faces": known_faces,
            "unknown_faces": max(0, len(faces) - len(known_faces)),
            "duplicate_image": False,
            "duplicate_probability": 0.0,
            "matches": [{"person": m["name"], "similarity": 100.0} for m in matches],
        }

        result: dict = {
            "success": True,
            "image_id": image.id,
            "image_path": image.image_path,
            "image_hash": image.image_hash,
            "phash": image.phash,
            "uploaded_at": image.uploaded_at,
            "faces_detected": len(faces),
            "faces": faces,
            "matches": matches,
        }
        result["gemini_summary"] = self.gemini.summarize(summary_input)
        return result


__all__ = ["ImageVerifier"]
