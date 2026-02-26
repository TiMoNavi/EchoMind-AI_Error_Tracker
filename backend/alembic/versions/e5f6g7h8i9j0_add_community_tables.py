"""add community tables (feature_requests, votes, feedbacks)

Revision ID: e5f6g7h8i9j0
Revises: d4e5f6g7h8i9
Create Date: 2026-02-26 10:45:00.000000
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID

revision: str = "e5f6g7h8i9j0"
down_revision: Union[str, None] = "d4e5f6g7h8i9"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # feature_requests 表
    op.create_table(
        "feature_requests",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("title", sa.String(200), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("vote_count", sa.Integer(), nullable=False, server_default=sa.text("0")),
        sa.Column("tag", sa.String(50), nullable=True),
        sa.Column("student_id", UUID(as_uuid=True), sa.ForeignKey("students.id"), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("idx_fr_student", "feature_requests", ["student_id"])
    op.create_index("idx_fr_votes", "feature_requests", ["vote_count"])

    # votes 表
    op.create_table(
        "votes",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("student_id", UUID(as_uuid=True), sa.ForeignKey("students.id"), nullable=False),
        sa.Column("request_id", UUID(as_uuid=True), sa.ForeignKey("feature_requests.id", ondelete="CASCADE"), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.UniqueConstraint("student_id", "request_id", name="uq_vote_student_request"),
    )
    op.create_index("idx_vote_student", "votes", ["student_id"])
    op.create_index("idx_vote_request", "votes", ["request_id"])

    # feedbacks 表
    op.create_table(
        "feedbacks",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("feedback_type", sa.String(30), nullable=False),
        sa.Column("student_id", UUID(as_uuid=True), sa.ForeignKey("students.id"), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("idx_fb_student", "feedbacks", ["student_id"])


def downgrade() -> None:
    op.drop_index("idx_fb_student", table_name="feedbacks")
    op.drop_table("feedbacks")

    op.drop_index("idx_vote_request", table_name="votes")
    op.drop_index("idx_vote_student", table_name="votes")
    op.drop_table("votes")

    op.drop_index("idx_fr_votes", table_name="feature_requests")
    op.drop_index("idx_fr_student", table_name="feature_requests")
    op.drop_table("feature_requests")
