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

    ml_backend: str = "auto"          # auto|insightface|stub
    store_backend: str = "auto"       # auto|pgvector|memory

    embedding_dim: int = 512
    match_threshold: float = 0.35     # cosine sim; >= means match
    match_top_k: int = 5
    min_det_score: float = 0.5
    max_image_mb: int = 10

    database_url: str | None = None
    cors_origins: list[str] = ["*"]

    model_config = SettingsConfigDict(
        env_file=".env",
        env_prefix="ARGUS_",
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    """Return a cached :class:`Settings` instance."""
    return Settings()
