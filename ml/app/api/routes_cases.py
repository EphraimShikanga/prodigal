"""Case enrollment / deletion endpoints for the ARGUS-KE ML service."""

from __future__ import annotations

import json
import uuid

from fastapi import (
    APIRouter,
    Depends,
    File,
    Form,
    HTTPException,
    Request,
    UploadFile,
)

from app.api.deps import get_engine, get_settings, get_store
from app.config import Settings
from app.schemas import EnrollRequest, EnrollResponse
from app.services.face_engine import Face, FaceEngine
from app.services.imaging import decode_b64_image, decode_image
from app.services.vector_store import FaceRecord, VectorStore

router = APIRouter(prefix=get_settings().api_prefix + "/cases", tags=["cases"])


def _best_face(faces: list[Face]) -> Face:
    """Return the highest-scoring face with an embedding, or raise 422."""
    candidates = [f for f in faces if f.embedding is not None]
    if not candidates:
        raise HTTPException(
            status_code=422, detail="No face detected in the provided image."
        )
    return max(candidates, key=lambda f: f.det_score)


def _parse_metadata(metadata: str | None) -> dict | None:
    """Parse an optional JSON metadata string."""
    if metadata is None or metadata == "":
        return None
    try:
        parsed = json.loads(metadata)
    except json.JSONDecodeError as exc:
        raise HTTPException(
            status_code=422, detail=f"Invalid metadata JSON: {exc}"
        ) from exc
    if not isinstance(parsed, dict):
        raise HTTPException(status_code=422, detail="metadata must be a JSON object.")
    return parsed


@router.post("/enroll", response_model=EnrollResponse)
async def enroll_case(
    request: Request,
    file: UploadFile | None = File(default=None),
    case_id: str | None = Form(default=None),
    ob_number: str | None = Form(default=None),
    metadata: str | None = Form(default=None),
    engine: FaceEngine = Depends(get_engine),
    store: VectorStore = Depends(get_store),
    settings: Settings = Depends(get_settings),
) -> EnrollResponse:
    """Enroll a verified missing-person face from multipart or JSON input.

    Accepts EITHER a multipart upload (``file`` + ``case_id`` / ``ob_number`` /
    optional ``metadata`` JSON string) OR an ``application/json`` body matching
    :class:`EnrollRequest` with an ``image_b64`` payload.
    """
    content_type = request.headers.get("content-type", "")

    if "application/json" in content_type:
        body = await request.json()
        try:
            payload = EnrollRequest(**body)
        except Exception as exc:  # pydantic validation error
            raise HTTPException(status_code=422, detail=str(exc)) from exc
        if not payload.image_b64:
            raise HTTPException(
                status_code=422, detail="image_b64 is required for JSON enrollment."
            )
        try:
            image = decode_b64_image(payload.image_b64)
        except ValueError as exc:
            raise HTTPException(status_code=422, detail=str(exc)) from exc
        case_id_val = payload.case_id
        ob_number_val = payload.ob_number
        metadata_val = payload.metadata
    else:
        if file is None or case_id is None or ob_number is None:
            raise HTTPException(
                status_code=422,
                detail="Multipart enrollment requires file, case_id and ob_number.",
            )
        data = await file.read()
        max_bytes = settings.max_image_mb * 1024 * 1024
        if len(data) > max_bytes:
            raise HTTPException(
                status_code=413,
                detail=f"Image exceeds maximum size of {settings.max_image_mb} MB.",
            )
        try:
            image = decode_image(data)
        except ValueError as exc:
            raise HTTPException(status_code=422, detail=str(exc)) from exc
        case_id_val = case_id
        ob_number_val = ob_number
        metadata_val = _parse_metadata(metadata)

    faces = engine.embed(image)
    face = _best_face(faces)

    face_id = str(uuid.uuid4())
    record = FaceRecord(
        face_id=face_id,
        case_id=case_id_val,
        ob_number=ob_number_val,
        embedding=[float(v) for v in face.embedding],
        metadata=metadata_val,
    )
    store.enroll(record)

    return EnrollResponse(
        case_id=case_id_val,
        face_id=face_id,
        embedding_dim=len(record.embedding),
        det_score=face.det_score,
        stored=True,
    )


@router.delete("/{case_id}")
async def delete_case(
    case_id: str,
    store: VectorStore = Depends(get_store),
) -> dict:
    """Delete all enrolled faces for ``case_id``."""
    deleted = store.delete_case(case_id)
    return {"case_id": case_id, "deleted": deleted}
