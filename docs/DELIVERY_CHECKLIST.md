# Delivery Checklist

Use this checklist before a change is considered ready.

## Scope

- [ ] The task goal is clear.
- [ ] Only intended files were changed.
- [ ] No unrelated cleanup or refactor was included.
- [ ] Protected areas were left untouched unless explicitly approved.

## Implementation

- [ ] Existing project patterns were followed.
- [ ] Frontend and backend contracts still match.
- [ ] Validation messages match actual validation rules.
- [ ] Environment variables are documented in `.env.example`.

## Verification

- [ ] `.\scripts\verify.ps1`
- [ ] `.\scripts\secret-scan.ps1`
- [ ] `cd frontend; npm.cmd run lint; npm.cmd run build`
- [ ] `cd backend; python -m ruff check .; python -m pytest`
- [ ] `.\scripts\test-integration.ps1 -KeepRunning` for Docker-backed API/database/cache changes
- [ ] Manual smoke test, if needed

## PR

- [ ] PR template is filled in.
- [ ] CI is green.
- [ ] Risk and rollback notes are included.
- [ ] Linear or Notion status is updated, if used.
