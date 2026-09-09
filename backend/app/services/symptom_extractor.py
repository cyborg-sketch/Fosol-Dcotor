"""Real (not mocked) Bangla symptom-to-disease matcher.

Approach: BanglaBERT (csebuetnlp/banglabert) embeds the farmer's transcribed
Bangla description and each candidate disease's stored description_bn, then
ranks diseases by cosine similarity. This is retrieval/semantic-search, not a
trained classifier — it needs no labeled training data, which fits a
hackathon timeline, but its accuracy is bounded by how well each disease's
description_bn actually describes distinguishing symptoms. Speech-to-text
itself happens on-device in the Flutter app (speech_to_text package) before
the transcript ever reaches this service.
"""

import asyncio

import torch
from transformers import AutoModel, AutoTokenizer

MODEL_NAME = "csebuetnlp/banglabert"
_TEMPERATURE = 0.1

_tokenizer = None
_model = None
_lock = asyncio.Lock()


def _load_model():
    global _tokenizer, _model
    if _model is None:
        _tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
        _model = AutoModel.from_pretrained(MODEL_NAME)
        _model.eval()
    return _tokenizer, _model


def _mean_pooled_embedding(text: str) -> torch.Tensor:
    tokenizer, model = _load_model()
    inputs = tokenizer(text, return_tensors="pt", truncation=True, max_length=128)
    with torch.no_grad():
        output = model(**inputs)
    token_embeddings = output.last_hidden_state.squeeze(0)  # (seq_len, hidden)
    mask = inputs["attention_mask"].squeeze(0).unsqueeze(-1)  # (seq_len, 1)
    pooled = (token_embeddings * mask).sum(dim=0) / mask.sum()
    return pooled / pooled.norm()


def _match_sync(transcript: str, candidates: list[dict]) -> list[dict]:
    """candidates: [{"disease_id": ..., "description_bn": ...}, ...]"""
    transcript_embedding = _mean_pooled_embedding(transcript)
    similarities = []
    for candidate in candidates:
        description = candidate.get("description_bn") or ""
        description_embedding = _mean_pooled_embedding(description) if description else torch.zeros_like(transcript_embedding)
        similarity = torch.dot(transcript_embedding, description_embedding).item()
        similarities.append((candidate["disease_id"], similarity))

    logits = torch.tensor([s for _, s in similarities]) / _TEMPERATURE
    probs = torch.softmax(logits, dim=0).tolist()

    ranked = sorted(zip([d for d, _ in similarities], probs), key=lambda pair: pair[1], reverse=True)
    return [{"disease_id": disease_id, "confidence": confidence} for disease_id, confidence in ranked]


async def match_symptoms(transcript: str, candidates: list[dict]) -> list[dict]:
    """Returns candidates ranked by confidence: [{"disease_id": ..., "confidence": 0.7}, ...]."""
    async with _lock:
        return await asyncio.to_thread(_match_sync, transcript, candidates)
