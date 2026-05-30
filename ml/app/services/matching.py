"""Vector math helpers for embedding comparison."""

from __future__ import annotations

import numpy as np


def l2_normalize(v: np.ndarray) -> np.ndarray:
    """Return ``v`` scaled to unit L2 norm.

    A zero vector is returned unchanged (to avoid division by zero).
    """
    arr = np.asarray(v, dtype=np.float64)
    norm = float(np.linalg.norm(arr))
    if norm == 0.0:
        return arr
    return arr / norm


def cosine_similarity(a: np.ndarray, b: np.ndarray) -> float:
    """Compute cosine similarity between two vectors.

    Safe for unnormalized inputs; returns ``0.0`` if either vector is zero.
    """
    av = np.asarray(a, dtype=np.float64)
    bv = np.asarray(b, dtype=np.float64)
    na = float(np.linalg.norm(av))
    nb = float(np.linalg.norm(bv))
    if na == 0.0 or nb == 0.0:
        return 0.0
    return float(np.dot(av, bv) / (na * nb))
