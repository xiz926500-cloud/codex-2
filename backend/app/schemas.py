from typing import Literal

from pydantic import BaseModel


class LiveResponse(BaseModel):
    status: Literal["ok"]
    app: str
    version: str
    environment: str


class HealthResponse(BaseModel):
    status: str
    app: str
    version: str
    environment: str
    database_configured: bool
    redis_configured: bool


class DependencyCheck(BaseModel):
    status: Literal["ok", "error"]
    detail: str


class ReadyResponse(BaseModel):
    status: Literal["ok", "error"]
    app: str
    version: str
    environment: str
    database: DependencyCheck
    redis: DependencyCheck
    migrations: DependencyCheck
