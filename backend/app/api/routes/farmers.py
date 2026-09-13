import uuid

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.crop import Crop
from app.models.farmer import Farmer

router = APIRouter(tags=["farmers"])


class FarmerCreateRequest(BaseModel):
    phone: str
    name: str | None = None
    language: str = "bn"


class FarmerOut(BaseModel):
    farmer_id: uuid.UUID
    phone: str
    name: str | None


@router.post("/farmers", response_model=FarmerOut)
def create_farmer(payload: FarmerCreateRequest, db: Session = Depends(get_db)):
    """Real farmer onboarding — no seeded/demo identity. Each device creates
    its own farmer record on first launch (see mobile/lib/core/identity.dart)
    and persists the returned id locally; every diagnosis after that is tied
    to this real record, not a pinned seed row.
    """
    existing = db.query(Farmer).filter(Farmer.phone == payload.phone).first()
    if existing:
        return FarmerOut(farmer_id=existing.id, phone=existing.phone, name=existing.name)

    farmer = Farmer(phone=payload.phone, name=payload.name, language=payload.language)
    db.add(farmer)
    db.commit()
    db.refresh(farmer)
    return FarmerOut(farmer_id=farmer.id, phone=farmer.phone, name=farmer.name)


class CropOut(BaseModel):
    id: uuid.UUID
    name_en: str
    name_bn: str


@router.get("/crops", response_model=list[CropOut])
def list_crops(db: Session = Depends(get_db)):
    crops = db.query(Crop).order_by(Crop.name_en).all()
    return [CropOut(id=c.id, name_en=c.name_en, name_bn=c.name_bn) for c in crops]
