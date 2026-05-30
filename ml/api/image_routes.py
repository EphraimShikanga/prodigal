"""Image verification + face-recognition HTTP endpoints.

Exposes the ``/api/images`` router that drives the :class:`ImageVerifier`
attached to ``app.state.image_verifier`` during the application lifespan. The
verifier and image database are resolved from ``request.app.state`` via small
dependency helpers so the routes stay thin.

Endpoints:

* ``POST /api/images/upload`` -- verify (and persist) an uploaded image.
* ``GET  /api/images/search/{image_id}`` -- describe a stored image.
* ``POST /api/images/persons`` -- enrol a known person from an image.
"""

from __future__ import annotations

import logging

from fastapi import APIRouter, File, Form, HTTPException, Request, UploadFile

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/images", tags=["images"])


def get_verifier(request: Request):
    """Return the :class:`ImageVerifier` stored on ``app.state``.

    Raises:
        HTTPException: 503 if the verifier was not initialised (lifespan
            did not run, e.g. misconfiguration).
    """
    verifier = getattr(request.app.state, "image_verifier", None)
    if verifier is None:
        raise HTTPException(
            status_code=503, detail="Image verification subsystem unavailable."
        )
    return verifier


def get_image_db(request: Request):
    """Return the image database stored on ``app.state`` (or ``None``)."""
    return getattr(request.app.state, "image_db", None)


@router.post("/upload")
async def upload_image(
    request: Request,
    file: UploadFile = File(...),
    person_name: str | None = Form(None),
) -> dict:
    """Verify an uploaded image and persist new images/faces.

    Args:
        request: Incoming request (used to resolve the verifier).
        file: Uploaded image file.
        person_name: Optional name to enrol and link to the strongest face.

    Returns:
        The verifier result dict (faces, duplicates, matches, summary).

    Raises:
        HTTPException: 413 if the payload is too large, 422 if undecodable.
    """
    verifier = get_verifier(request)
    data = await file.read()
    try:
        return verifier.verify(data, persist=True, person_name=person_name)
    except ValueError as exc:
        message = str(exc).lower()
        if "large" in message or "big" in message or "size" in message:
            raise HTTPException(status_code=413, detail=str(exc)) from exc
        raise HTTPException(status_code=422, detail=str(exc)) from exc


@router.get("/search/{image_id}")
async def search_image(request: Request, image_id: str) -> dict:
    """Describe a stored image plus its faces and linked persons.

    Args:
        request: Incoming request (used to resolve the verifier).
        image_id: Id of the stored image to describe.

    Returns:
        The describe-image result dict.

    Raises:
        HTTPException: 404 if no image with ``image_id`` exists.
    """
    verifier = get_verifier(request)
    result = verifier.describe_image(image_id)
    if not result:
        raise HTTPException(status_code=404, detail="Image not found.")
    return result


@router.post("/persons")
async def enroll_person(
    request: Request,
    file: UploadFile = File(...),
    name: str = Form(...),
) -> dict:
    """Enrol a known person from an uploaded image.

    Args:
        request: Incoming request (used to resolve the verifier).
        file: Uploaded image file of the person.
        name: Display name for the enrolled person.

    Returns:
        The verifier result dict for the enrolment upload.

    Raises:
        HTTPException: 413 if the payload is too large, 422 if undecodable.
    """
    verifier = get_verifier(request)
    data = await file.read()
    try:
        return verifier.verify(data, persist=True, person_name=name)
    except ValueError as exc:
        message = str(exc).lower()
        if "large" in message or "big" in message or "size" in message:
            raise HTTPException(status_code=413, detail=str(exc)) from exc
        raise HTTPException(status_code=422, detail=str(exc)) from exc


__all__ = ["router"]
