# Project Stack

This repository is set up as a practical full-stack starter.

## Frontend

- React
- TypeScript
- Vite
- ESLint
- Generated API types from FastAPI OpenAPI

Local commands:

```powershell
cd frontend
npm.cmd install
npm.cmd run generate:api
npm.cmd run lint
npm.cmd run build
npm.cmd run dev
```

## Backend

- FastAPI
- Pydantic settings
- SQLModel
- Alembic
- Live/readiness endpoints
- Pytest
- Ruff

Local commands:

```powershell
cd backend
python -m pip install -e ".[dev]"
python -m alembic upgrade head
python -m ruff check .
python -m pytest
python -m uvicorn app.main:app --reload
```

## Data Services

- PostgreSQL
- Redis
- Alembic migration state is checked by API readiness

Docker Compose is provided for local services and app containers:

```powershell
.\scripts\dev.ps1
.\scripts\migrate.ps1
.\scripts\test-integration.ps1 -KeepRunning
```

Docker is not required for CI checks, but it is the intended local integration path once Docker Desktop is installed.

## Dev Container

The `.devcontainer` setup installs Python, Node.js, Docker CLI access, backend dev dependencies, and frontend npm dependencies for a portable editor environment.

## API Contract

The runtime contracts are:

```text
GET /api/live
GET /api/ready
GET /api/health
```

The frontend uses readiness to confirm that the API, database, Redis, and migration state are healthy.

Refresh the local OpenAPI contract and generated TypeScript client after changing FastAPI routes or schemas:

```powershell
.\scripts\generate-api.ps1
```
