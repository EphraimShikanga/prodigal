"""Unit tests for the Gemini face engine using an injected fake client.

These run fully offline (no API key, no network): we inject a stand-in client
whose ``models.generate_content`` / ``models.embed_content`` return canned data,
exercising the engine's parsing, bbox de-normalisation and embedding wiring.
"""

from __future__ import annotations

import numpy as np

from app.services.face_engine import GeminiFaceEngine

VISION_JSON = (
    '{"faces":[{"box_2d":[100,200,800,700],"confidence":0.95,'
    '"description":{"apparent_age_range":"6-9","sex_presentation":"female",'
    '"skin_tone":"brown","hair":"short black","facial_features":"round face",'
    '"clothing":"red school uniform","accessories":"none",'
    '"distinguishing_marks":"small scar on chin"}}]}'
)


class _FakeEmbedding:
    def __init__(self, values):
        self.values = values


class _FakeEmbedResult:
    def __init__(self, values):
        self.embeddings = [_FakeEmbedding(values)]


class _FakeResponse:
    def __init__(self, text):
        self.text = text


class _FakeModels:
    def __init__(self, vision_json, embed_values):
        self._vision_json = vision_json
        self._embed_values = embed_values
        self.embed_calls = []

    def generate_content(self, model, contents, config=None):
        return _FakeResponse(self._vision_json)

    def embed_content(self, model, contents, config=None):
        self.embed_calls.append(contents)
        return _FakeEmbedResult(self._embed_values)


class _FakeClient:
    def __init__(self, vision_json, embed_values):
        self.models = _FakeModels(vision_json, embed_values)


def _image() -> np.ndarray:
    return np.zeros((100, 100, 3), dtype=np.uint8)


def test_gemini_detect_parses_box_and_description():
    client = _FakeClient(VISION_JSON, [0.1] * 512)
    engine = GeminiFaceEngine(embedding_dim=512, client=client)

    faces = engine.detect(_image())

    assert len(faces) == 1
    face = faces[0]
    # box_2d [ymin=100, xmin=200, ymax=800, xmax=700] on a 100x100 image ->
    # x1=20, y1=10, x2=70, y2=80 (normalised 0-1000 -> pixels).
    assert round(face.bbox[0]) == 20
    assert round(face.bbox[1]) == 10
    assert round(face.bbox[2]) == 70
    assert round(face.bbox[3]) == 80
    assert face.det_score == 0.95
    assert face.attributes["distinguishing_marks"] == "small scar on chin"


def test_gemini_embed_returns_normalised_vector_from_description():
    client = _FakeClient(VISION_JSON, list(np.linspace(0.0, 1.0, 512)))
    engine = GeminiFaceEngine(embedding_dim=512, client=client)

    faces = engine.embed(_image())

    assert len(faces) == 1
    emb = faces[0].embedding
    assert emb is not None
    assert len(emb) == 512
    # Embeddings are L2-normalised for cosine matching.
    assert abs(float(np.linalg.norm(emb)) - 1.0) < 1e-6
    # The description text (not the image) is what gets embedded.
    assert "red school uniform" in client.models.embed_calls[0]


def test_gemini_handles_no_faces():
    client = _FakeClient('{"faces": []}', [0.0] * 512)
    engine = GeminiFaceEngine(embedding_dim=512, client=client)

    assert engine.detect(_image()) == []
    assert engine.embed(_image()) == []
