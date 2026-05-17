# codex-2

Initialized by Codex on 2026-05-11.

## Stack

- Frontend: React, TypeScript, Vite
- Backend: FastAPI, Pytest, Ruff
- Data services: PostgreSQL and Redis
- Delivery: GitHub Actions, branch protection, Dependabot, CodeQL, Dependency Review

## Codex Workflow

- Project stack: [`docs/PROJECT_STACK.md`](docs/PROJECT_STACK.md)
- Workflow guide: [`docs/CODEX_WORKFLOW.md`](docs/CODEX_WORKFLOW.md)
- Engineering standards: [`docs/ENGINEERING_STANDARDS.md`](docs/ENGINEERING_STANDARDS.md)
- Delivery checklist: [`docs/DELIVERY_CHECKLIST.md`](docs/DELIVERY_CHECKLIST.md)
- Security baseline: [`docs/SECURITY_BASELINE.md`](docs/SECURITY_BASELINE.md)
- Security policy: [`SECURITY.md`](SECURITY.md)
- Agent instructions: [`AGENTS.md`](AGENTS.md)
- Quick local check: `.\scripts\codex-check.ps1`
- CI entrypoint: [`.github/workflows/ci.yml`](.github/workflows/ci.yml)

## Local Development

Backend:

```powershell
cd backend
python -m pip install -e ".[dev]"
python -m uvicorn app.main:app --reload
```

Frontend:

```powershell
cd frontend
npm.cmd install
npm.cmd run dev
```

Full local stack after Docker Desktop is installed:

```powershell
docker compose up --build
```
