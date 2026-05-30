"""Similarity helpers for the face-recognition subsystem.

Wraps :func:`app.services.matching.cosine_similarity` and adds batch cosine
computation, percentage formatting and threshold-based classification used by
the recognizer and verifier. NumPy-only, fully offline.
"""

from __future__ import annotations

import logging

import numpy as np

from app.services.matching import cosine_similarity, l2_normalize

logger = logging.getLogger(__name__)


def cosine(a: np.ndarray, b: np.ndarray) -> float:
    """Return the cosine similarity between two vectors.

    Thin re-export of :func:`app.services.matching.cosine_similarity`.

    Args:
        a: First vector.
        b: Second vector.

    Returns:
        Cosine similarity in ``[-1, 1]`` (``0.0`` for a zero vector).
    """
    return cosine_similarity(a, b)


def cosine_matrix(query: np.ndarray, matrix: np.ndarray) -> np.ndarray:
    """Compute cosine similarities of ``query`` against each row of ``matrix``.

    Args:
        query: 1-D query vector of length ``D``.
        matrix: 2-D array of shape ``(N, D)`` of row-stacked vectors.

    Returns:
        1-D array of shape ``(N,)`` with the cosine similarity for each row.
        An empty array is returned when ``matrix`` has no rows.
    """
    mat = np.asarray(matrix, dtype=np.float64)
    if mat.ndim != 2 or mat.shape[0] == 0:
        return np.zeros((0,), dtype=np.float64)

    q = np.asarray(query, dtype=np.float64).reshape(-1)
    q_norm = float(np.linalg.norm(q))
    if q_norm == 0.0:
        return np.zeros((mat.shape[0],), dtype=np.float64)
    q_unit = q / q_norm

    row_norms = np.linalg.norm(mat, axis=1)
    safe_norms = np.where(row_norms == 0.0, 1.0, row_norms)
    sims = (mat @ q_unit) / safe_norms
    # Rows that were zero vectors contribute a similarity of 0.
    sims = np.where(row_norms == 0.0, 0.0, sims)
    return sims.astype(np.float64)


def to_percent(sim: float) -> float:
    """Convert a cosine similarity to a clamped percentage rounded to 1 dp.

    Negative similarities are clamped to ``0``.

    Args:
        sim: Cosine similarity in ``[-1, 1]``.

    Returns:
        Percentage in ``[0, 100]`` rounded to one decimal place.
    """
    return round(max(0.0, float(sim)) * 100, 1)


def classify(sim: float, has_person: bool, settings) -> str:
    """Classify a best-match similarity into ``known`` / ``similar`` / ``unknown``.

    Args:
        sim: Best cosine similarity found for the query face.
        has_person: Whether the best-matching record is linked to a person.
        settings: Settings object exposing ``recognition_threshold`` and
            ``similar_threshold``.

    Returns:
        ``"known"`` if ``sim >= recognition_threshold`` and ``has_person`` is
        true; otherwise ``"similar"`` if ``sim >= similar_threshold``; otherwise
        ``"unknown"``.
    """
    s = float(sim)
    if has_person and s >= settings.recognition_threshold:
        return "known"
    if s >= settings.similar_threshold:
        return "similar"
    return "unknown"


def is_duplicate_by_face(sim: float, settings) -> bool:
    """Return whether a face similarity indicates a duplicate.

    Args:
        sim: Face-embedding cosine similarity.
        settings: Settings object exposing ``duplicate_threshold``.

    Returns:
        ``True`` when ``sim >= settings.duplicate_threshold``.
    """
    return float(sim) >= settings.duplicate_threshold


__all__ = [
    "cosine",
    "cosine_matrix",
    "to_percent",
    "classify",
    "is_duplicate_by_face",
    "l2_normalize",
]
