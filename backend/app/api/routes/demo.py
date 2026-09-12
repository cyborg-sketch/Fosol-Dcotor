from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.crop import Crop
from app.models.farmer import Farmer

router = APIRouter(prefix="/demo", tags=["demo"])


@router.get("/context")
def demo_context(db: Session = Depends(get_db)):
    """Returns a default farmer_id/crop_id so the mobile app can call
    POST /diagnoses without a real login/crop-selection flow yet. Only for
    the hackathon demo — remove once onboarding actually persists a farmer
    and their selected crop.
    """
    farmer = db.query(Farmer).order_by(Farmer.created_at).first()
    # Pinned to Tomato, not just "first crop" by id (UUIDs sort randomly) —
    # Tomato has the richest seeded disease set (6 classes) of the 9 crops in
    # scripts/seed_demo.py, giving the best demo depth for this hardcoded pick.
    crop = db.query(Crop).filter(Crop.name_en == "Tomato").first()
    if not farmer or not crop:
        raise HTTPException(status_code=404, detail="No seed data — run scripts/seed_demo.py first")
    return {
        "farmer_id": str(farmer.id),
        "farmer_name": farmer.name,
        "crop_id": str(crop.id),
        "crop_name_bn": crop.name_bn,
    }
