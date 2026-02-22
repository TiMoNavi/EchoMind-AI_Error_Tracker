"""RegionalTemplate — 表6"""
from datetime import datetime

from sqlalchemy import String, Integer, DateTime, UniqueConstraint, func
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class RegionalTemplate(Base):
    __tablename__ = "regional_templates"

    id: Mapped[str] = mapped_column(String(50), primary_key=True)
    region_id: Mapped[str] = mapped_column(String(30), nullable=False)
    subject: Mapped[str] = mapped_column(String(20), nullable=False)
    target_score: Mapped[int] = mapped_column(Integer, nullable=False)
    total_score: Mapped[int] = mapped_column(Integer, nullable=False)

    exam_structure: Mapped[dict] = mapped_column(JSONB, nullable=False)
    question_strategies: Mapped[dict] = mapped_column(JSONB, nullable=False)
    diagnosis_path: Mapped[dict] = mapped_column(JSONB, nullable=False)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        UniqueConstraint("region_id", "subject", "target_score"),
    )
