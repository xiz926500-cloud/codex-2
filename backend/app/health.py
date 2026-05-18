from pathlib import Path

from alembic.config import Config
from alembic.script import ScriptDirectory
from redis.asyncio import Redis
from sqlalchemy import text

from app.database import create_database_engine
from app.schemas import DependencyCheck, ReadyResponse
from app.settings import Settings


def _ok(detail: str) -> DependencyCheck:
    return DependencyCheck(status="ok", detail=detail)


def _error(detail: str) -> DependencyCheck:
    return DependencyCheck(status="error", detail=detail)


def _alembic_heads() -> set[str]:
    project_root = Path(__file__).resolve().parents[1]
    config = Config(str(project_root / "alembic.ini"))
    return set(ScriptDirectory.from_config(config).get_heads())


async def check_database(settings: Settings) -> DependencyCheck:
    engine = create_database_engine(settings.database_url)
    try:
        async with engine.connect() as connection:
            await connection.execute(text("SELECT 1"))
    except Exception as exc:
        return _error(f"database check failed: {type(exc).__name__}")
    finally:
        await engine.dispose()

    return _ok("database connection ok")


async def check_migrations(settings: Settings) -> DependencyCheck:
    engine = create_database_engine(settings.database_url)
    expected_heads = _alembic_heads()
    try:
        async with engine.connect() as connection:
            result = await connection.execute(text("SELECT version_num FROM alembic_version"))
            current_versions = {row[0] for row in result.all()}
    except Exception as exc:
        return _error(f"migration check failed: {type(exc).__name__}")
    finally:
        await engine.dispose()

    if current_versions == expected_heads:
        return _ok(f"database schema at head: {', '.join(sorted(expected_heads))}")

    current = ", ".join(sorted(current_versions)) if current_versions else "none"
    expected = ", ".join(sorted(expected_heads)) if expected_heads else "none"
    return _error(f"database schema mismatch: current={current}; expected={expected}")


async def check_redis(settings: Settings) -> DependencyCheck:
    client = Redis.from_url(settings.redis_url, socket_connect_timeout=2, socket_timeout=2)
    try:
        await client.ping()
    except Exception as exc:
        return _error(f"redis check failed: {type(exc).__name__}")
    finally:
        await client.aclose()

    return _ok("redis ping ok")


async def get_readiness(settings: Settings) -> ReadyResponse:
    database = await check_database(settings)
    redis = await check_redis(settings)
    migrations = await check_migrations(settings)
    status = "ok" if all(
        check.status == "ok" for check in (database, redis, migrations)
    ) else "error"

    return ReadyResponse(
        status=status,
        app=settings.app_name,
        version=settings.version,
        environment=settings.environment,
        database=database,
        redis=redis,
        migrations=migrations,
    )
