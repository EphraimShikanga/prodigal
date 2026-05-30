"""Pluggable vector stores for enrolled face embeddings.

Two backends are provided:

* :class:`InMemoryStore` -- in-process list with cosine-similarity search; no
  external dependencies, used for development and tests.
* :class:`PgVectorStore` -- Postgres + ``pgvector`` via ``psycopg`` (imported
  lazily) for production / Supabase.

Use :func:`load_store` to construct the store selected by
:attr:`Settings.store_backend`.
"""

from __future__ import annotations

import logging
from abc import ABC, abstractmethod
from dataclasses import dataclass

import numpy as np

from app.services.matching import cosine_similarity

logger = logging.getLogger(__name__)


@dataclass
class FaceRecord:
    """A stored face embedding with case metadata.

    Attributes:
        face_id: Unique id (uuid4 string).
        case_id: Missing-person case identifier.
        ob_number: Police OB (Occurrence Book) number, if known.
        embedding: 512-d embedding as a list of floats.
        metadata: Arbitrary JSON-serializable metadata.
    """

    face_id: str
    case_id: str
    ob_number: str | None
    embedding: list[float]
    metadata: dict | None = None


class VectorStore(ABC):
    """Abstract store for enrolling and searching face embeddings."""

    name: str = "base"

    @abstractmethod
    def enroll(self, record: FaceRecord) -> None:
        """Persist a single face record."""
        raise NotImplementedError

    @abstractmethod
    def search(
        self, embedding: list[float], top_k: int, threshold: float
    ) -> list[tuple[FaceRecord, float]]:
        """Return up to ``top_k`` records with cosine sim ``>= threshold``.

        Results are sorted in descending order of similarity.
        """
        raise NotImplementedError

    @abstractmethod
    def delete_case(self, case_id: str) -> int:
        """Delete all records for ``case_id``; return the number removed."""
        raise NotImplementedError

    @abstractmethod
    def count(self) -> int:
        """Return the total number of enrolled records."""
        raise NotImplementedError


class InMemoryStore(VectorStore):
    """In-process vector store backed by a Python list."""

    name = "memory"

    def __init__(self) -> None:
        self._records: list[FaceRecord] = []

    def enroll(self, record: FaceRecord) -> None:
        self._records.append(record)

    def search(
        self, embedding: list[float], top_k: int, threshold: float
    ) -> list[tuple[FaceRecord, float]]:
        probe = np.asarray(embedding, dtype=np.float64)
        scored: list[tuple[FaceRecord, float]] = []
        for record in self._records:
            sim = cosine_similarity(probe, np.asarray(record.embedding, dtype=np.float64))
            if sim >= threshold:
                scored.append((record, sim))
        scored.sort(key=lambda pair: pair[1], reverse=True)
        return scored[:top_k]

    def delete_case(self, case_id: str) -> int:
        before = len(self._records)
        self._records = [r for r in self._records if r.case_id != case_id]
        return before - len(self._records)

    def count(self) -> int:
        return len(self._records)


class PgVectorStore(VectorStore):
    """Postgres + ``pgvector`` vector store.

    ``psycopg`` and ``pgvector`` are imported lazily inside ``__init__`` so the
    base install never requires them.
    """

    name = "pgvector"

    def __init__(self, database_url: str) -> None:
        import psycopg  # lazy import
        from pgvector.psycopg import register_vector  # lazy import

        self._database_url = database_url
        self._conn = psycopg.connect(database_url, autocommit=True)
        register_vector(self._conn)

    def enroll(self, record: FaceRecord) -> None:
        with self._conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO argus_faces
                    (face_id, case_id, ob_number, embedding, metadata)
                VALUES (%s, %s, %s, %s, %s)
                """,
                (
                    record.face_id,
                    record.case_id,
                    record.ob_number,
                    np.asarray(record.embedding, dtype=np.float32),
                    self._to_jsonb(record.metadata),
                ),
            )

    def search(
        self, embedding: list[float], top_k: int, threshold: float
    ) -> list[tuple[FaceRecord, float]]:
        probe = np.asarray(embedding, dtype=np.float32)
        with self._conn.cursor() as cur:
            cur.execute(
                """
                SELECT face_id, case_id, ob_number, embedding, metadata,
                       embedding <=> %s AS distance
                FROM argus_faces
                ORDER BY embedding <=> %s
                LIMIT %s
                """,
                (probe, probe, top_k),
            )
            rows = cur.fetchall()

        results: list[tuple[FaceRecord, float]] = []
        for face_id, case_id, ob_number, emb, metadata, distance in rows:
            similarity = 1.0 - float(distance)
            if similarity < threshold:
                continue
            record = FaceRecord(
                face_id=str(face_id),
                case_id=case_id,
                ob_number=ob_number,
                embedding=list(np.asarray(emb, dtype=np.float64)),
                metadata=metadata,
            )
            results.append((record, similarity))
        # Already ordered ascending by distance == descending by similarity.
        return results

    def delete_case(self, case_id: str) -> int:
        with self._conn.cursor() as cur:
            cur.execute("DELETE FROM argus_faces WHERE case_id = %s", (case_id,))
            return cur.rowcount

    def count(self) -> int:
        with self._conn.cursor() as cur:
            cur.execute("SELECT COUNT(*) FROM argus_faces")
            row = cur.fetchone()
            return int(row[0]) if row else 0

    @staticmethod
    def _to_jsonb(metadata: dict | None):
        """Adapt a dict to a jsonb-compatible parameter."""
        if metadata is None:
            return None
        from psycopg.types.json import Jsonb  # lazy import

        return Jsonb(metadata)


def load_store(settings) -> VectorStore:
    """Construct the vector store selected by ``settings.store_backend``.

    For ``"auto"``, pgvector is used when ``database_url`` is set, otherwise the
    in-memory store. On a pgvector connection error the in-memory store is used
    (a warning is logged).
    """
    backend = settings.store_backend

    if backend == "memory":
        return InMemoryStore()

    if backend == "pgvector":
        if not settings.database_url:
            raise ValueError("store_backend='pgvector' requires database_url to be set")
        return PgVectorStore(settings.database_url)

    # auto
    if settings.database_url:
        try:
            return PgVectorStore(settings.database_url)
        except Exception as exc:  # pragma: no cover - depends on DB availability
            logger.warning(
                "pgvector unavailable (%s); falling back to InMemoryStore.", exc
            )
            return InMemoryStore()
    return InMemoryStore()
