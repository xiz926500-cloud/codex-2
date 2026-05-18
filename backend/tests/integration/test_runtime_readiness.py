import os

import httpx
import pytest

BASE_URL = os.getenv("INTEGRATION_BASE_URL")
pytestmark = pytest.mark.skipif(
    BASE_URL is None,
    reason="integration tests require INTEGRATION_BASE_URL",
)


def test_live_endpoint_is_available() -> None:
    response = httpx.get(f"{BASE_URL}/api/live", timeout=10)

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_ready_endpoint_reports_runtime_dependencies() -> None:
    response = httpx.get(f"{BASE_URL}/api/ready", timeout=10)

    assert response.status_code == 200
    payload = response.json()
    assert payload["status"] == "ok"
    assert payload["database"]["status"] == "ok"
    assert payload["redis"]["status"] == "ok"
    assert payload["migrations"]["status"] == "ok"
