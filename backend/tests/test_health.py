from fastapi.testclient import TestClient

from app.main import app
from app.schemas import DependencyCheck, ReadyResponse


def test_health_endpoint_returns_runtime_summary() -> None:
    client = TestClient(app)

    response = client.get("/api/health")

    assert response.status_code == 200
    payload = response.json()
    assert payload["status"] == "ok"
    assert payload["app"] == "codex-2 API"
    assert payload["database_configured"] is True
    assert payload["redis_configured"] is True


def test_live_endpoint_returns_process_status() -> None:
    client = TestClient(app)

    response = client.get("/api/live")

    assert response.status_code == 200
    payload = response.json()
    assert payload["status"] == "ok"
    assert payload["app"] == "codex-2 API"


def test_ready_endpoint_returns_ok_when_dependencies_pass(monkeypatch) -> None:
    async def fake_readiness(settings) -> ReadyResponse:  # noqa: ANN001
        return ReadyResponse(
            status="ok",
            app=settings.app_name,
            version=settings.version,
            environment=settings.environment,
            database=DependencyCheck(status="ok", detail="database connection ok"),
            redis=DependencyCheck(status="ok", detail="redis ping ok"),
            migrations=DependencyCheck(status="ok", detail="database schema at head"),
        )

    monkeypatch.setattr("app.main.get_readiness", fake_readiness)
    client = TestClient(app)

    response = client.get("/api/ready")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_ready_endpoint_returns_503_when_dependency_fails(monkeypatch) -> None:
    async def fake_readiness(settings) -> ReadyResponse:  # noqa: ANN001
        return ReadyResponse(
            status="error",
            app=settings.app_name,
            version=settings.version,
            environment=settings.environment,
            database=DependencyCheck(status="error", detail="database check failed"),
            redis=DependencyCheck(status="ok", detail="redis ping ok"),
            migrations=DependencyCheck(status="error", detail="migration check failed"),
        )

    monkeypatch.setattr("app.main.get_readiness", fake_readiness)
    client = TestClient(app)

    response = client.get("/api/ready")

    assert response.status_code == 503
    assert response.json()["database"]["status"] == "error"
