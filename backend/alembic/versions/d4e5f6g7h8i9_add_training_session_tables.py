"""add training session tables (training_sessions + training_messages + training_step_results)

Revision ID: d4e5f6g7h8i9
Revises: c3d4e5f6g7h8
Create Date: 2026-02-26 22:15:00.000000
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID, JSONB

revision: str = "d4e5f6g7h8i9"
down_revision: Union[str, None] = "c3d4e5f6g7h8"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # training_sessions 表
    op.create_table(
        "training_sessions",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("student_id", UUID(as_uuid=True), sa.ForeignKey("students.id"), nullable=False),
        sa.Column("model_id", sa.String(50), nullable=False),
        sa.Column("model_name", sa.String(100), nullable=True),
        sa.Column("status", sa.String(20), nullable=False, server_default="active"),
        sa.Column("current_step", sa.Integer(), nullable=False, server_default=sa.text("1")),
        sa.Column("entry_step", sa.Integer(), nullable=False, server_default=sa.text("1")),
        sa.Column("source", sa.String(30), nullable=False, server_default="self_study"),
        sa.Column("question_id", UUID(as_uuid=True), sa.ForeignKey("questions.id"), nullable=True),
        sa.Column("diagnosis_result", JSONB(), nullable=True),
        sa.Column("system_prompt", sa.Text(), nullable=True),
        sa.Column("mastery_snapshot", JSONB(), nullable=True),
        sa.Column("training_result", JSONB(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    op.create_index("idx_train_session_student", "training_sessions", ["student_id"])
    op.create_index("idx_train_session_model", "training_sessions", ["model_id"])

    # training_messages 表
    op.create_table(
        "training_messages",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column(
            "session_id",
            UUID(as_uuid=True),
            sa.ForeignKey("training_sessions.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("role", sa.String(10), nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("step", sa.SmallInteger(), nullable=False),
        sa.Column("token_count", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    op.create_index("idx_train_msg_session", "training_messages", ["session_id", "created_at"])

    # training_step_results 表
    op.create_table(
        "training_step_results",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column(
            "session_id",
            UUID(as_uuid=True),
            sa.ForeignKey("training_sessions.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("step", sa.SmallInteger(), nullable=False),
        sa.Column("passed", sa.Boolean(), nullable=False),
        sa.Column("ai_summary", sa.Text(), nullable=True),
        sa.Column("details", JSONB(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.UniqueConstraint("session_id", "step", name="uq_train_step_session_step"),
    )

    op.create_index("idx_train_step_session", "training_step_results", ["session_id"])


def downgrade() -> None:
    op.drop_index("idx_train_step_session", table_name="training_step_results")
    op.drop_table("training_step_results")

    op.drop_index("idx_train_msg_session", table_name="training_messages")
    op.drop_table("training_messages")

    op.drop_index("idx_train_session_model", table_name="training_sessions")
    op.drop_index("idx_train_session_student", table_name="training_sessions")
    op.drop_table("training_sessions")
