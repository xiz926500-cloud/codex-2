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

Use the bootstrap script on a fresh checkout or new machine:

```powershell
.\scripts\bootstrap.ps1
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

For changes that touch Docker, database migrations, Redis, or runtime readiness, run:

```powershell
.\scripts\test-integration.ps1 -KeepRunning
```

For changes that affect the user-facing browser workflow, run:

```powershell
.\scripts\test-e2e.ps1 -KeepRunning
```

Install repository-local pre-commit checks in each checkout:

```powershell
.\scripts\install-git-hooks.ps1
```

## Requirements

Use `docs/requirements/` for features with complex business behavior,
permissions, state transitions, data changes, or rollout risk. PRs should link
to the relevant PRD, business rules, acceptance cases, or risk checklist when
those documents exist.

Use `CONTEXT.md` for stable project language. Use `docs/adr/` for durable
decisions that future contributors should not have to rediscover.

Use `docs/TEMPLATE_USAGE.md` and `scripts/new-project.ps1` when turning this
repository into a new project scaffold.

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
- Broken readiness, migration, or container startup behavior
- Missing tests for risky changes
- Unrelated refactors mixed into the task
