"""Face embedding extraction and identification against the stored corpus.

Uses the app face engine to extract L2-normalized embeddings, then searches the
:class:`~services.embedding_service.EmbeddingService` vector index to classify a
query face as a ``known`` person, a ``similar`` image, or ``unknown`` via the
thresholds in :mod:`utils.similarity`. Fully offline with the stub engine and
the in-memory database.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass

import numpy as np

from services.database_service import ImageDatabase
from services.embedding_service import EmbeddingService
from utils.similarity import classify

logger = logging.getLogger(__name__)


@dataclass
class FaceEmbeddingResult:
    """A detected face together with its extracted embedding.

    Attributes:
        bbox: ``(x1, y1, x2, y2)`` pixel coordinates.
        confidence: Detector confidence in ``[0, 1]``.
        embedding: 512-d L2-normalized embedding as a list of floats.
    """

    bbox: tuple
    confidence: float
    embedding: list[float]


@dataclass
class Identification:
    """The outcome of identifying a single query embedding.

    Attributes:
        label: ``"known"``, ``"similar"`` or ``"unknown"``.
        person_id: Linked person id of the best match, if any.
        person_name: Resolved person name of the best match, if any.
        similarity: Best cosine similarity found (``0.0`` when no corpus).
        embedding_id: Id of the best-matching stored embedding, if any.
    """

    label: str
    person_id: str | None
    person_name: str | None
    similarity: float
    embedding_id: str | None


class FaceRecognizer:
    """Extract embeddings and identify faces against the stored corpus."""

    def __init__(
        self,
        engine,
        embedding_service: EmbeddingService,
        db: ImageDatabase,
        settings,
    ) -> None:
        """Initialise the recognizer.

        Args:
            engine: App face engine (from ``load_engine``) exposing ``embed``.
            embedding_service: Service providing the searchable vector index.
            db: Image/embedding database (for resolving person names).
            settings: Settings object exposing the recognition thresholds.
        """
        self.engine = engine
        self.embedding_service = embedding_service
        self.db = db
        self.settings = settings

    def extract(self, image: np.ndarray) -> list[FaceEmbeddingResult]:
        """Detect and embed every face in ``image``.

        Args:
            image: RGB ``HxWx3`` ``uint8`` image.

        Returns:
            A :class:`FaceEmbeddingResult` per face that has an embedding
            (possibly empty). Extraction errors are logged, not raised.
        """
        faces = self.embedding_service.embed_faces(image)
        results: list[FaceEmbeddingResult] = []
        for face in faces:
            embedding = [float(v) for v in np.asarray(face.embedding).reshape(-1)]
            x1, y1, x2, y2 = (float(c) for c in face.bbox)
            results.append(
                FaceEmbeddingResult(
                    bbox=(x1, y1, x2, y2),
                    confidence=float(getattr(face, "det_score", 0.0)),
                    embedding=embedding,
                )
            )
        return results

    def identify(self, embedding: list[float]) -> Identification:
        """Identify a query embedding against the stored corpus.

        Searches the embedding service for the most similar stored face, then
        classifies the result using :func:`utils.similarity.classify` (taking
        into account whether the best match is linked to a person) and resolves
        the person's name via the database.

        Args:
            embedding: Query embedding as a list of floats.

        Returns:
            An :class:`Identification` describing the best match.
        """
        hits = self.embedding_service.search(embedding, k=1)
        if not hits:
            return Identification(
                label="unknown",
                person_id=None,
                person_name=None,
                similarity=0.0,
                embedding_id=None,
            )

        record, sim = hits[0]
        sim = float(sim)
        person_id = record.person_id
        has_person = person_id is not None

        person_name: str | None = None
        if has_person:
            try:
                person = self.db.get_person(person_id)
                if person is not None:
                    person_name = person.name
            except Exception as exc:
                logger.warning("Could not resolve person %s: %s", person_id, exc)

        label = classify(sim, has_person and person_name is not None, self.settings)

        return Identification(
            label=label,
            person_id=person_id if label == "known" else person_id,
            person_name=person_name,
            similarity=sim,
            embedding_id=record.id,
        )


__all__ = ["FaceEmbeddingResult", "Identification", "FaceRecognizer"]
