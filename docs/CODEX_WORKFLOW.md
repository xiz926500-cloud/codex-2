# Codex Default Workflow (Windows)

This workflow is tuned for local Windows development with GitHub and Codex.

## 1) Start From A Clear Task

Use this task shape when asking Codex:

```text
Inspect project first, find root cause, then implement fix.
Allowed scope: <files/modules>
Do not touch: <algorithms/modules>
Run verification commands and report what changed.
```

## 2) Branch Strategy

Create a task branch:

```powershell
git checkout -b codex/<short-task-name>
```

## 3) Local Verification

Use command forms that are stable in PowerShell:

```powershell
npm.cmd run lint
npm.cmd run build
python -m py_compile path\to\file.py
```

For this repository:

```powershell
.\scripts\generate-api.ps1

cd frontend
npm.cmd run lint
npm.cmd run build
npm.cmd run test:e2e

cd ..\backend
python -m ruff check .
python -m pytest
```

Run repository quick checks:

```powershell
.\scripts\codex-check.ps1
```

Run CI-equivalent repository verification:

```powershell
.\scripts\verify.ps1
```

Run the full Docker development stack:

```powershell
.\scripts\dev.ps1
.\scripts\logs.ps1 -Follow
.\scripts\migrate.ps1
.\scripts\test-integration.ps1 -KeepRunning
.\scripts\test-e2e.ps1 -KeepRunning
.\scripts\stop.ps1
```

Install repository-local Git hooks once per checkout:

```powershell
.\scripts\install-git-hooks.ps1
```

## 4) Commit Rules

Keep commits scoped:

```powershell
git add <intended-files>
git commit -m "fix: <what changed>"
```

## 5) PR Flow

Create PR:

```powershell
gh pr create --fill
```

Watch checks:

```powershell
gh pr checks
gh run list --limit 5
```

## 6) Review And Close

- Address review comments with focused commits.
- Re-run checks after fixes.
- Merge only after green CI and scope confirmation.

## 7) Delivery Notes

Use the delivery checklist before considering a task done:

```text
docs/DELIVERY_CHECKLIST.md
```
