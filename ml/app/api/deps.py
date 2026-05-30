"""FastAPI dependencies for the ARGUS-KE ML service.

The face engine and vector store are constructed once during application
startup (see :func:`app.main.create_app`) and stored on ``app.state``. These
dependencies expose them to the route handlers via ``Depends``.
"""

from __future__ import annotations

from fastapi import Depends, Request

from app.config import Settings, get_settings
from app.services.face_engine import FaceEngine
from app.services.vector_store import VectorStore


def get_engine(request: Request) -> FaceEngine:
    """Return the face engine stored on ``app.state``."""
    return request.app.state.engine


def get_store(request: Request) -> VectorStore:
    """Return the vector store stored on ``app.state``."""
    return request.app.state.store


def get_settings_dep() -> Settings:
    """Return the cached application settings."""
    return get_settings()


# Convenience aliases for use with ``Depends`` in route signatures.
SettingsDep = Depends(get_settings_dep)
EngineDep = Depends(get_engine)
StoreDep = Depends(get_store)
