"""Unified entry point for the ARGUS-KE ML microservice.

This thin module exposes the FastAPI application built in
:mod:`app.main` as a top-level ``app`` symbol so the service can be launched
either as ``uvicorn main:app`` or ``uvicorn app.main:app`` (uvicorn runs with
``cwd=ml`` so the ``api``/``services``/``models``/``utils`` packages import as
top-level packages). Running this file directly starts a development server.
"""

from __future__ import annotations

from app.main import app

__all__ = ["app"]


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app.main:app", host="0.0.0.0", port=8000)
