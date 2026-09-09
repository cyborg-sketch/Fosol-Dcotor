from sqlalchemy.orm import Session

from app.models.treatment import Treatment

CATEGORY_ORDER = {"organic": 0, "low_chemical": 1, "chemical": 2}


def rank_treatments(db: Session, disease_id, limit: int = 3) -> list[Treatment]:
    """Rank approved treatments deterministically: prefer organic/low-chemical first,
    then higher effectiveness rating. Never LLM-ranked and never unapproved records —
    the LLM's only job downstream is translating this exact list into simple Bangla.
    """
    treatments = (
        db.query(Treatment)
        .filter(Treatment.disease_id == disease_id, Treatment.approved.is_(True))
        .all()
    )
    treatments.sort(key=lambda t: (CATEGORY_ORDER.get(t.category, 9), -t.effectiveness_rating))
    return treatments[:limit]
