"""ARGUS-KE ML microservice application factory.

Builds the FastAPI app, wiring the pluggable face engine and vector store onto
``app.state`` during the lifespan, configuring CORS, registering the four API
routers, and installing a uniform error envelope.
"""

from __future__ import annotations

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.api.routes_cases import router as cases_router
from app.api.routes_faces import router as faces_router
from app.api.routes_health import router as health_router
from app.api.routes_match import router as match_router
from app.config import get_settings
from app.schemas import ErrorResponse
from app.services.face_engine import load_engine
from app.services.vector_store import load_store

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Load the face engine and vector store onto ``app.state``."""
    settings = get_settings()
    app.state.settings = settings
    app.state.engine = load_engine(settings)
    app.state.store = load_store(settings)
    logger.info(
        "ARGUS-KE ready: engine=%s store=%s",
        app.state.engine.name,
        app.state.store.name,
    )
    yield


def create_app() -> FastAPI:
    """Construct and configure the FastAPI application."""
    settings = get_settings()

    app = FastAPI(
        title=settings.app_name,
        version=settings.version,
        lifespan=lifespan,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @app.exception_handler(Exception)
    async def _unhandled_exception_handler(request: Request, exc: Exception):
        """Return all unhandled errors as a uniform :class:`ErrorResponse`."""
        logger.exception("Unhandled error on %s %s", request.method, request.url.path)
        return JSONResponse(
            status_code=500,
            content=ErrorResponse(detail="Internal server error").model_dump(),
        )

    app.include_router(health_router)
    app.include_router(faces_router)
    app.include_router(cases_router)
    app.include_router(match_router)

    return app


app = create_app()
