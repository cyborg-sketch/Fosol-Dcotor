import uuid
from datetime import datetime

from sqlalchemy import DateTime, Enum, ForeignKey, Integer, String, Text, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base

TreatmentCategory = Enum("organic", "low_chemical", "chemical", name="treatment_category")


class Treatment(Base):
    __tablename__ = "treatments"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    disease_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("diseases.id"), nullable=False)
    action_bn: Mapped[str] = mapped_column(Text, nullable=False)
    category: Mapped[str] = mapped_column(TreatmentCategory, nullable=False)
    cost_level: Mapped[int] = mapped_column(Integer, default=1)  # 1=low .. 3=high
    effectiveness_rating: Mapped[int] = mapped_column(Integer, default=3)  # 1..5
    safety_notes_bn: Mapped[str] = mapped_column(Text, nullable=True)
    availability_notes_bn: Mapped[str] = mapped_column(Text, nullable=True)
    approved: Mapped[bool] = mapped_column(default=False)
    version: Mapped[str] = mapped_column(String(20), default="v1")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
