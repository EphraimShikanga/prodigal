"""Face detection and embedding endpoints for the ARGUS-KE ML service."""

from __future__ import annotations

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile

from app.api.deps import get_engine, get_settings
from app.config import Settings
from app.schemas import (
    BBox,
    DetectedFace,
    DetectResponse,
    EmbedResponse,
    FaceEmbedding,
)
from app.services.face_engine import Face, FaceEngine
from app.services.imaging import decode_image

router = APIRouter(prefix=get_settings().api_prefix + "/faces", tags=["faces"])


async def _read_image(file: UploadFile, settings: Settings) -> bytes:
    """Read an uploaded image, enforcing the configured max size."""
    data = await file.read()
    max_bytes = settings.max_image_mb * 1024 * 1024
    if len(data) > max_bytes:
        raise HTTPException(
            status_code=413,
            detail=f"Image exceeds maximum size of {settings.max_image_mb} MB.",
        )
    return data


def _bbox(face: Face) -> BBox:
    """Convert a :class:`Face` bbox tuple to a :class:`BBox` schema."""
    x1, y1, x2, y2 = face.bbox
    return BBox(x1=x1, y1=y1, x2=x2, y2=y2)


@router.post("/detect", response_model=DetectResponse)
async def detect_faces(
    file: UploadFile = File(...),
    engine: FaceEngine = Depends(get_engine),
    settings: Settings = Depends(get_settings),
) -> DetectResponse:
    """Detect faces in an uploaded image (RGB), filtered by ``min_det_score``."""
    data = await _read_image(file, settings)
    try:
        image = decode_image(data)
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc

    faces = engine.detect(image)
    kept = [f for f in faces if f.det_score >= settings.min_det_score]
    detected = [
        DetectedFace(bbox=_bbox(f), det_score=f.det_score, landmarks=f.landmarks)
        for f in kept
    ]
    return DetectResponse(count=len(detected), faces=detected)


@router.post("/embed", response_model=EmbedResponse)
async def embed_faces(
    file: UploadFile = File(...),
    engine: FaceEngine = Depends(get_engine),
    settings: Settings = Depends(get_settings),
) -> EmbedResponse:
    """Detect faces and return their embeddings (all faces included)."""
    data = await _read_image(file, settings)
    try:
        image = decode_image(data)
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc

    faces = engine.embed(image)
    embeddings = [
        FaceEmbedding(
            bbox=_bbox(f),
            det_score=f.det_score,
            embedding=[float(v) for v in f.embedding]
            if f.embedding is not None
            else [],
        )
        for f in faces
    ]
    return EmbedResponse(count=len(embeddings), embeddings=embeddings)
