from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.diagnosis import Diagnosis, DiagnosisCandidate
from app.models.disease import Disease
from app.models.region import Region

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@router.get("/trends")
def trends(db: Session = Depends(get_db)):
    total = db.query(func.count(Diagnosis.id)).scalar()
    needs_review = db.query(func.count(Diagnosis.id)).filter(Diagnosis.status == "NEEDS_REVIEW").scalar()

    by_region_rows = (
        db.query(Region.district, func.count(Diagnosis.id))
        .join(Diagnosis, Diagnosis.region_id == Region.id)
        .group_by(Region.district)
        .all()
    )

    top_diseases_rows = (
        db.query(Disease.name_bn, func.count(DiagnosisCandidate.id))
        .join(DiagnosisCandidate, DiagnosisCandidate.disease_id == Disease.id)
        .filter(DiagnosisCandidate.rank == 1)
        .group_by(Disease.name_bn)
        .order_by(func.count(DiagnosisCandidate.id).desc())
        .limit(5)
        .all()
    )

    return {
        "total_diagnoses": total,
        "needs_review": needs_review,
        "by_region": [{"district": district, "count": count} for district, count in by_region_rows],
        "top_diseases": [{"disease_name_bn": name, "count": count} for name, count in top_diseases_rows],
    }
