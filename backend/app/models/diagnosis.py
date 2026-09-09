import uuid
from datetime import datetime

from sqlalchemy import DateTime, Enum, Float, ForeignKey, JSON, String, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base

DiagnosisStatus = Enum("AUTO_RESOLVED", "NEEDS_REVIEW", "VERIFIED", name="diagnosis_status")
DiagnosisSource = Enum("online", "offline", name="diagnosis_source")


class Diagnosis(Base):
    __tablename__ = "diagnoses"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    farmer_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("farmers.id"), nullable=False)
    crop_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("crops.id"), nullable=False)
    region_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("regions.id"), nullable=True)

    image_ref: Mapped[str] = mapped_column(String(500), nullable=True)
    symptoms_json: Mapped[dict] = mapped_column(JSON, nullable=True)
    confidence: Mapped[float] = mapped_column(Float, nullable=False)
    source: Mapped[str] = mapped_column(DiagnosisSource, default="online")
    model_version: Mapped[str] = mapped_column(String(40), nullable=True)
    status: Mapped[str] = mapped_column(DiagnosisStatus, default="AUTO_RESOLVED")

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class DiagnosisCandidate(Base):
    """Ranked disease candidates returned by the vision/NLP pipeline for one diagnosis."""

    __tablename__ = "diagnosis_candidates"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    diagnosis_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("diagnoses.id"), nullable=False)
    disease_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("diseases.id"), nullable=False)
    confidence: Mapped[float] = mapped_column(Float, nullable=False)
    rank: Mapped[int] = mapped_column(default=1)


class DiagnosisTreatment(Base):
    """Snapshot of the treatment(s) shown to the farmer for a given diagnosis."""

    __tablename__ = "diagnosis_treatments"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    diagnosis_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("diagnoses.id"), nullable=False)
    treatment_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("treatments.id"), nullable=False)
    rank: Mapped[int] = mapped_column(default=1)
