"""ConfusionGroup — 表8"""
from datetime import datetime

from sqlalchemy import String, DateTime, func
from sqlalchemy.dialects.postgresql import ARRAY, TEXT, JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class ConfusionGroup(Base):
    __tablename__ = "confusion_groups"

    id: Mapped[str] = mapped_column(String(50), primary_key=True)
    model_ids: Mapped[list[str]] = mapped_column(ARRAY(TEXT), nullable=False)
    comparison_table: Mapped[dict | None] = mapped_column(JSONB)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
