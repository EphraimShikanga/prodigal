"""Application configuration for the ARGUS-KE ML service.

Settings are loaded from environment variables (prefix ``ARGUS_``) and an
optional ``.env`` file via pydantic-settings.
"""

from __future__ import annotations

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Runtime configuration for the ML microservice."""

    app_name: str = "ARGUS-KE ML Service"
    version: str = "0.1.0"
    api_prefix: str = "/api/v1"

    ml_backend: str = "auto"          # auto|gemini|insightface|stub
    store_backend: str = "auto"       # auto|pgvector|memory

    embedding_dim: int = 512
    match_threshold: float = 0.35     # cosine sim; >= means match
    match_top_k: int = 5
    min_det_score: float = 0.5
    max_image_mb: int = 10

    # --- Gemini backend (ml_backend=gemini) ---
    # Key resolution order: ARGUS_GEMINI_API_KEY, then GEMINI_API_KEY / GOOGLE_API_KEY.
    gemini_api_key: str | None = None
    gemini_vision_model: str = "gemini-2.5-flash"
    gemini_embed_model: str = "gemini-embedding-001"

    database_url: str | None = None
    cors_origins: list[str] = ["*"]

    # --- Face-recognition / image-verification subsystem ---
    recognition_threshold: float = 0.45   # cosine >= -> same known person
    similar_threshold: float = 0.30       # cosine >= -> "similar" image
    duplicate_threshold: float = 0.97     # face-embedding cosine >= -> duplicate
    phash_duplicate_max_hamming: int = 6  # perceptual-hash hamming <= -> duplicate image
    image_store_dir: str = "data/images"
    use_faiss: bool = True

    model_config = SettingsConfigDict(
        env_file=".env",
        env_prefix="ARGUS_",
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    """Return a cached :class:`Settings` instance."""
    return Settings()
