"""Pluggable face-detection / embedding engines for ARGUS-KE.

Two backends are provided:

* :class:`StubFaceEngine` -- zero heavy dependencies, fully deterministic, used
  for local development and the test suite.
* :class:`InsightFaceEngine` -- the real model (``buffalo_l``) loaded lazily so
  the base install never needs ``insightface`` / ``onnxruntime``.

Use :func:`load_engine` to construct the engine selected by
:attr:`Settings.ml_backend`.
"""

from __future__ import annotations

import hashlib
import logging
from abc import ABC, abstractmethod
from dataclasses import dataclass

import numpy as np

from app.services.matching import l2_normalize

logger = logging.getLogger(__name__)


@dataclass
class Face:
    """A detected face and (optionally) its embedding.

    Attributes:
        bbox: ``(x1, y1, x2, y2)`` pixel coordinates.
        det_score: Detector confidence in ``[0, 1]``.
        landmarks: Optional list of ``[x, y]`` keypoints.
        embedding: Optional L2-normalized embedding.
        attributes: Optional structured description of the person (used by the
            Gemini backend, which matches on a text description rather than a
            biometric face vector). Stored in case metadata at enrollment.
    """

    bbox: tuple[float, float, float, float]
    det_score: float
    landmarks: list[list[float]] | None = None
    embedding: np.ndarray | None = None
    attributes: dict | None = None


class FaceEngine(ABC):
    """Abstract face engine: detection + embedding."""

    name: str = "base"
    loaded: bool = False

    @abstractmethod
    def detect(self, image: np.ndarray) -> list[Face]:
        """Detect faces in an RGB ``HxWx3`` image."""
        raise NotImplementedError

    @abstractmethod
    def embed(self, image: np.ndarray) -> list[Face]:
        """Detect faces and attach embeddings."""
        raise NotImplementedError


class StubFaceEngine(FaceEngine):
    """Deterministic, dependency-free face engine.

    ``detect`` always returns exactly one face whose bbox covers the central
    60% of the image. ``embed`` attaches a deterministic L2-normalized 512-d
    embedding derived from a hash of the downscaled grayscale image, so the same
    image always yields the same embedding and different images differ.
    """

    name = "stub"

    def __init__(self, embedding_dim: int = 512) -> None:
        self.embedding_dim = embedding_dim
        self.loaded = True

    def _central_bbox(self, image: np.ndarray) -> tuple[float, float, float, float]:
        h, w = image.shape[0], image.shape[1]
        # Central 60% region -> 20% margin on each side.
        x1 = w * 0.2
        y1 = h * 0.2
        x2 = w * 0.8
        y2 = h * 0.8
        return (float(x1), float(y1), float(x2), float(y2))

    def detect(self, image: np.ndarray) -> list[Face]:
        """Return a single face covering the central 60% of the image."""
        return [Face(bbox=self._central_bbox(image), det_score=0.99, landmarks=None)]

    def _deterministic_embedding(self, image: np.ndarray) -> np.ndarray:
        """Derive a deterministic L2-normalized embedding from image bytes."""
        from PIL import Image

        # Downscale to 32x32 grayscale for a stable, content-sensitive hash.
        pil = Image.fromarray(np.asarray(image, dtype=np.uint8)).convert("L")
        pil = pil.resize((32, 32))
        gray_bytes = np.asarray(pil, dtype=np.uint8).tobytes()

        digest = hashlib.sha256(gray_bytes).digest()
        seed = int.from_bytes(digest[:8], "big", signed=False)
        rng = np.random.default_rng(seed)
        vec = rng.standard_normal(self.embedding_dim)
        return l2_normalize(vec).astype(np.float64)

    def embed(self, image: np.ndarray) -> list[Face]:
        """Detect the single stub face and attach a deterministic embedding."""
        faces = self.detect(image)
        emb = self._deterministic_embedding(image)
        for face in faces:
            face.embedding = emb
        return faces


class InsightFaceEngine(FaceEngine):
    """Real face engine backed by InsightFace ``buffalo_l`` (CPU).

    ``insightface`` is imported lazily inside :meth:`__init__` so the base
    install never requires the heavy ML stack.
    """

    name = "insightface"

    def __init__(self, det_size: tuple[int, int] = (640, 640)) -> None:
        from insightface.app import FaceAnalysis  # lazy import

        self._app = FaceAnalysis(name="buffalo_l")
        self._app.prepare(ctx_id=-1, det_size=det_size)
        self.loaded = True

    @staticmethod
    def _to_bgr(image: np.ndarray) -> np.ndarray:
        """Convert an RGB array to BGR for InsightFace."""
        return np.asarray(image, dtype=np.uint8)[:, :, ::-1]

    @staticmethod
    def _landmarks(face) -> list[list[float]] | None:
        kps = getattr(face, "kps", None)
        if kps is None:
            return None
        return [[float(x), float(y)] for x, y in np.asarray(kps)]

    def detect(self, image: np.ndarray) -> list[Face]:
        """Detect faces using InsightFace."""
        bgr = self._to_bgr(image)
        results = self._app.get(bgr)
        faces: list[Face] = []
        for f in results:
            x1, y1, x2, y2 = (float(v) for v in np.asarray(f.bbox))
            faces.append(
                Face(
                    bbox=(x1, y1, x2, y2),
                    det_score=float(f.det_score),
                    landmarks=self._landmarks(f),
                )
            )
        return faces

    def embed(self, image: np.ndarray) -> list[Face]:
        """Detect faces and attach their L2-normalized embeddings."""
        bgr = self._to_bgr(image)
        results = self._app.get(bgr)
        faces: list[Face] = []
        for f in results:
            x1, y1, x2, y2 = (float(v) for v in np.asarray(f.bbox))
            faces.append(
                Face(
                    bbox=(x1, y1, x2, y2),
                    det_score=float(f.det_score),
                    landmarks=self._landmarks(f),
                    embedding=np.asarray(f.normed_embedding, dtype=np.float64),
                )
            )
        return faces


# Field order used to build the canonical description text that gets embedded.
# Keeping it fixed makes the embedding stable for a given description.
_DESCRIPTION_FIELDS = (
    "apparent_age_range",
    "sex_presentation",
    "skin_tone",
    "hair",
    "facial_features",
    "clothing",
    "accessories",
    "distinguishing_marks",
)

_VISION_PROMPT = (
    "You are a careful forensic image analyst helping reunite missing children "
    "with their families. Analyse the image and return STRICT JSON only, no prose.\n"
    'Schema: {"faces": [{"box_2d": [ymin, xmin, ymax, xmax], "confidence": <0..1>, '
    '"description": {' + ", ".join(f'"{k}": "<short text or empty>"' for k in _DESCRIPTION_FIELDS) + "}}]}\n"
    "box_2d uses integer coordinates normalised to 0-1000 (origin at the top-left). "
    "Include one entry per visible human face, most prominent first. "
    "Describe only what is visible; use an empty string when unsure. "
    'If there are no human faces, return {"faces": []}.'
)


class GeminiFaceEngine(FaceEngine):
    """Face engine backed by the Google Gemini API.

    Gemini does not provide biometric face-identity vectors, so this engine:

    * **detects** faces (and their bounding boxes) with a Gemini vision model, and
    * **embeds** a *structured textual description* of each face produced by the
      vision model, using a Gemini text-embedding model.

    Matching therefore finds people whose *descriptions* are similar, not a
    biometric same-person guarantee. The ``google-genai`` SDK is imported lazily.
    """

    name = "gemini"

    def __init__(
        self,
        api_key: str | None = None,
        vision_model: str = "gemini-2.0-flash",
        embed_model: str = "gemini-embedding-001",
        embedding_dim: int = 512,
        client=None,
    ) -> None:
        self._vision_model = vision_model
        self._embed_model = embed_model
        self._embedding_dim = embedding_dim
        if client is None:
            from google import genai  # lazy import

            if not api_key:
                raise ValueError("Gemini API key is required for GeminiFaceEngine.")
            client = genai.Client(api_key=api_key)
        self._client = client
        self.loaded = True

    @staticmethod
    def _to_png_bytes(image: np.ndarray) -> bytes:
        from io import BytesIO

        from PIL import Image

        buf = BytesIO()
        Image.fromarray(np.asarray(image, dtype=np.uint8)).save(buf, format="PNG")
        return buf.getvalue()

    @staticmethod
    def _parse_json(text: str) -> dict:
        """Parse model JSON output, tolerating ```json fences."""
        import json

        cleaned = text.strip()
        if cleaned.startswith("```"):
            cleaned = cleaned.split("```", 2)[1]
            if cleaned.lstrip().startswith("json"):
                cleaned = cleaned.lstrip()[4:]
        try:
            return json.loads(cleaned)
        except json.JSONDecodeError:
            logger.warning("Gemini returned non-JSON vision output; treating as no faces.")
            return {"faces": []}

    def _analyze(self, image: np.ndarray) -> list[Face]:
        """Run one Gemini vision call and return detected faces with attributes."""
        from google.genai import types  # lazy import

        h, w = image.shape[0], image.shape[1]
        png = self._to_png_bytes(image)
        response = self._client.models.generate_content(
            model=self._vision_model,
            contents=[
                types.Part.from_bytes(data=png, mime_type="image/png"),
                _VISION_PROMPT,
            ],
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                temperature=0.0,
            ),
        )
        parsed = self._parse_json(response.text or "")
        faces: list[Face] = []
        for item in parsed.get("faces", []):
            box = item.get("box_2d") or [0, 0, 1000, 1000]
            ymin, xmin, ymax, xmax = (float(v) for v in box)
            bbox = (
                xmin / 1000.0 * w,
                ymin / 1000.0 * h,
                xmax / 1000.0 * w,
                ymax / 1000.0 * h,
            )
            try:
                score = float(item.get("confidence", 0.9))
            except (TypeError, ValueError):
                score = 0.9
            desc = item.get("description") or {}
            attributes = {k: str(desc.get(k, "")) for k in _DESCRIPTION_FIELDS}
            faces.append(
                Face(bbox=bbox, det_score=score, landmarks=None, attributes=attributes)
            )
        return faces

    def detect(self, image: np.ndarray) -> list[Face]:
        """Detect faces using a Gemini vision model."""
        return self._analyze(image)

    def _embed_text(self, text: str) -> np.ndarray:
        from google.genai import types  # lazy import

        result = self._client.models.embed_content(
            model=self._embed_model,
            contents=text,
            config=types.EmbedContentConfig(
                task_type="SEMANTIC_SIMILARITY",
                output_dimensionality=self._embedding_dim,
            ),
        )
        values = result.embeddings[0].values
        return l2_normalize(np.asarray(values, dtype=np.float64))

    @staticmethod
    def _description_text(attributes: dict | None) -> str:
        """Build a stable canonical description string from attributes."""
        attributes = attributes or {}
        parts = [
            f"{k.replace('_', ' ')}: {attributes.get(k, '')}".strip()
            for k in _DESCRIPTION_FIELDS
        ]
        return "; ".join(p for p in parts if not p.endswith(":"))

    def embed(self, image: np.ndarray) -> list[Face]:
        """Detect faces and attach embeddings of their textual descriptions."""
        faces = self._analyze(image)
        for face in faces:
            text = self._description_text(face.attributes)
            face.embedding = self._embed_text(text)
        return faces


def _resolve_gemini_api_key(settings) -> str | None:
    """Find a Gemini API key from settings or common env vars."""
    import os

    return (
        getattr(settings, "gemini_api_key", None)
        or os.environ.get("GEMINI_API_KEY")
        or os.environ.get("GOOGLE_API_KEY")
    )


def load_engine(settings) -> FaceEngine:
    """Construct the face engine selected by ``settings.ml_backend``.

    * ``stub``        -> deterministic, dependency-free engine.
    * ``gemini``      -> Gemini detect-and-describe engine (requires an API key).
    * ``insightface`` -> the real biometric ArcFace model.
    * ``auto``        -> Gemini if an API key is configured, else InsightFace,
      else the stub. Any load error falls back to the stub (a warning is logged).
    """
    backend = settings.ml_backend

    if backend == "stub":
        return StubFaceEngine(embedding_dim=settings.embedding_dim)

    if backend == "gemini":
        return GeminiFaceEngine(
            api_key=_resolve_gemini_api_key(settings),
            vision_model=settings.gemini_vision_model,
            embed_model=settings.gemini_embed_model,
            embedding_dim=settings.embedding_dim,
        )

    if backend == "insightface":
        return InsightFaceEngine()

    # auto
    api_key = _resolve_gemini_api_key(settings)
    if api_key:
        try:
            return GeminiFaceEngine(
                api_key=api_key,
                vision_model=settings.gemini_vision_model,
                embed_model=settings.gemini_embed_model,
                embedding_dim=settings.embedding_dim,
            )
        except Exception as exc:  # pragma: no cover - depends on optional deps
            logger.warning("Gemini unavailable (%s); trying next backend.", exc)
    try:
        return InsightFaceEngine()
    except Exception as exc:  # pragma: no cover - depends on optional deps
        logger.warning(
            "InsightFace unavailable (%s); falling back to StubFaceEngine.", exc
        )
        return StubFaceEngine(embedding_dim=settings.embedding_dim)
