"""Embedding extraction, vector indexing and fast similarity search.

This module wires the app face engine (``app.services.face_engine``) to the
image database (:mod:`services.database_service`) and provides a FAISS-backed
nearest-neighbour index with a transparent NumPy fallback.

Nothing here hard-requires FAISS: ``import faiss`` is performed lazily and, when
unavailable (or disabled via ``settings.use_faiss``), a NumPy matrix is used
for cosine search instead. The whole module therefore works offline with the
stub engine and the in-memory database.
"""

from __future__ import annotations

import logging

import numpy as np

from app.services.matching import l2_normalize
from services.database_service import EmbeddingRecord, ImageDatabase
from utils.similarity import cosine_matrix

logger = logging.getLogger(__name__)


class VectorIndex:
    """Cosine-similarity vector index with FAISS acceleration and NumPy fallback.

    Vectors are L2-normalized on insertion so an inner-product search is
    equivalent to cosine similarity. When FAISS is available and ``use_faiss``
    is true an ``IndexFlatIP`` is used; otherwise a row-stacked NumPy matrix is
    queried directly.

    Attributes:
        dim: Dimensionality of the stored vectors.
        use_faiss: Whether FAISS acceleration is requested.
    """

    def __init__(self, dim: int, use_faiss: bool = True) -> None:
        """Initialise an empty index.

        Args:
            dim: Vector dimensionality (e.g. ``512``).
            use_faiss: Attempt to use FAISS when available.
        """
        self.dim = int(dim)
        self.use_faiss = bool(use_faiss)
        self._ids: list[str] = []
        self._matrix: np.ndarray | None = None  # (N, dim) L2-normalized rows
        self._faiss = None  # the faiss module, if loaded
        self._index = None  # faiss.IndexFlatIP, if built

    # -- internals -------------------------------------------------------

    def _try_load_faiss(self):
        """Return the ``faiss`` module if usable, else ``None`` (logged once)."""
        if not self.use_faiss:
            return None
        if self._faiss is not None:
            return self._faiss
        try:
            import faiss  # lazy import

            self._faiss = faiss
            return faiss
        except Exception as exc:  # pragma: no cover - depends on optional dep
            logger.info(
                "FAISS unavailable (%s); using NumPy similarity fallback.", exc
            )
            self.use_faiss = False
            return None

    @staticmethod
    def _unit(vector: list[float] | np.ndarray, dim: int) -> np.ndarray:
        """Return ``vector`` as a float32, L2-normalized row of length ``dim``."""
        arr = np.asarray(vector, dtype=np.float64).reshape(-1)
        arr = np.asarray(l2_normalize(arr), dtype=np.float32)
        return arr

    # -- public API ------------------------------------------------------

    def build(self, ids: list[str], vectors: list[list[float]]) -> None:
        """Replace the index contents with ``ids`` / ``vectors``.

        Args:
            ids: Identifiers aligned 1:1 with ``vectors``.
            vectors: Embeddings as lists of floats (length ``dim``).
        """
        self._ids = list(ids)
        self._index = None
        if not vectors:
            self._matrix = np.zeros((0, self.dim), dtype=np.float32)
            return

        rows = [self._unit(v, self.dim) for v in vectors]
        self._matrix = np.vstack(rows).astype(np.float32)

        faiss = self._try_load_faiss()
        if faiss is not None:
            try:
                index = faiss.IndexFlatIP(self.dim)
                index.add(self._matrix)
                self._index = index
            except Exception as exc:  # pragma: no cover - depends on optional dep
                logger.warning(
                    "Failed to build FAISS index (%s); using NumPy fallback.", exc
                )
                self._index = None

    def add(self, id: str, vector: list[float]) -> None:
        """Append a single vector to the index.

        Args:
            id: Identifier for the vector.
            vector: Embedding as a list of floats (length ``dim``).
        """
        row = self._unit(vector, self.dim).reshape(1, -1)
        self._ids.append(id)
        if self._matrix is None or self._matrix.shape[0] == 0:
            self._matrix = row
        else:
            self._matrix = np.vstack([self._matrix, row]).astype(np.float32)

        if self._index is not None:
            try:
                self._index.add(row)
            except Exception as exc:  # pragma: no cover - depends on optional dep
                logger.warning(
                    "FAISS add failed (%s); rebuilding NumPy fallback only.", exc
                )
                self._index = None

    def search(self, query: list[float], k: int) -> list[tuple[str, float]]:
        """Return up to ``k`` ``(id, cosine_sim)`` pairs in descending order.

        Args:
            query: Query embedding as a list of floats (length ``dim``).
            k: Maximum number of neighbours to return.

        Returns:
            A list of ``(id, cosine_similarity)`` tuples, highest first. Empty
            when the index holds no vectors.
        """
        if self._matrix is None or self._matrix.shape[0] == 0 or k <= 0:
            return []

        q = self._unit(query, self.dim)
        top = min(int(k), len(self._ids))

        if self._index is not None:
            try:
                scores, idxs = self._index.search(q.reshape(1, -1), top)
                results: list[tuple[str, float]] = []
                for score, idx in zip(scores[0], idxs[0]):
                    if idx < 0:
                        continue
                    results.append((self._ids[int(idx)], float(score)))
                return results
            except Exception as exc:  # pragma: no cover - depends on optional dep
                logger.warning(
                    "FAISS search failed (%s); using NumPy fallback.", exc
                )

        sims = cosine_matrix(q, self._matrix)
        order = np.argsort(sims)[::-1][:top]
        return [(self._ids[int(i)], float(sims[int(i)])) for i in order]

    def size(self) -> int:
        """Return the number of vectors currently stored."""
        return len(self._ids)


class EmbeddingService:
    """Extract face embeddings and search them against the stored corpus.

    Combines the app face engine with a :class:`VectorIndex` whose contents are
    sourced from an :class:`~services.database_service.ImageDatabase`. New
    embeddings are written through to both the database and the live index.
    """

    def __init__(self, db: ImageDatabase, engine, settings) -> None:
        """Initialise the service.

        Args:
            db: Image/embedding database backend.
            engine: App face engine (from ``load_engine``) exposing ``embed``.
            settings: Settings object exposing ``embedding_dim`` and
                ``use_faiss``.
        """
        self.db = db
        self.engine = engine
        self.settings = settings
        self.dim = int(getattr(settings, "embedding_dim", 512))
        self.index = VectorIndex(self.dim, use_faiss=bool(getattr(settings, "use_faiss", True)))
        self._records: dict[str, EmbeddingRecord] = {}

    def embed_faces(self, image: np.ndarray) -> list:
        """Detect and embed faces, returning only those with an embedding.

        Args:
            image: RGB ``HxWx3`` ``uint8`` image.

        Returns:
            The list of ``Face`` objects whose ``embedding`` is not ``None``.
        """
        try:
            faces = self.engine.embed(image)
        except Exception as exc:
            logger.warning("Face embedding failed: %s", exc)
            return []
        return [f for f in faces if getattr(f, "embedding", None) is not None]

    def build_index(self) -> None:
        """(Re)load all embeddings from the database into the vector index.

        Never raises: a database error (e.g. the image tables not yet created)
        is logged and leaves an empty index, so the rest of the service keeps
        working instead of failing to start.
        """
        try:
            records = self.db.all_embeddings()
        except Exception as exc:
            logger.warning(
                "Could not load embeddings for the index (%s); starting empty. "
                "If using Postgres, apply app/db/images_schema.sql.",
                exc,
            )
            records = []
        self._records = {r.id: r for r in records}
        ids = [r.id for r in records]
        vectors = [r.embedding for r in records]
        self.index.build(ids, vectors)
        logger.info(
            "Built vector index with %d embeddings (faiss=%s).",
            self.index.size(),
            self.index.use_faiss,
        )

    def search(
        self, embedding: list[float], k: int | None = None
    ) -> list[tuple[EmbeddingRecord, float]]:
        """Search the index and resolve matches to embedding records.

        Args:
            embedding: Query embedding as a list of floats.
            k: Maximum number of neighbours (defaults to ``min(size, 10)``).

        Returns:
            A list of ``(EmbeddingRecord, cosine_similarity)`` pairs, highest
            similarity first. Records missing from the cache are skipped.
        """
        if k is None:
            k = min(self.index.size(), 10) or 1
        hits = self.index.search(embedding, k)
        results: list[tuple[EmbeddingRecord, float]] = []
        for emb_id, sim in hits:
            record = self._records.get(emb_id)
            if record is not None:
                results.append((record, sim))
        return results

    def add_embedding(
        self,
        image_id: str,
        embedding: list[float],
        person_id: str | None,
        bbox: dict | None,
        det_score: float | None,
    ) -> EmbeddingRecord:
        """Persist an embedding and add it to the live index and cache.

        Args:
            image_id: Owning image id.
            embedding: 512-d embedding as a list of floats.
            person_id: Linked person id, if any.
            bbox: Bounding box dict, if any.
            det_score: Detection confidence, if any.

        Returns:
            The created :class:`EmbeddingRecord`.
        """
        record = self.db.add_embedding(image_id, embedding, person_id, bbox, det_score)
        self._records[record.id] = record
        self.index.add(record.id, record.embedding)
        return record

    def batch_index_images(self, items: list[tuple[str, np.ndarray]]) -> int:
        """Detect, embed and store every face for a batch of images.

        Args:
            items: ``(image_id, image)`` pairs to process.

        Returns:
            The total number of face embeddings stored across all images.
        """
        count = 0
        for image_id, image in items:
            faces = self.embed_faces(image)
            for face in faces:
                embedding = [float(v) for v in np.asarray(face.embedding).reshape(-1)]
                x1, y1, x2, y2 = (float(c) for c in face.bbox)
                bbox = {"x1": x1, "y1": y1, "x2": x2, "y2": y2}
                self.add_embedding(
                    image_id=image_id,
                    embedding=embedding,
                    person_id=None,
                    bbox=bbox,
                    det_score=float(getattr(face, "det_score", 0.0)),
                )
                count += 1
        return count


def load_embedding_service(db: ImageDatabase, engine, settings) -> EmbeddingService:
    """Construct an :class:`EmbeddingService` for ``db`` / ``engine``.

    Args:
        db: Image/embedding database backend.
        engine: App face engine (from ``load_engine``).
        settings: Settings object.

    Returns:
        A ready-to-use :class:`EmbeddingService` (call ``build_index`` to load
        existing embeddings).
    """
    return EmbeddingService(db, engine, settings)


__all__ = ["VectorIndex", "EmbeddingService", "load_embedding_service"]
