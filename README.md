# codex-2

Initialized by Codex on 2026-05-11.

## Stack

- Frontend: React, TypeScript, Vite
- Backend: FastAPI, SQLModel, Alembic, Pytest, Ruff
- Data services: PostgreSQL and Redis
- Dev environment: Docker Compose and Dev Container
- Delivery: GitHub Actions, branch protection, Dependabot, CodeQL, Dependency Review, GHCR images

## Codex Workflow

- Project stack: [`docs/PROJECT_STACK.md`](docs/PROJECT_STACK.md)
- Project context: [`CONTEXT.md`](CONTEXT.md)
- Workflow guide: [`docs/CODEX_WORKFLOW.md`](docs/CODEX_WORKFLOW.md)
- Requirements templates: [`docs/requirements/README.md`](docs/requirements/README.md)
- ADR templates: [`docs/adr/README.md`](docs/adr/README.md)
- Engineering standards: [`docs/ENGINEERING_STANDARDS.md`](docs/ENGINEERING_STANDARDS.md)
- Delivery checklist: [`docs/DELIVERY_CHECKLIST.md`](docs/DELIVERY_CHECKLIST.md)
- Security baseline: [`docs/SECURITY_BASELINE.md`](docs/SECURITY_BASELINE.md)
- Security policy: [`SECURITY.md`](SECURITY.md)
- Agent instructions: [`AGENTS.md`](AGENTS.md)
- Quick local check: `.\scripts\codex-check.ps1`
- CI entrypoint: [`.github/workflows/ci.yml`](.github/workflows/ci.yml)

## Local Development

Full local stack:

```powershell
.\scripts\dev.ps1
```

View logs or stop the stack:

```powershell
.\scripts\logs.ps1 -Follow
.\scripts\stop.ps1
```

Run migrations manually when needed:

```powershell
.\scripts\migrate.ps1
.\scripts\migrate.ps1 -Local
```

Run Docker-backed integration checks:

```powershell
.\scripts\test-integration.ps1 -KeepRunning
```

Run browser E2E checks:

```powershell
cd frontend
npm.cmd install
npx.cmd playwright install chromium
cd ..
.\scripts\test-e2e.ps1 -KeepRunning
```

Install local pre-commit checks:

```powershell
.\scripts\install-git-hooks.ps1
```

Backend:

```powershell
cd backend
python -m pip install -e ".[dev]"
python -m uvicorn app.main:app --reload
python -m alembic upgrade head
```

Frontend:

```powershell
cd frontend
npm.cmd install
npm.cmd run generate:api
npm.cmd run dev
```

Refresh the committed OpenAPI contract and generated TypeScript client:

```powershell
.\scripts\generate-api.ps1
```

Dev Container users can reopen the repository in a container and use the same scripts from the workspace root.

Container images are built on pull requests and published from `main` to GitHub Container Registry:

```text
ghcr.io/xiz926500-cloud/codex-2-api
ghcr.io/xiz926500-cloud/codex-2-web
```
