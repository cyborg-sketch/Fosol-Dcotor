import uuid
from datetime import datetime

from sqlalchemy import DateTime, Enum, ForeignKey, Text, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base

ReviewStatus = Enum("PENDING", "APPROVED", "EDITED", name="review_status")


class ExpertReview(Base):
    __tablename__ = "expert_reviews"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    diagnosis_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("diagnoses.id"), nullable=False)
    field_worker_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("field_workers.id"), nullable=True)
    status: Mapped[str] = mapped_column(ReviewStatus, default="PENDING")
    verified_notes_bn: Mapped[str] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    resolved_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=True)
