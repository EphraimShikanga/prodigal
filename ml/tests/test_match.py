"""Enroll / match / delete end-to-end tests using the deterministic backends."""

from __future__ import annotations


def _enroll(client, image: bytes, case_id: str, ob_number: str):
    """Helper: enroll an image via multipart and return the parsed response."""
    return client.post(
        "/api/v1/cases/enroll",
        files={"file": ("img.png", image, "image/png")},
        data={"case_id": case_id, "ob_number": ob_number},
    )


def test_match_same_image(client, image_a) -> None:
    """Enrolling image A and matching the SAME image yields a high-sim C1 match."""
    enroll = _enroll(client, image_a, "C1", "OB/1")
    assert enroll.status_code == 200, enroll.text
    enroll_body = enroll.json()
    assert enroll_body["case_id"] == "C1"
    assert enroll_body["stored"] is True
    assert enroll_body["embedding_dim"] == 512

    resp = client.post(
        "/api/v1/match",
        files={"file": ("a.png", image_a, "image/png")},
    )
    assert resp.status_code == 200
    body = resp.json()
    assert body["probe_faces"] >= 1
    assert body["matches"], "expected a non-empty match list for the same image"
    top = body["matches"][0]
    assert top["case_id"] == "C1"
    assert top["similarity"] > 0.9
    assert body["best_similarity"] > 0.9


def test_match_different_image(client, image_a, image_b) -> None:
    """A different probe image must not produce a high-confidence C1 match."""
    # Ensure C1 (image A) is enrolled.
    _enroll(client, image_a, "C1", "OB/1")

    resp = client.post(
        "/api/v1/match",
        files={"file": ("b.png", image_b, "image/png")},
    )
    assert resp.status_code == 200
    body = resp.json()
    matches = body["matches"]
    # Either no match passed threshold, or the top match is not C1.
    assert not matches or matches[0]["case_id"] != "C1"


def test_delete_case(client, image_a) -> None:
    """Deleting an enrolled case removes its records."""
    _enroll(client, image_a, "C1", "OB/1")

    resp = client.delete("/api/v1/cases/C1")
    assert resp.status_code == 200
    body = resp.json()
    assert body["case_id"] == "C1"
    assert body["deleted"] >= 1
