"""Face detection wrapper around the app face engine.

Thin adapter that turns the engine's :class:`~app.services.face_engine.Face`
detections into lightweight :class:`DetectedFace` records carrying only the
geometry and confidence needed by the verification pipeline. Works offline with
the stub engine and supports multiple faces per image.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass

import numpy as np

logger = logging.getLogger(__name__)


@dataclass
class DetectedFace:
    """A detected face with its location and detector confidence.

    Attributes:
        bbox: ``(x1, y1, x2, y2)`` pixel coordinates.
        confidence: Detector confidence in ``[0, 1]``.
        landmarks: Optional list of keypoints, if the engine provides them.
    """

    bbox: tuple[float, float, float, float]
    confidence: float
    landmarks: list | None = None


class FaceDetector:
    """Detect faces in an image using the configured app face engine."""

    def __init__(self, engine) -> None:
        """Initialise the detector.

        Args:
            engine: App face engine (from ``load_engine``) exposing ``detect``.
        """
        self.engine = engine

    def detect(self, image: np.ndarray) -> list[DetectedFace]:
        """Detect all faces in ``image``.

        Args:
            image: RGB ``HxWx3`` ``uint8`` image.

        Returns:
            A list of :class:`DetectedFace` (possibly empty). Detection errors
            are logged and yield an empty list rather than raising.
        """
        try:
            faces = self.engine.detect(image)
        except Exception as exc:
            logger.warning("Face detection failed: %s", exc)
            return []

        detected: list[DetectedFace] = []
        for face in faces:
            x1, y1, x2, y2 = (float(c) for c in face.bbox)
            detected.append(
                DetectedFace(
                    bbox=(x1, y1, x2, y2),
                    confidence=float(getattr(face, "det_score", 0.0)),
                    landmarks=getattr(face, "landmarks", None),
                )
            )
        return detected


__all__ = ["DetectedFace", "FaceDetector"]
