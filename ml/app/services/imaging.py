"""Image decoding helpers for the ARGUS-KE ML service."""

from __future__ import annotations

import base64
import io

import numpy as np
from PIL import Image, UnidentifiedImageError


def decode_image(data: bytes) -> np.ndarray:
    """Decode raw image bytes into an RGB ``uint8`` array of shape ``HxWx3``.

    Args:
        data: Raw encoded image bytes (PNG, JPEG, etc.).

    Returns:
        A NumPy array of shape ``(H, W, 3)`` and dtype ``uint8`` in RGB order.

    Raises:
        ValueError: If the bytes cannot be decoded as an image.
    """
    try:
        with Image.open(io.BytesIO(data)) as img:
            rgb = img.convert("RGB")
            return np.asarray(rgb, dtype=np.uint8)
    except (UnidentifiedImageError, OSError, ValueError) as exc:
        raise ValueError(f"Could not decode image: {exc}") from exc


def decode_b64_image(b64: str) -> np.ndarray:
    """Decode a (optionally data-URL-prefixed) base64 string into an RGB array.

    Args:
        b64: Base64-encoded image, optionally prefixed with a ``data:`` URL header.

    Returns:
        A NumPy array of shape ``(H, W, 3)`` and dtype ``uint8`` in RGB order.

    Raises:
        ValueError: If the string is not valid base64 or not a valid image.
    """
    payload = b64.strip()
    if payload.startswith("data:"):
        # Strip the "data:<mime>;base64," prefix.
        _, _, payload = payload.partition(",")

    try:
        raw = base64.b64decode(payload, validate=False)
    except (ValueError, base64.binascii.Error) as exc:
        raise ValueError(f"Invalid base64 image data: {exc}") from exc

    return decode_image(raw)
