"""Tests for :mod:`utils.image_processing`.

Covers SHA-256 determinism, the perceptual dHash (stability + Hamming distance
behaviour) and the validation helper. Uses deterministic PIL+NumPy PNGs, fully
offline.
"""

from __future__ import annotations

import io

import numpy as np
import pytest
from PIL import Image

from utils.image_processing import (
    decode_image,
    hamming_distance,
    perceptual_hash,
    sha256_hex,
    validate_image,
)


def _png_bytes(seed: int, size: tuple[int, int] = (128, 128)) -> bytes:
    """Build reproducible PNG bytes from a seeded random RGB array."""
    rng = np.random.default_rng(seed)
    arr = rng.integers(0, 256, size=(size[1], size[0], 3), dtype=np.uint8)
    buf = io.BytesIO()
    Image.fromarray(arr, mode="RGB").save(buf, format="PNG")
    return buf.getvalue()


def test_sha256_deterministic_and_distinct() -> None:
    """Same bytes hash identically; different bytes hash differently."""
    a = _png_bytes(1)
    b = _png_bytes(999)
    assert sha256_hex(a) == sha256_hex(a)
    assert len(sha256_hex(a)) == 64
    assert sha256_hex(a) != sha256_hex(b)


def test_perceptual_hash_stable_and_format() -> None:
    """The perceptual hash is a stable 16-char hex string for a given image."""
    img = decode_image(_png_bytes(1))
    h1 = perceptual_hash(img)
    h2 = perceptual_hash(img)
    assert h1 == h2
    assert len(h1) == 16
    int(h1, 16)  # must parse as hex


def test_hamming_zero_for_same_image() -> None:
    """Identical images produce phashes with Hamming distance 0."""
    img = decode_image(_png_bytes(1))
    assert hamming_distance(perceptual_hash(img), perceptual_hash(img)) == 0


def test_hamming_positive_for_different_images() -> None:
    """Visually different images produce a positive Hamming distance."""
    a = decode_image(_png_bytes(1))
    b = decode_image(_png_bytes(999))
    assert hamming_distance(perceptual_hash(a), perceptual_hash(b)) > 0


def test_validate_image_accepts_valid_png() -> None:
    """A valid PNG within the size limit passes validation."""
    validate_image(_png_bytes(1), max_mb=10)  # should not raise


def test_validate_image_rejects_empty() -> None:
    """Empty payloads are rejected."""
    with pytest.raises(ValueError):
        validate_image(b"", max_mb=10)


def test_validate_image_rejects_junk() -> None:
    """Undecodable junk bytes are rejected."""
    with pytest.raises(ValueError):
        validate_image(b"not-an-image-at-all", max_mb=10)


def test_validate_image_rejects_too_large() -> None:
    """Payloads exceeding the size limit are rejected."""
    big = _png_bytes(1)
    with pytest.raises(ValueError):
        validate_image(big, max_mb=0)
