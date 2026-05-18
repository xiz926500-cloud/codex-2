"""create project events

Revision ID: 202605180001
Revises:
Create Date: 2026-05-18 00:00:00.000000
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "202605180001"
down_revision: str | Sequence[str] | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "project_events",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("name", sa.String(length=120), nullable=False),
        sa.Column("status", sa.String(length=40), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_project_events_name", "project_events", ["name"], unique=False)
    op.create_index("ix_project_events_status", "project_events", ["status"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_project_events_status", table_name="project_events")
    op.drop_index("ix_project_events_name", table_name="project_events")
    op.drop_table("project_events")
