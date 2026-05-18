# Security Baseline

This repository uses a lightweight baseline that works before application code exists and can grow with the project.

## What Runs Now

- `Repository health`: validates required project files, README links, whitespace, and secret patterns.
- `Dependency Review`: checks dependency manifest changes in pull requests.
- `Dependabot`: checks GitHub Actions updates weekly.
- `CodeQL`: detects supported source languages and runs analysis when JavaScript, TypeScript, or Python files are present.
- `Docker integration`: starts the Compose stack and verifies runtime readiness for API, database, Redis, and migrations.

## Local Commands

Run all baseline checks:

```powershell
.\scripts\verify.ps1
```

Run only the lightweight secret scan:

```powershell
.\scripts\secret-scan.ps1
```

Run Docker-backed runtime checks:

```powershell
.\scripts\test-integration.ps1 -KeepRunning
```

## When A Real Stack Is Added

Update the baseline with the project-specific ecosystem:

- Add package manifests such as `package.json`, `requirements.txt`, `pyproject.toml`, or lock files.
- Extend `.github/dependabot.yml` with the relevant package ecosystems.
- Add test, lint, build, and smoke-test commands to CI.
- Add application-specific threat notes to `SECURITY.md`.

## Rules Of Thumb

- Keep secrets out of git history.
- Prefer least-privilege tokens.
- Document required environment variables in `.env.example`.
- Treat public CI logs as public information.
- Rotate exposed secrets immediately.
