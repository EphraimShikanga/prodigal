"""Image / face-embedding persistence for the verification subsystem.

Two backends mirror :mod:`app.services.vector_store`:

* :class:`InMemoryImageDatabase` -- dict-backed, no external dependencies; used
  for development and tests (always works offline).
* :class:`PgImageDatabase` -- Postgres + ``pgvector`` via ``psycopg`` (imported
  lazily), backed by the ``images`` / ``persons`` / ``face_embeddings`` tables
  defined in ``app/db/images_schema.sql``.

Use :func:`load_database` to construct the backend selected by the presence of
``settings.database_url`` (falling back to in-memory on any connection error).
"""

from __future__ import annotations

import logging
import uuid
from abc import ABC, abstractmethod
from dataclasses import dataclass, field

logger = logging.getLogger(__name__)


@dataclass
class ImageRecord:
    """A stored image plus its content and perceptual hashes.

    Attributes:
        id: Unique id (uuid4 string).
        image_path: On-disk path of the saved image, if any.
        image_hash: SHA-256 hex digest of the raw bytes (exact-dup key).
        phash: Perceptual hash (dHash hex) for near-duplicate detection.
        uploaded_at: ISO timestamp string, if known.
    """

    id: str
    image_path: str | None
    image_hash: str | None
    phash: str | None
    uploaded_at: str | None = None


@dataclass
class PersonRecord:
    """A known/enrolled person.

    Attributes:
        id: Unique id (uuid4 string).
        name: Person's display name.
        image_id: Representative image they were enrolled from, if any.
    """

    id: str
    name: str
    image_id: str | None = None


@dataclass
class EmbeddingRecord:
    """A single detected face embedding with detection metadata.

    Attributes:
        id: Unique id (uuid4 string).
        image_id: Image this face belongs to.
        person_id: Linked person, if identified/enrolled.
        embedding: 512-d embedding as a list of floats.
        bbox: Bounding box as a JSON-serializable dict, if known.
        det_score: Detection confidence, if known.
    """

    id: str
    image_id: str
    person_id: str | None
    embedding: list[float]
    bbox: dict | None
    det_score: float | None


class ImageDatabase(ABC):
    """Abstract store for images, persons and face embeddings."""

    name: str = "base"

    @abstractmethod
    def add_image(
        self, image_path: str | None, image_hash: str, phash: str | None
    ) -> ImageRecord:
        """Insert an image row and return the created record."""
        raise NotImplementedError

    @abstractmethod
    def get_image(self, image_id: str) -> ImageRecord | None:
        """Return the image with ``image_id`` or ``None``."""
        raise NotImplementedError

    @abstractmethod
    def find_image_by_hash(self, image_hash: str) -> ImageRecord | None:
        """Return the image whose ``image_hash`` matches, or ``None``."""
        raise NotImplementedError

    @abstractmethod
    def list_image_phashes(self) -> list[tuple[str, str]]:
        """Return ``(image_id, phash)`` pairs for images with a non-null phash."""
        raise NotImplementedError

    @abstractmethod
    def add_embedding(
        self,
        image_id: str,
        embedding: list[float],
        person_id: str | None,
        bbox: dict | None,
        det_score: float | None,
    ) -> EmbeddingRecord:
        """Insert a face-embedding row and return the created record."""
        raise NotImplementedError

    @abstractmethod
    def all_embeddings(self) -> list[EmbeddingRecord]:
        """Return every stored embedding record."""
        raise NotImplementedError

    @abstractmethod
    def embeddings_for_image(self, image_id: str) -> list[EmbeddingRecord]:
        """Return all embedding records belonging to ``image_id``."""
        raise NotImplementedError

    @abstractmethod
    def add_person(self, name: str, image_id: str | None) -> PersonRecord:
        """Insert a person row and return the created record."""
        raise NotImplementedError

    @abstractmethod
    def get_person(self, person_id: str) -> PersonRecord | None:
        """Return the person with ``person_id`` or ``None``."""
        raise NotImplementedError

    @abstractmethod
    def find_person_by_name(self, name: str) -> PersonRecord | None:
        """Return the first person whose ``name`` matches, or ``None``."""
        raise NotImplementedError

    @abstractmethod
    def count_images(self) -> int:
        """Return the total number of stored images."""
        raise NotImplementedError

    @abstractmethod
    def count_embeddings(self) -> int:
        """Return the total number of stored embeddings."""
        raise NotImplementedError


class InMemoryImageDatabase(ImageDatabase):
    """Dict-backed image database with no external dependencies."""

    name = "memory"

    def __init__(self) -> None:
        self._images: dict[str, ImageRecord] = {}
        self._persons: dict[str, PersonRecord] = {}
        self._embeddings: dict[str, EmbeddingRecord] = {}

    def add_image(
        self, image_path: str | None, image_hash: str, phash: str | None
    ) -> ImageRecord:
        record = ImageRecord(
            id=str(uuid.uuid4()),
            image_path=image_path,
            image_hash=image_hash,
            phash=phash,
            uploaded_at=None,
        )
        self._images[record.id] = record
        return record

    def get_image(self, image_id: str) -> ImageRecord | None:
        return self._images.get(image_id)

    def find_image_by_hash(self, image_hash: str) -> ImageRecord | None:
        for record in self._images.values():
            if record.image_hash == image_hash:
                return record
        return None

    def list_image_phashes(self) -> list[tuple[str, str]]:
        return [
            (record.id, record.phash)
            for record in self._images.values()
            if record.phash is not None
        ]

    def add_embedding(
        self,
        image_id: str,
        embedding: list[float],
        person_id: str | None,
        bbox: dict | None,
        det_score: float | None,
    ) -> EmbeddingRecord:
        record = EmbeddingRecord(
            id=str(uuid.uuid4()),
            image_id=image_id,
            person_id=person_id,
            embedding=[float(v) for v in embedding],
            bbox=bbox,
            det_score=det_score,
        )
        self._embeddings[record.id] = record
        return record

    def all_embeddings(self) -> list[EmbeddingRecord]:
        return list(self._embeddings.values())

    def embeddings_for_image(self, image_id: str) -> list[EmbeddingRecord]:
        return [r for r in self._embeddings.values() if r.image_id == image_id]

    def add_person(self, name: str, image_id: str | None) -> PersonRecord:
        record = PersonRecord(id=str(uuid.uuid4()), name=name, image_id=image_id)
        self._persons[record.id] = record
        return record

    def get_person(self, person_id: str) -> PersonRecord | None:
        return self._persons.get(person_id)

    def find_person_by_name(self, name: str) -> PersonRecord | None:
        for record in self._persons.values():
            if record.name == name:
                return record
        return None

    def count_images(self) -> int:
        return len(self._images)

    def count_embeddings(self) -> int:
        return len(self._embeddings)


class PgImageDatabase(ImageDatabase):
    """Postgres + ``pgvector`` image database.

    ``psycopg`` and ``pgvector`` are imported lazily inside ``__init__`` so the
    base install never requires them. Embeddings are stored and returned as
    plain ``list[float]``.
    """

    name = "pgvector"

    def __init__(self, database_url: str) -> None:
        import numpy as np  # lazy import
        import psycopg  # lazy import
        from pgvector.psycopg import register_vector  # lazy import

        self._np = np
        self._database_url = database_url
        self._conn = psycopg.connect(database_url, autocommit=True)
        register_vector(self._conn)

    # -- helpers ---------------------------------------------------------

    @staticmethod
    def _to_jsonb(value: dict | None):
        """Adapt a dict to a jsonb-compatible parameter."""
        if value is None:
            return None
        from psycopg.types.json import Jsonb  # lazy import

        return Jsonb(value)

    def _embedding_to_list(self, value) -> list[float]:
        """Coerce a pgvector value into a plain ``list[float]``."""
        return [float(v) for v in self._np.asarray(value, dtype=self._np.float64)]

    # -- images ----------------------------------------------------------

    def add_image(
        self, image_path: str | None, image_hash: str, phash: str | None
    ) -> ImageRecord:
        with self._conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO images (image_path, image_hash, phash)
                VALUES (%s, %s, %s)
                RETURNING id, image_path, image_hash, phash, uploaded_at
                """,
                (image_path, image_hash, phash),
            )
            row = cur.fetchone()
        return self._image_from_row(row)

    def get_image(self, image_id: str) -> ImageRecord | None:
        with self._conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, image_path, image_hash, phash, uploaded_at
                FROM images WHERE id = %s
                """,
                (image_id,),
            )
            row = cur.fetchone()
        return self._image_from_row(row) if row else None

    def find_image_by_hash(self, image_hash: str) -> ImageRecord | None:
        with self._conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, image_path, image_hash, phash, uploaded_at
                FROM images WHERE image_hash = %s LIMIT 1
                """,
                (image_hash,),
            )
            row = cur.fetchone()
        return self._image_from_row(row) if row else None

    def list_image_phashes(self) -> list[tuple[str, str]]:
        with self._conn.cursor() as cur:
            cur.execute(
                "SELECT id, phash FROM images WHERE phash IS NOT NULL"
            )
            rows = cur.fetchall()
        return [(str(image_id), phash) for image_id, phash in rows]

    @staticmethod
    def _image_from_row(row) -> ImageRecord:
        image_id, image_path, image_hash, phash, uploaded_at = row
        return ImageRecord(
            id=str(image_id),
            image_path=image_path,
            image_hash=image_hash,
            phash=phash,
            uploaded_at=str(uploaded_at) if uploaded_at is not None else None,
        )

    # -- embeddings ------------------------------------------------------

    def add_embedding(
        self,
        image_id: str,
        embedding: list[float],
        person_id: str | None,
        bbox: dict | None,
        det_score: float | None,
    ) -> EmbeddingRecord:
        vector = self._np.asarray(embedding, dtype=self._np.float32)
        with self._conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO face_embeddings
                    (image_id, person_id, embedding, bbox, det_score)
                VALUES (%s, %s, %s, %s, %s)
                RETURNING id, image_id, person_id, embedding, bbox, det_score
                """,
                (
                    image_id,
                    person_id,
                    vector,
                    self._to_jsonb(bbox),
                    det_score,
                ),
            )
            row = cur.fetchone()
        return self._embedding_from_row(row)

    def all_embeddings(self) -> list[EmbeddingRecord]:
        with self._conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, image_id, person_id, embedding, bbox, det_score
                FROM face_embeddings
                """
            )
            rows = cur.fetchall()
        return [self._embedding_from_row(row) for row in rows]

    def embeddings_for_image(self, image_id: str) -> list[EmbeddingRecord]:
        with self._conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, image_id, person_id, embedding, bbox, det_score
                FROM face_embeddings WHERE image_id = %s
                """,
                (image_id,),
            )
            rows = cur.fetchall()
        return [self._embedding_from_row(row) for row in rows]

    def _embedding_from_row(self, row) -> EmbeddingRecord:
        emb_id, image_id, person_id, embedding, bbox, det_score = row
        return EmbeddingRecord(
            id=str(emb_id),
            image_id=str(image_id),
            person_id=str(person_id) if person_id is not None else None,
            embedding=self._embedding_to_list(embedding),
            bbox=bbox,
            det_score=float(det_score) if det_score is not None else None,
        )

    # -- persons ---------------------------------------------------------

    def add_person(self, name: str, image_id: str | None) -> PersonRecord:
        with self._conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO persons (name, image_id)
                VALUES (%s, %s)
                RETURNING id, name, image_id
                """,
                (name, image_id),
            )
            row = cur.fetchone()
        return self._person_from_row(row)

    def get_person(self, person_id: str) -> PersonRecord | None:
        with self._conn.cursor() as cur:
            cur.execute(
                "SELECT id, name, image_id FROM persons WHERE id = %s",
                (person_id,),
            )
            row = cur.fetchone()
        return self._person_from_row(row) if row else None

    def find_person_by_name(self, name: str) -> PersonRecord | None:
        with self._conn.cursor() as cur:
            cur.execute(
                "SELECT id, name, image_id FROM persons WHERE name = %s LIMIT 1",
                (name,),
            )
            row = cur.fetchone()
        return self._person_from_row(row) if row else None

    @staticmethod
    def _person_from_row(row) -> PersonRecord:
        person_id, name, image_id = row
        return PersonRecord(
            id=str(person_id),
            name=name,
            image_id=str(image_id) if image_id is not None else None,
        )

    # -- counts ----------------------------------------------------------

    def count_images(self) -> int:
        with self._conn.cursor() as cur:
            cur.execute("SELECT COUNT(*) FROM images")
            row = cur.fetchone()
        return int(row[0]) if row else 0

    def count_embeddings(self) -> int:
        with self._conn.cursor() as cur:
            cur.execute("SELECT COUNT(*) FROM face_embeddings")
            row = cur.fetchone()
        return int(row[0]) if row else 0


def load_database(settings) -> ImageDatabase:
    """Construct the image database selected by ``settings.database_url``.

    Uses :class:`PgImageDatabase` when ``settings.database_url`` is set,
    otherwise :class:`InMemoryImageDatabase`. On any pgvector connection error
    the in-memory backend is used and a warning is logged.
    """
    database_url = getattr(settings, "database_url", None)
    if database_url:
        try:
            return PgImageDatabase(database_url)
        except Exception as exc:  # pragma: no cover - depends on DB availability
            logger.warning(
                "pgvector image database unavailable (%s); falling back to "
                "InMemoryImageDatabase.",
                exc,
            )
            return InMemoryImageDatabase()
    return InMemoryImageDatabase()
