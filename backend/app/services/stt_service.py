from app.core.config import settings


class SttServiceUnavailable(Exception):
    pass


async def transcribe_bangla(audio_bytes: bytes) -> str:
    """Adapter around the managed Bangla STT API. Kept behind this function so the
    provider can be swapped later without touching the voice-input flow.
    """
    if not settings.stt_api_key:
        raise SttServiceUnavailable("STT_API_KEY is not configured")
    raise NotImplementedError("Wire up the chosen Bangla STT provider here")
