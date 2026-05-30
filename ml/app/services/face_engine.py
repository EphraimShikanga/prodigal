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
        embedding: Optional L2-normalized 512-d embedding.
    """

    bbox: tuple[float, float, float, float]
    det_score: float
    landmarks: list[list[float]] | None = None
    embedding: np.ndarray | None = None


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


def load_engine(settings) -> FaceEngine:
    """Construct the face engine selected by ``settings.ml_backend``.

    For ``"auto"``, InsightFace is attempted first and the stub is used on any
    import/load error (a warning is logged).
    """
    backend = settings.ml_backend

    if backend == "stub":
        return StubFaceEngine(embedding_dim=settings.embedding_dim)

    if backend == "insightface":
        return InsightFaceEngine()

    # auto
    try:
        return InsightFaceEngine()
    except Exception as exc:  # pragma: no cover - depends on optional deps
        logger.warning(
            "InsightFace unavailable (%s); falling back to StubFaceEngine.", exc
        )
        return StubFaceEngine(embedding_dim=settings.embedding_dim)
