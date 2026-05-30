"""Match endpoints: the live "Match Found" engine for ARGUS-KE."""

from __future__ import annotations

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile

from app.api.deps import get_engine, get_settings, get_store
from app.config import Settings
from app.schemas import MatchEmbeddingRequest, MatchItem, MatchResponse
from app.services.face_engine import Face, FaceEngine
from app.services.imaging import decode_image
from app.services.vector_store import FaceRecord, VectorStore

router = APIRouter(prefix=get_settings().api_prefix, tags=["match"])


def _to_matches(results: list[tuple[FaceRecord, float]]) -> list[MatchItem]:
    """Convert store search results to :class:`MatchItem` list."""
    return [
        MatchItem(
            case_id=record.case_id,
            face_id=record.face_id,
            similarity=float(similarity),
            ob_number=record.ob_number,
            metadata=record.metadata,
        )
        for record, similarity in results
    ]


@router.post("/match", response_model=MatchResponse)
async def match(
    file: UploadFile = File(...),
    top_k: int | None = Form(default=None),
    threshold: float | None = Form(default=None),
    engine: FaceEngine = Depends(get_engine),
    store: VectorStore = Depends(get_store),
    settings: Settings = Depends(get_settings),
) -> MatchResponse:
    """Match a probe image against enrolled cases.

    Detects + embeds all probe faces and runs a vector-store search for the
    best-scoring face.
    """
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

    k = top_k if top_k is not None else settings.match_top_k
    thr = threshold if threshold is not None else settings.match_threshold

    faces: list[Face] = engine.embed(image)
    probe_faces = len(faces)

    candidates = [f for f in faces if f.embedding is not None]
    if not candidates:
        return MatchResponse(probe_faces=probe_faces, best_similarity=None, matches=[])

    best = max(candidates, key=lambda f: f.det_score)
    results = store.search([float(v) for v in best.embedding], top_k=k, threshold=thr)
    matches = _to_matches(results)
    best_similarity = matches[0].similarity if matches else None

    return MatchResponse(
        probe_faces=probe_faces,
        best_similarity=best_similarity,
        matches=matches,
    )


@router.post("/match/embedding", response_model=MatchResponse)
async def match_embedding(
    payload: MatchEmbeddingRequest,
    store: VectorStore = Depends(get_store),
    settings: Settings = Depends(get_settings),
) -> MatchResponse:
    """Match a precomputed embedding against enrolled cases."""
    k = payload.top_k if payload.top_k is not None else settings.match_top_k
    thr = payload.threshold if payload.threshold is not None else settings.match_threshold

    results = store.search(payload.embedding, top_k=k, threshold=thr)
    matches = _to_matches(results)
    best_similarity = matches[0].similarity if matches else None

    return MatchResponse(
        probe_faces=1,
        best_similarity=best_similarity,
        matches=matches,
    )
