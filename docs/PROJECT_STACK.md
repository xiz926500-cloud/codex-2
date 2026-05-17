# Project Stack

This repository is set up as a practical full-stack starter.

## Frontend

- React
- TypeScript
- Vite
- ESLint

Local commands:

```powershell
cd frontend
npm.cmd install
npm.cmd run lint
npm.cmd run build
npm.cmd run dev
```

## Backend

- FastAPI
- Pydantic settings
- Pytest
- Ruff

Local commands:

```powershell
cd backend
python -m pip install -e ".[dev]"
python -m ruff check .
python -m pytest
python -m uvicorn app.main:app --reload
```

## Data Services

- PostgreSQL
- Redis

Docker Compose is provided for local services and app containers:

```powershell
docker compose up --build
```

Docker is not required for CI checks, but it is the intended local integration path once Docker Desktop is installed.

## API Contract

The first contract is the health endpoint:

```text
GET /api/health
```

The frontend uses this endpoint to confirm that the API is reachable and that database/cache configuration is present.
