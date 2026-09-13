import uuid
from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel


class SymptomExtraction(BaseModel):
    crop: str
    symptoms: list[str]
    severity: Optional[str] = None
    duration: Optional[str] = None
    affected_area: Optional[str] = None


class DiagnosisCandidateOut(BaseModel):
    disease_id: uuid.UUID
    disease_name_bn: str
    confidence: float


class TreatmentOut(BaseModel):
    id: uuid.UUID
    action_bn: str
    category: Literal["organic", "low_chemical", "chemical"]
    safety_notes_bn: Optional[str] = None


class DiagnosisCreateRequest(BaseModel):
    farmer_id: uuid.UUID
    crop_id: Optional[uuid.UUID] = None
    image_ref: Optional[str] = None
    symptoms: Optional[SymptomExtraction] = None
    source: Literal["online", "offline"] = "online"


class DiagnosisResult(BaseModel):
    id: uuid.UUID
    status: Literal["AUTO_RESOLVED", "NEEDS_REVIEW", "VERIFIED"]
    confidence: float
    crop_id: Optional[uuid.UUID] = None
    crop_name_bn: Optional[str] = None
    image_ref: Optional[str] = None
    candidates: list[DiagnosisCandidateOut]
    treatments: list[TreatmentOut]
    created_at: datetime

    class Config:
        from_attributes = True
