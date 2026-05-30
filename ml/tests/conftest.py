"""Shared pytest fixtures for the ARGUS-KE ML service tests.

The deterministic ``stub`` face engine and ``memory`` vector store are forced via
environment variables that MUST be set *before* the application (and its cached
settings) are imported.
"""

from __future__ import annotations

import io
import os

# Force deterministic, dependency-free backends BEFORE importing the app.
# Clearing ARGUS_DATABASE_URL keeps the tests hermetic (in-memory image DB), even
# when a developer's .env points at a real Postgres.
os.environ["ARGUS_ML_BACKEND"] = "stub"
os.environ["ARGUS_STORE_BACKEND"] = "memory"
os.environ["ARGUS_DATABASE_URL"] = ""

import numpy as np
import pytest
from fastapi.testclient import TestClient
from PIL import Image

from app.config import get_settings

# Clear any settings cached during import so the env overrides above take effect.
get_settings.cache_clear()

from app.main import create_app  # noqa: E402  (import after env setup)


def make_image_bytes(seed: int, size: tuple[int, int] = (128, 128)) -> bytes:
    """Build reproducible PNG bytes from a seeded random RGB array."""
    rng = np.random.default_rng(seed)
    arr = rng.integers(0, 256, size=(size[1], size[0], 3), dtype=np.uint8)
    img = Image.fromarray(arr, mode="RGB")
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()


@pytest.fixture(scope="session")
def client() -> TestClient:
    """A FastAPI ``TestClient`` with the lifespan (engine + store) initialised."""
    app = create_app()
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture()
def image_a() -> bytes:
    """Deterministic synthetic image A."""
    return make_image_bytes(seed=1)


@pytest.fixture()
def image_b() -> bytes:
    """Deterministic synthetic image B (distinct from A)."""
    return make_image_bytes(seed=999)
