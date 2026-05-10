# Engineering Standards

This repository uses a small, practical baseline for reliable project delivery.

## Branches

- `main` should stay releasable.
- Use `codex/<short-task-name>` for Codex-assisted work.
- Use one branch per feature, fix, or investigation.

## Verification

Run the repository health check before opening a pull request:

```powershell
.\scripts\verify.ps1
```

Run the lightweight secret scan before committing sensitive changes:

```powershell
.\scripts\secret-scan.ps1
```

For application projects, add the project-specific checks below and keep them current:

```powershell
npm.cmd run lint
npm.cmd run build
npm.cmd test
python -m pytest
python -m py_compile path\to\file.py
```

## Configuration

- Keep real secrets in `.env`.
- Keep documented placeholders in `.env.example`.
- Do not commit tokens, passwords, private keys, database dumps, or local machine paths.

## Pull Requests

Every PR should include:

- What changed
- Why it changed
- Exact validation commands and results
- Known risks
- Rollback plan

## Reviews

Review for behavior first:

- User-visible regressions
- Security or data handling risks
- Broken contracts between frontend, backend, and database
- Missing tests for risky changes
- Unrelated refactors mixed into the task
