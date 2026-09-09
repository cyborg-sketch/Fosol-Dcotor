import uuid

from sqlalchemy import ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Disease(Base):
    __tablename__ = "diseases"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    crop_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("crops.id"), nullable=False)
    name_en: Mapped[str] = mapped_column(String(120), nullable=False)
    name_bn: Mapped[str] = mapped_column(String(120), nullable=False)
    description_bn: Mapped[str] = mapped_column(Text, nullable=True)
