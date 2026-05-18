from datetime import UTC, datetime

from sqlmodel import Field, SQLModel


def utc_now() -> datetime:
    return datetime.now(UTC)


class ProjectEvent(SQLModel, table=True):
    __tablename__ = "project_events"

    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(max_length=120, index=True)
    status: str = Field(default="planned", max_length=40, index=True)
    created_at: datetime = Field(default_factory=utc_now, nullable=False)
