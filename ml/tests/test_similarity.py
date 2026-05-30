"""Tests for :mod:`utils.similarity`.

Covers cosine similarity, batched cosine against a matrix, percentage
formatting and the threshold-based classification helpers. Pure NumPy, fully
offline.
"""

from __future__ import annotations

import numpy as np

from app.config import get_settings
from utils.similarity import (
    classify,
    cosine,
    cosine_matrix,
    is_duplicate_by_face,
    to_percent,
)


def test_cosine_identical_and_orthogonal() -> None:
    """Identical vectors give 1.0; orthogonal vectors give 0.0."""
    a = np.array([1.0, 0.0, 0.0])
    b = np.array([2.0, 0.0, 0.0])
    c = np.array([0.0, 1.0, 0.0])
    assert cosine(a, b) == 1.0
    assert abs(cosine(a, c)) < 1e-9


def test_cosine_opposite() -> None:
    """Opposite vectors give -1.0."""
    a = np.array([1.0, 1.0])
    b = np.array([-1.0, -1.0])
    assert abs(cosine(a, b) - (-1.0)) < 1e-9


def test_cosine_matrix_shape_and_values() -> None:
    """cosine_matrix returns one similarity per row, highest for the match."""
    query = np.array([1.0, 0.0, 0.0])
    matrix = np.array(
        [
            [1.0, 0.0, 0.0],   # identical -> 1.0
            [0.0, 1.0, 0.0],   # orthogonal -> 0.0
            [-1.0, 0.0, 0.0],  # opposite -> -1.0
        ]
    )
    sims = cosine_matrix(query, matrix)
    assert sims.shape == (3,)
    assert abs(sims[0] - 1.0) < 1e-9
    assert abs(sims[1] - 0.0) < 1e-9
    assert abs(sims[2] - (-1.0)) < 1e-9


def test_cosine_matrix_empty() -> None:
    """An empty matrix yields an empty similarity array."""
    sims = cosine_matrix(np.array([1.0, 0.0]), np.zeros((0, 2)))
    assert sims.shape == (0,)


def test_to_percent_clamps_and_rounds() -> None:
    """to_percent clamps negatives to 0 and rounds to one decimal place."""
    assert to_percent(1.0) == 100.0
    assert to_percent(0.0) == 0.0
    assert to_percent(-0.5) == 0.0
    assert to_percent(0.12345) == 12.3
    assert to_percent(0.305) in (30.5, 30.4)  # rounding tolerance


def test_classify_thresholds() -> None:
    """classify maps similarity + person presence to known/similar/unknown."""
    settings = get_settings()
    rec = settings.recognition_threshold  # 0.45
    sim_t = settings.similar_threshold    # 0.30

    # Above recognition threshold AND linked to a person -> known.
    assert classify(rec + 0.1, True, settings) == "known"
    # Above recognition threshold but no person -> falls through to similar.
    assert classify(rec + 0.1, False, settings) == "similar"
    # Between similar and recognition thresholds -> similar.
    assert classify((rec + sim_t) / 2, True, settings) == "similar"
    # Below similar threshold -> unknown.
    assert classify(sim_t - 0.05, True, settings) == "unknown"


def test_is_duplicate_by_face() -> None:
    """is_duplicate_by_face fires only at/above the duplicate threshold."""
    settings = get_settings()
    dup = settings.duplicate_threshold  # 0.97
    assert is_duplicate_by_face(dup, settings) is True
    assert is_duplicate_by_face(dup + 0.01, settings) is True
    assert is_duplicate_by_face(dup - 0.01, settings) is False
