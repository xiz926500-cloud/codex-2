from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine
from sqlmodel import SQLModel

from app import models as models  # noqa: F401
from app.settings import get_settings

metadata = SQLModel.metadata


def create_database_engine(database_url: str | None = None) -> AsyncEngine:
    return create_async_engine(database_url or get_settings().database_url, pool_pre_ping=True)
