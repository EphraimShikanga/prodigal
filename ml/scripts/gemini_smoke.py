"""Live Gemini smoke test (hits the real API — needs a key + network).

Not collected by pytest. Run it directly to confirm the Gemini backend can
detect a face, describe it, and produce a text embedding.

Setup (keeps your key out of source control):
    1. Create ml/.env with:
         ARGUS_ML_BACKEND=gemini
         ARGUS_GEMINI_API_KEY=your-key-here
    2. Run from the ml/ directory:
         .venv/Scripts/python.exe scripts/gemini_smoke.py path/to/face.jpg

It prints the detected faces, the structured description Gemini produced, and
the embedding dimensionality.
"""

from __future__ import annotations

import sys

from app.config import get_settings
from app.services.face_engine import load_engine
from app.services.imaging import decode_image


def main(path: str) -> int:
    settings = get_settings()
    engine = load_engine(settings)
    print(f"Active engine: {engine.name}")
    if engine.name != "gemini":
        print(
            "WARNING: the Gemini engine is not active. Set ARGUS_ML_BACKEND=gemini "
            "and provide an API key (ARGUS_GEMINI_API_KEY / GEMINI_API_KEY)."
        )

    with open(path, "rb") as fh:
        image = decode_image(fh.read())

    faces = engine.embed(image)
    print(f"Faces detected: {len(faces)}")
    for i, face in enumerate(faces):
        bbox = tuple(round(v, 1) for v in face.bbox)
        dim = len(face.embedding) if face.embedding is not None else None
        print(f"\nface[{i}]  det_score={face.det_score}  bbox={bbox}  embedding_dim={dim}")
        if face.attributes:
            for key, value in face.attributes.items():
                if value:
                    print(f"    {key}: {value}")
    return 0


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python scripts/gemini_smoke.py path/to/face.jpg")
        raise SystemExit(2)
    raise SystemExit(main(sys.argv[1]))
