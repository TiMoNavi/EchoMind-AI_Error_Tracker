"""add diagnosis session tables + widen questions.source

Revision ID: a1b2c3d4e5f6
Revises: 2368aa6ef27a
Create Date: 2026-02-25 07:10:00.000000
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID, JSONB

revision: str = "a1b2c3d4e5f6"
down_revision: Union[str, None] = "2368aa6ef27a"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # diagnosis_sessions 表
    op.create_table(
        "diagnosis_sessions",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("student_id", UUID(as_uuid=True), sa.ForeignKey("students.id"), nullable=False),
        sa.Column("question_id", UUID(as_uuid=True), sa.ForeignKey("questions.id"), nullable=False),
        sa.Column("status", sa.String(20), nullable=False, server_default="active"),
        sa.Column("current_round", sa.SmallInteger(), nullable=False, server_default=sa.text("0")),
        sa.Column("max_rounds", sa.SmallInteger(), nullable=False, server_default=sa.text("5")),
        sa.Column("system_prompt", sa.Text(), nullable=True),
        sa.Column("diagnosis_result", JSONB(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    op.create_index("idx_diag_session_student", "diagnosis_sessions", ["student_id"])
    op.create_index("idx_diag_session_question", "diagnosis_sessions", ["question_id"])
    op.create_index(
        "idx_diag_session_active",
        "diagnosis_sessions",
        ["student_id", "question_id"],
        unique=True,
        postgresql_where=sa.text("status = 'active'"),
    )

    # diagnosis_messages 表
    op.create_table(
        "diagnosis_messages",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column(
            "session_id",
            UUID(as_uuid=True),
            sa.ForeignKey("diagnosis_sessions.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("role", sa.String(10), nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("round", sa.SmallInteger(), nullable=False),
        sa.Column("token_count", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    op.create_index("idx_diag_msg_session", "diagnosis_messages", ["session_id", "created_at"])

    # questions.source: VARCHAR(20) → VARCHAR(200)
    op.alter_column("questions", "source", type_=sa.String(200), existing_type=sa.String(20))


def downgrade() -> None:
    # 回缩 questions.source
    op.alter_column("questions", "source", type_=sa.String(20), existing_type=sa.String(200))

    op.drop_index("idx_diag_msg_session", table_name="diagnosis_messages")
    op.drop_table("diagnosis_messages")

    op.drop_index("idx_diag_session_active", table_name="diagnosis_sessions")
    op.drop_index("idx_diag_session_question", table_name="diagnosis_sessions")
    op.drop_index("idx_diag_session_student", table_name="diagnosis_sessions")
    op.drop_table("diagnosis_sessions")
