# AGENTS.md

Guidance for Codex and other coding agents working in this repository.

## Default Workflow

- Inspect the repository structure before changing code.
- Prefer the smallest change that fully solves the task.
- Follow existing project patterns before introducing new abstractions.
- Keep unrelated refactors out of task branches.
- Use one branch per task, preferably `codex/<short-task-name>`.
- Open a pull request for review instead of pushing directly to `main`.

## Scope Control

- Respect explicit user boundaries about files, modules, algorithms, and UI behavior.
- If a task names protected logic, do not modify it unless the user explicitly approves.
- If frontend and backend validation rules both exist, keep them aligned.
- If a UI prompt or behavior was not requested, avoid adding it.

## Windows Commands

- Use PowerShell-compatible commands.
- Prefer `npm.cmd` over `npm` in automation to avoid PowerShell `.ps1` execution-policy surprises.
- Use `python` rather than `py`; the Python launcher may not be installed.
- Prefer `rg` for searching; fall back to PowerShell `Get-ChildItem` and `Select-String` if needed.

## Verification

Run the repository baseline before opening or updating a PR:

```powershell
.\scripts\verify.ps1
```

Use project-specific checks when the project stack is added:

```powershell
npm.cmd run lint
npm.cmd run build
npm.cmd test
python -m pytest
python -m py_compile path\to\file.py
```

## GitHub And Project Tracking

- Keep PR descriptions filled with summary, validation, risks, and rollback notes.
- Check CI after pushing.
- Use Linear issues and Notion docs as source context when available.
- Update task status or comments when implementation reaches a meaningful checkpoint.

## Current Stack

- Frontend lives in `frontend` and uses React, TypeScript, Vite, and ESLint.
- Backend lives in `backend` and uses FastAPI, Pytest, and Ruff.
- Local integration services are defined in `docker-compose.yml` for PostgreSQL and Redis.
- CI should run repository verification, frontend lint/build, backend lint/test, dependency review, and CodeQL when supported source files exist.

## Safety

- Never commit real credentials, tokens, private keys, database dumps, or machine-specific secrets.
- Keep `.env.example` current when new environment variables are introduced.
- Do not use destructive Git commands unless the user explicitly requests them.
