"""Health and readiness endpoints for the ARGUS-KE ML service."""

from __future__ import annotations

from fastapi import APIRouter, Depends

from app.api.deps import get_engine, get_settings_dep, get_store
from app.config import Settings
from app.schemas import HealthResponse
from app.services.face_engine import FaceEngine
from app.services.vector_store import VectorStore

router = APIRouter(tags=["health"])


def _health(
    settings: Settings,
    engine: FaceEngine,
    store: VectorStore,
) -> HealthResponse:
    """Build a :class:`HealthResponse` snapshot of the running service."""
    return HealthResponse(
        status="ok",
        version=settings.version,
        model_backend=engine.name,
        model_loaded=engine.loaded,
        store_backend=store.name,
        embedding_dim=settings.embedding_dim,
        enrolled=store.count(),
    )


@router.get("/", response_model=HealthResponse)
def root(
    settings: Settings = Depends(get_settings_dep),
    engine: FaceEngine = Depends(get_engine),
    store: VectorStore = Depends(get_store),
) -> HealthResponse:
    """Service root: report health and configuration."""
    return _health(settings, engine, store)


@router.get("/health", response_model=HealthResponse)
def health(
    settings: Settings = Depends(get_settings_dep),
    engine: FaceEngine = Depends(get_engine),
    store: VectorStore = Depends(get_store),
) -> HealthResponse:
    """Report service health and configuration."""
    return _health(settings, engine, store)
