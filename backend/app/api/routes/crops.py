from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.crop import Crop

router = APIRouter(prefix="/crops", tags=["crops"])


PRIORITY = {
    "Rice": 0,
    "Jute": 1,
    "Tomato": 2,
    "Brinjal (Eggplant)": 3,
    "Potato": 4,
    "Corn (Maize)": 5,
    "Bell Pepper": 6,
}


@router.get("")
def list_crops(db: Session = Depends(get_db)):
    """Lets the mobile app show a real crop picker instead of always diagnosing
    against the hardcoded /demo/context crop. Prioritizes primary Bangladeshi crops.
    """
    crops = db.query(Crop).all()
    crops.sort(key=lambda c: (PRIORITY.get(c.name_en, 99), c.name_en))
    return [{"id": str(c.id), "name_en": c.name_en, "name_bn": c.name_bn} for c in crops]
