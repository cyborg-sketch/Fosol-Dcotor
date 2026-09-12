from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.crop import Crop

router = APIRouter(prefix="/crops", tags=["crops"])


@router.get("")
def list_crops(db: Session = Depends(get_db)):
    """Lets the mobile app show a real crop picker instead of always diagnosing
    against the hardcoded /demo/context crop — a photo of any other crop was
    previously always forced through the demo crop's disease list.
    """
    crops = db.query(Crop).order_by(Crop.name_en).all()
    return [{"id": str(c.id), "name_en": c.name_en, "name_bn": c.name_bn} for c in crops]
