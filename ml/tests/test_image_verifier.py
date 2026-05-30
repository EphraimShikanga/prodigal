"""End-to-end tests for :class:`models.image_verifier.ImageVerifier`.

Builds the full verification stack from the deterministic stub engine, an
in-memory image database and a key-less Gemini summary service (template
fallback). Everything runs offline.
"""

from __future__ import annotations

import io

import numpy as np
import pytest
from PIL import Image

from app.config import get_settings
from app.services.face_engine import load_engine
from models.face_detector import FaceDetector
from models.face_recognizer import FaceRecognizer
from models.image_verifier import ImageVerifier
from services.database_service import InMemoryImageDatabase
from services.embedding_service import load_embedding_service
from services.gemini_service import GeminiSummaryService


def _png_bytes(seed: int, size: tuple[int, int] = (128, 128)) -> bytes:
    """Build reproducible PNG bytes from a seeded random RGB array."""
    rng = np.random.default_rng(seed)
    arr = rng.integers(0, 256, size=(size[1], size[0], 3), dtype=np.uint8)
    buf = io.BytesIO()
    Image.fromarray(arr, mode="RGB").save(buf, format="PNG")
    return buf.getvalue()


@pytest.fixture()
def verifier() -> ImageVerifier:
    """A fresh ImageVerifier wired to stub engine + in-memory DB + fallback Gemini."""
    settings = get_settings()
    engine = load_engine(settings)
    db = InMemoryImageDatabase()
    es = load_embedding_service(db, engine, settings)
    es.build_index()
    detector = FaceDetector(engine)
    recognizer = FaceRecognizer(engine, es, db, settings)
    gemini = GeminiSummaryService(api_key=None)  # forces template fallback
    return ImageVerifier(detector, recognizer, es, db, gemini, settings)


def test_first_upload_detects_face_no_duplicate(verifier: ImageVerifier) -> None:
    """First upload of an image detects a face and is not a duplicate."""
    result = verifier.verify(_png_bytes(1), persist=True)

    assert result["success"] is True
    assert result["faces_detected"] >= 1
    assert result["duplicate_image"] is False
    assert result["image_exists"] is False
    assert result["image_id"] is not None
    assert isinstance(result["gemini_summary"], str)
    assert result["gemini_summary"].strip() != ""
    # Expected result keys are present.
    for key in (
        "success",
        "image_id",
        "image_exists",
        "duplicate_image",
        "duplicate_probability",
        "faces_detected",
        "known_faces",
        "unknown_faces",
        "matches",
    ):
        assert key in result


def test_same_bytes_again_is_duplicate(verifier: ImageVerifier) -> None:
    """Re-uploading identical bytes is flagged as an exact duplicate."""
    data = _png_bytes(1)
    verifier.verify(data, persist=True)
    second = verifier.verify(data, persist=True)

    assert second["image_exists"] is True
    assert second["duplicate_image"] is True
    assert second["duplicate_probability"] >= 90.0


def test_enroll_person_then_recognise(verifier: ImageVerifier) -> None:
    """A person enrolled from image A is recognised in a near-identical image."""
    data = _png_bytes(7)
    enroll = verifier.verify(data, persist=True, person_name="Alice")
    assert enroll["success"] is True

    # Verify a visually identical (but freshly built) image of the same content.
    same_content = _png_bytes(7)
    result = verifier.verify(same_content, persist=False, person_name=None)

    names = {f["name"] for f in result["known_faces"]}
    assert "Alice" in names
    assert result["known_faces"]
    assert any(m["person"] == "Alice" for m in result["matches"])


def test_describe_image_returns_details(verifier: ImageVerifier) -> None:
    """describe_image returns stored details; unknown ids return {}."""
    result = verifier.verify(_png_bytes(3), persist=True)
    image_id = result["image_id"]

    described = verifier.describe_image(image_id)
    assert described["image_id"] == image_id
    assert described["faces_detected"] >= 1
    assert isinstance(described["gemini_summary"], str)
    assert described["gemini_summary"].strip() != ""

    assert verifier.describe_image("does-not-exist") == {}
