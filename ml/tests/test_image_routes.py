"""HTTP-level tests for the ``/api/images`` router.

Drives the FastAPI app via ``TestClient`` (lifespan-initialised stub engine +
in-memory image DB + Gemini fallback). Fully offline.
"""

from __future__ import annotations

import io

import numpy as np
from PIL import Image


def _png_bytes(seed: int, size: tuple[int, int] = (128, 128)) -> bytes:
    """Build reproducible PNG bytes from a seeded random RGB array."""
    rng = np.random.default_rng(seed)
    arr = rng.integers(0, 256, size=(size[1], size[0], 3), dtype=np.uint8)
    buf = io.BytesIO()
    Image.fromarray(arr, mode="RGB").save(buf, format="PNG")
    return buf.getvalue()


def test_upload_returns_documented_keys(client) -> None:
    """POST /api/images/upload returns 200 with the documented result keys."""
    files = {"file": ("a.png", _png_bytes(11), "image/png")}
    resp = client.post("/api/images/upload", files=files)
    assert resp.status_code == 200

    body = resp.json()
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
        "gemini_summary",
    ):
        assert key in body
    assert body["success"] is True
    assert body["faces_detected"] >= 1
    assert isinstance(body["gemini_summary"], str)
    assert body["gemini_summary"].strip() != ""


def test_upload_rejects_junk_with_422(client) -> None:
    """Undecodable bytes are rejected with HTTP 422."""
    files = {"file": ("junk.png", b"not-an-image", "image/png")}
    resp = client.post("/api/images/upload", files=files)
    assert resp.status_code == 422


def test_enroll_person_and_search(client) -> None:
    """Enrol a person, then search the stored image by id."""
    files = {"file": ("bob.png", _png_bytes(21), "image/png")}
    enroll = client.post(
        "/api/images/persons", files=files, data={"name": "Bob"}
    )
    assert enroll.status_code == 200
    image_id = enroll.json()["image_id"]
    assert image_id

    search = client.get(f"/api/images/search/{image_id}")
    assert search.status_code == 200
    body = search.json()
    assert body["image_id"] == image_id
    assert body["faces_detected"] >= 1
    # The enrolled person should be linked to this image.
    names = {m["name"] for m in body["matches"]}
    assert "Bob" in names


def test_search_unknown_id_returns_404(client) -> None:
    """A search for a non-existent image id returns HTTP 404."""
    resp = client.get("/api/images/search/00000000-0000-0000-0000-000000000000")
    assert resp.status_code == 404
