"""Gemini-backed natural-language summaries for image-verification results.

This module turns the structured ``results`` dict produced by the image
verifier into a short, human-readable summary.  It uses the Google Gemini API
when a key is configured, but ALWAYS degrades gracefully: on any failure or
missing key it returns a deterministic template summary built locally.

The ``google-genai`` SDK is imported lazily (mirroring
``app.services.face_engine``) so the base install never requires it, and the
service works fully offline.
"""

from __future__ import annotations

import logging
import os

logger = logging.getLogger(__name__)


def _resolve_gemini_api_key(api_key: str | None = None) -> str | None:
    """Resolve a Gemini API key from the argument or common env vars."""
    return (
        api_key
        or os.environ.get("GEMINI_API_KEY")
        or os.environ.get("GOOGLE_API_KEY")
    )


class GeminiSummaryService:
    """Produce natural-language summaries of image-verification results.

    The service is constructed cheaply and never touches the network at import
    or construction time.  A Gemini client is created lazily on first use, and
    every code path falls back to :meth:`_fallback_summary` rather than raising.

    Args:
        api_key: Explicit Gemini API key; falls back to ``GEMINI_API_KEY`` /
            ``GOOGLE_API_KEY`` environment variables.
        model: Gemini text model used for generation.
        client: Optional pre-built ``google.genai.Client`` (mainly for tests).
    """

    def __init__(
        self,
        api_key: str | None = None,
        model: str = "gemini-2.5-flash",
        client=None,
    ) -> None:
        self._model = model
        self._api_key = _resolve_gemini_api_key(api_key)
        self._client = client

    def _get_client(self):
        """Lazily build (and cache) the Gemini client, or return ``None``."""
        if self._client is not None:
            return self._client
        if not self._api_key:
            return None
        try:
            from google import genai  # lazy import

            self._client = genai.Client(api_key=self._api_key)
            return self._client
        except Exception as exc:  # pragma: no cover - depends on optional deps
            logger.warning("Could not initialise Gemini client (%s).", exc)
            return None

    @staticmethod
    def _build_prompt(results: dict) -> str:
        """Build a text prompt describing the verification results."""
        faces_detected = results.get("faces_detected", 0)
        known_faces = results.get("known_faces") or []
        unknown_faces = results.get("unknown_faces", 0)
        duplicate_image = results.get("duplicate_image", False)
        duplicate_probability = results.get("duplicate_probability", 0.0)
        matches = results.get("matches") or []

        known_desc = (
            ", ".join(
                f"{f.get('name', 'unknown')} ({f.get('confidence', 0)}%)"
                for f in known_faces
            )
            or "none"
        )
        match_desc = (
            ", ".join(
                f"{m.get('person', 'unknown')} ({m.get('similarity', 0)}%)"
                for m in matches
            )
            or "none"
        )

        return (
            "You are an image-verification assistant. Write a concise, friendly "
            "1-3 sentence natural-language summary of the following face/image "
            "verification result. Do not use markdown or bullet points.\n\n"
            f"- Faces detected: {faces_detected}\n"
            f"- Known (recognised) faces: {known_desc}\n"
            f"- Unknown faces: {unknown_faces}\n"
            f"- Matched persons: {match_desc}\n"
            f"- Duplicate of an existing image: {duplicate_image}\n"
            f"- Duplicate probability: {duplicate_probability}%\n"
        )

    def summarize(self, results: dict) -> str:
        """Summarise ``results`` in natural language.

        Attempts a Gemini text generation call; on any error or missing key it
        returns :meth:`_fallback_summary`.  This method never raises.

        Args:
            results: The structured verification result dict.

        Returns:
            A human-readable summary string (never empty).
        """
        client = self._get_client()
        if client is None:
            return self._fallback_summary(results)

        try:
            from google.genai import types  # lazy import

            response = client.models.generate_content(
                model=self._model,
                contents=self._build_prompt(results),
                config=types.GenerateContentConfig(temperature=0.2),
            )
            text = (getattr(response, "text", None) or "").strip()
            if text:
                return text
            logger.warning("Gemini returned an empty summary; using fallback.")
        except Exception as exc:  # pragma: no cover - depends on optional deps
            logger.warning("Gemini summary generation failed (%s); using fallback.", exc)
        return self._fallback_summary(results)

    @staticmethod
    def _fallback_summary(results: dict) -> str:
        """Build a deterministic summary without any external dependency.

        This never raises and needs no API key. ``results`` may be partial; all
        lookups are defensive.
        """
        try:
            faces_detected = int(results.get("faces_detected", 0) or 0)
        except (TypeError, ValueError):
            faces_detected = 0

        known_faces = results.get("known_faces") or []
        try:
            unknown_faces = int(results.get("unknown_faces", 0) or 0)
        except (TypeError, ValueError):
            unknown_faces = 0
        duplicate_image = bool(results.get("duplicate_image", False))
        duplicate_probability = results.get("duplicate_probability", 0.0)

        sentences: list[str] = []

        if faces_detected == 0:
            sentences.append("No faces were detected in the image.")
        elif faces_detected == 1:
            sentences.append("1 face was detected in the image.")
        else:
            sentences.append(f"{faces_detected} faces were detected in the image.")

        named = [str(f.get("name")) for f in known_faces if f.get("name")]
        if named:
            if len(named) == 1:
                sentences.append(f"It matches a known person: {named[0]}.")
            else:
                sentences.append("It matches known people: " + ", ".join(named) + ".")
        elif faces_detected:
            sentences.append("No known person was recognised.")

        if unknown_faces:
            label = "unrecognised face" if unknown_faces == 1 else "unrecognised faces"
            sentences.append(f"There {'is' if unknown_faces == 1 else 'are'} {unknown_faces} {label}.")

        if duplicate_image:
            sentences.append(
                f"This image appears to be a duplicate of an existing image "
                f"(probability {duplicate_probability}%)."
            )
        else:
            sentences.append("No duplicate of this image was found in the database.")

        return " ".join(sentences)


def load_gemini_summary(settings) -> GeminiSummaryService:
    """Construct a :class:`GeminiSummaryService` from ``settings``.

    Resolves the API key from ``settings.gemini_api_key`` (falling back to env
    vars inside the service) and the model from ``settings.gemini_summary_model``
    when present, otherwise a sensible default.
    """
    api_key = getattr(settings, "gemini_api_key", None)
    model = getattr(settings, "gemini_summary_model", None) or "gemini-2.5-flash"
    return GeminiSummaryService(api_key=api_key, model=model)
