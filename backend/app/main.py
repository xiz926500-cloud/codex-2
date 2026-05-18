from fastapi import FastAPI, Response
from fastapi.middleware.cors import CORSMiddleware

from app.health import get_readiness
from app.schemas import HealthResponse, LiveResponse, ReadyResponse
from app.settings import get_settings

settings = get_settings()

app = FastAPI(title=settings.app_name, version=settings.version)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/api/live", response_model=LiveResponse)
def live() -> LiveResponse:
    return LiveResponse(
        status="ok",
        app=settings.app_name,
        version=settings.version,
        environment=settings.environment,
    )


@app.get(
    "/api/ready",
    response_model=ReadyResponse,
    responses={503: {"model": ReadyResponse, "description": "Runtime dependencies unavailable"}},
)
async def ready(response: Response) -> ReadyResponse:
    readiness = await get_readiness(settings)
    if readiness.status != "ok":
        response.status_code = 503

    return readiness


@app.get("/api/health", response_model=HealthResponse)
def health() -> HealthResponse:
    return HealthResponse(
        status="ok",
        app=settings.app_name,
        version=settings.version,
        environment=settings.environment,
        database_configured=bool(settings.database_url),
        redis_configured=bool(settings.redis_url),
    )
