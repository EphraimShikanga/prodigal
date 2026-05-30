"""Face detection and embedding endpoint tests."""

from __future__ import annotations


def test_detect(client, image_a) -> None:
    """`/faces/detect` reports at least one face for the stub engine."""
    resp = client.post(
        "/api/v1/faces/detect",
        files={"file": ("a.png", image_a, "image/png")},
    )
    assert resp.status_code == 200
    body = resp.json()
    assert body["count"] >= 1
    assert len(body["faces"]) == body["count"]
    face = body["faces"][0]
    assert face["det_score"] >= 0.5
    assert {"x1", "y1", "x2", "y2"} <= set(face["bbox"].keys())


def test_embed(client, image_a) -> None:
    """`/faces/embed` returns 512-dimensional embeddings."""
    resp = client.post(
        "/api/v1/faces/embed",
        files={"file": ("a.png", image_a, "image/png")},
    )
    assert resp.status_code == 200
    body = resp.json()
    assert body["count"] >= 1
    embedding = body["embeddings"][0]["embedding"]
    assert len(embedding) == 512
