# Delivery Checklist

Use this checklist before a change is considered ready.

## Scope

- [ ] The task goal is clear.
- [ ] `CONTEXT.md` was checked when project terminology or scope boundaries mattered.
- [ ] Existing ADRs were checked before changing durable architecture or ownership decisions.
- [ ] Complex business rules have a PRD or requirements note in `docs/requirements/`.
- [ ] Actors, permissions, edge cases, and acceptance cases are documented when relevant.
- [ ] Only intended files were changed.
- [ ] No unrelated cleanup or refactor was included.
- [ ] Protected areas were left untouched unless explicitly approved.

## Implementation

- [ ] Existing project patterns were followed.
- [ ] Frontend and backend contracts still match.
- [ ] Validation messages match actual validation rules.
- [ ] Environment variables are documented in `.env.example`.
- [ ] New setup requirements are reflected in `scripts/bootstrap.ps1` or `docs/TEMPLATE_USAGE.md`.

## Verification

- [ ] `.\scripts\verify.ps1`
- [ ] `.\scripts\secret-scan.ps1`
- [ ] `.\scripts\test-template.ps1` for template generation changes
- [ ] `cd frontend; npm.cmd run lint; npm.cmd run build`
- [ ] `cd backend; python -m ruff check .; python -m pytest`
- [ ] `.\scripts\test-integration.ps1 -KeepRunning` for Docker-backed API/database/cache changes
- [ ] `.\scripts\test-e2e.ps1 -KeepRunning` for frontend/runtime workflow changes
- [ ] Manual smoke test, if needed

## PR

- [ ] PR template is filled in.
- [ ] New ADR is included when a hard-to-reverse trade-off was made.
- [ ] CI is green.
- [ ] Risk and rollback notes are included.
- [ ] Linear or Notion status is updated, if used.
