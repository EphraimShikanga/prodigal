"""Health endpoint tests."""

from __future__ import annotations


def test_health(client) -> None:
    """`/health` returns 200 with the stub engine and memory store reported."""
    resp = client.get("/health")
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "ok"
    assert body["model_backend"] == "stub"
    assert body["store_backend"] == "memory"
    assert body["model_loaded"] is True
    assert body["embedding_dim"] == 512
    assert "enrolled" in body


def test_root(client) -> None:
    """Root `/` mirrors the health snapshot."""
    resp = client.get("/")
    assert resp.status_code == 200
    body = resp.json()
    assert body["model_backend"] == "stub"
    assert body["store_backend"] == "memory"
