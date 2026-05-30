"""Image-processing utilities for the face-recognition subsystem.

These helpers wrap the existing :mod:`app.services.imaging` decoder and add
hashing, perceptual hashing (dHash), validation and on-disk persistence used by
the image-verification pipeline. Everything works offline with only NumPy and
Pillow (already required by the base service).
"""

from __future__ import annotations

import hashlib
import logging
import os

import numpy as np

from app.services.imaging import decode_image as _decode_image

logger = logging.getLogger(__name__)


def decode_image(data: bytes) -> np.ndarray:
    """Decode raw image bytes into an RGB ``uint8`` ``HxWx3`` array.

    Thin re-export of :func:`app.services.imaging.decode_image` so callers in
    this package have a single import surface.

    Args:
        data: Raw encoded image bytes (PNG, JPEG, ...).

    Returns:
        RGB ``uint8`` array of shape ``(H, W, 3)``.

    Raises:
        ValueError: If the bytes cannot be decoded.
    """
    return _decode_image(data)


def load_image_from_path(path: str) -> np.ndarray:
    """Load and decode an image file from disk into an RGB ``uint8`` array.

    Args:
        path: Filesystem path to an image file.

    Returns:
        RGB ``uint8`` array of shape ``(H, W, 3)``.

    Raises:
        ValueError: If the file cannot be read or decoded.
    """
    try:
        with open(path, "rb") as fh:
            data = fh.read()
    except OSError as exc:
        raise ValueError(f"Could not read image from path {path!r}: {exc}") from exc
    return decode_image(data)


def sha256_hex(data: bytes) -> str:
    """Return the hex-encoded SHA-256 digest of ``data``.

    Args:
        data: Raw bytes (typically the original encoded image).

    Returns:
        64-character lowercase hex string.
    """
    return hashlib.sha256(data).hexdigest()


def perceptual_hash(image: np.ndarray) -> str:
    """Compute a 64-bit difference-hash (dHash) as a 16-char hex string.

    The image is converted to grayscale and resized to ``9x8``; each of the 64
    bits is set when a pixel is brighter than its right-hand neighbour. Visually
    similar images produce hashes with a small Hamming distance.

    Args:
        image: RGB (or grayscale) ``uint8`` array.

    Returns:
        16-character lowercase hex string encoding the 64-bit hash.
    """
    from PIL import Image

    arr = np.asarray(image, dtype=np.uint8)
    pil = Image.fromarray(arr).convert("L").resize((9, 8))
    gray = np.asarray(pil, dtype=np.int16)

    # Compare each pixel to its right neighbour -> 8x8 boolean grid.
    diff = gray[:, 1:] > gray[:, :-1]
    bits = diff.flatten()

    value = 0
    for bit in bits:
        value = (value << 1) | int(bool(bit))
    return f"{value:016x}"


def hamming_distance(hex1: str, hex2: str) -> int:
    """Return the Hamming distance between two hex-encoded hashes.

    Args:
        hex1: First hex-encoded hash.
        hex2: Second hex-encoded hash.

    Returns:
        Number of differing bits.
    """
    return int(bin(int(hex1, 16) ^ int(hex2, 16)).count("1"))


def validate_image(data: bytes, max_mb: int) -> None:
    """Validate raw image bytes for size and decodability.

    Args:
        data: Raw encoded image bytes.
        max_mb: Maximum allowed size in megabytes.

    Raises:
        ValueError: If ``data`` is empty, exceeds ``max_mb`` or cannot be decoded.
    """
    if not data:
        raise ValueError("Empty image payload.")
    size_mb = len(data) / (1024 * 1024)
    if size_mb > max_mb:
        raise ValueError(
            f"Image too large: {size_mb:.2f} MB exceeds limit of {max_mb} MB."
        )
    # Raises ValueError if the bytes are not a decodable image.
    decode_image(data)


def save_image(data: bytes, dest_dir: str, filename: str) -> str:
    """Persist ``data`` to ``dest_dir/filename``, creating directories as needed.

    Args:
        data: Raw bytes to write.
        dest_dir: Destination directory (created with ``mkdir -p`` semantics).
        filename: File name to write within ``dest_dir``.

    Returns:
        The full path to the written file.

    Raises:
        ValueError: If the file could not be written.
    """
    try:
        os.makedirs(dest_dir, exist_ok=True)
        full_path = os.path.join(dest_dir, filename)
        with open(full_path, "wb") as fh:
            fh.write(data)
        return full_path
    except OSError as exc:
        raise ValueError(f"Could not save image to {dest_dir!r}: {exc}") from exc
