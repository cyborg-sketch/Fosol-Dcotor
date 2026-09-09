from app.core.config import settings


def resolve_status(top_confidence: float) -> str:
    """Deterministic escalation rule: never let the model claim certainty it doesn't have.

    Kept in its own function (not inlined at call sites) because the threshold and the
    reason string must always travel together for the farmer-facing escalation copy.
    """
    if top_confidence >= settings.confidence_auto_threshold:
        return "AUTO_RESOLVED"
    return "NEEDS_REVIEW"


def escalation_reason_bn(top_confidence: float) -> str | None:
    if top_confidence >= settings.confidence_auto_threshold:
        return None
    return "নিশ্চিতভাবে রোগটি শনাক্ত করা যায়নি"
