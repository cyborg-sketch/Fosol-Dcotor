import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.crop import Crop
from app.models.diagnosis import Diagnosis, DiagnosisCandidate
from app.models.disease import Disease
from app.models.expert_review import ExpertReview
from app.models.farmer import Farmer

router = APIRouter(prefix="/field-worker", tags=["field-worker"])


class QueueItem(BaseModel):
    diagnosis_id: uuid.UUID
    farmer_name: str
    farmer_phone: str
    crop_name_bn: str
    top_disease_name_bn: str | None
    confidence: float
    created_at: datetime


@router.get("/queue", response_model=list[QueueItem])
def pending_queue(db: Session = Depends(get_db)):
    diagnoses = (
        db.query(Diagnosis)
        .filter(Diagnosis.status == "NEEDS_REVIEW")
        .order_by(Diagnosis.created_at)
        .all()
    )
    items = []
    for d in diagnoses:
        farmer = db.get(Farmer, d.farmer_id)
        crop = db.get(Crop, d.crop_id)
        top_candidate = (
            db.query(DiagnosisCandidate)
            .filter_by(diagnosis_id=d.id)
            .order_by(DiagnosisCandidate.rank)
            .first()
        )
        top_disease = db.get(Disease, top_candidate.disease_id) if top_candidate else None
        items.append(
            QueueItem(
                diagnosis_id=d.id,
                farmer_name=farmer.name or farmer.phone,
                farmer_phone=farmer.phone,
                crop_name_bn=crop.name_bn,
                top_disease_name_bn=top_disease.name_bn if top_disease else None,
                confidence=d.confidence,
                created_at=d.created_at,
            )
        )
    return items


class ResolveRequest(BaseModel):
    notes_bn: str


@router.post("/reviews/{diagnosis_id}/resolve")
def resolve_review(diagnosis_id: uuid.UUID, payload: ResolveRequest, db: Session = Depends(get_db)):
    diagnosis = db.get(Diagnosis, diagnosis_id)
    if not diagnosis:
        raise HTTPException(status_code=404, detail="Diagnosis not found")

    review = ExpertReview(
        diagnosis_id=diagnosis.id,
        status="APPROVED",
        verified_notes_bn=payload.notes_bn,
        resolved_at=datetime.now(timezone.utc),
    )
    diagnosis.status = "VERIFIED"
    db.add(review)
    db.commit()
    return {"diagnosis_id": diagnosis.id, "status": diagnosis.status}
