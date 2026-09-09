import uuid

from sqlalchemy import ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Symptom(Base):
    __tablename__ = "symptoms"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    disease_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("diseases.id"), nullable=False)
    label_bn: Mapped[str] = mapped_column(String(200), nullable=False)
