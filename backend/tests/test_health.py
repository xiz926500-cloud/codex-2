from fastapi.testclient import TestClient

from app.main import app


def test_health_endpoint_returns_runtime_summary() -> None:
    client = TestClient(app)

    response = client.get("/api/health")

    assert response.status_code == 200
    payload = response.json()
    assert payload["status"] == "ok"
    assert payload["app"] == "codex-2 API"
    assert payload["database_configured"] is True
    assert payload["redis_configured"] is True
