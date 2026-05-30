"""Pydantic v2 request/response schemas for the ARGUS-KE ML service."""

from __future__ import annotations

from pydantic import BaseModel


class BBox(BaseModel):
    """Axis-aligned bounding box in pixel coordinates."""

    x1: float
    y1: float
    x2: float
    y2: float


class DetectedFace(BaseModel):
    """A detected face with its bounding box and detection score."""

    bbox: BBox
    det_score: float
    landmarks: list[list[float]] | None = None


class DetectResponse(BaseModel):
    """Response for the face-detection endpoint."""

    count: int
    faces: list[DetectedFace]


class FaceEmbedding(BaseModel):
    """A detected face together with its embedding vector."""

    bbox: BBox
    det_score: float
    embedding: list[float]


class EmbedResponse(BaseModel):
    """Response for the face-embedding endpoint."""

    count: int
    embeddings: list[FaceEmbedding]


class EnrollRequest(BaseModel):
    """JSON body for enrolling a missing-person face."""

    case_id: str
    ob_number: str
    image_b64: str | None = None
    metadata: dict | None = None


class EnrollResponse(BaseModel):
    """Response after enrolling a face."""

    case_id: str
    face_id: str
    embedding_dim: int
    det_score: float
    stored: bool


class MatchItem(BaseModel):
    """A single match result from a vector-store search."""

    case_id: str
    face_id: str
    similarity: float
    ob_number: str | None = None
    metadata: dict | None = None


class MatchResponse(BaseModel):
    """Response for the match endpoints."""

    probe_faces: int
    best_similarity: float | None
    matches: list[MatchItem]


class MatchEmbeddingRequest(BaseModel):
    """JSON body for matching a precomputed embedding."""

    embedding: list[float]
    top_k: int | None = None
    threshold: float | None = None


class HealthResponse(BaseModel):
    """Service health and configuration snapshot."""

    status: str
    version: str
    model_backend: str
    model_loaded: bool
    store_backend: str
    embedding_dim: int
    enrolled: int


class ErrorResponse(BaseModel):
    """Standard error envelope."""

    detail: str
