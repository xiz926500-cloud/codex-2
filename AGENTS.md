# AGENTS.md

Normative repository guidance for Codex and other coding agents. Global
Terra/Sol/Luna routing remains defined in `~/.codex/AGENTS.md`.
`docs/CODEX_WORKFLOW.md` explains this policy but does not duplicate or override
it.

## Default Workflow

- Operate with high autonomy: when the user states a goal, proceed through
  inspection, implementation, and verification without repeated confirmation.
- Resolve uncertainty from the repository, runtime, and available documentation
  before asking the user. Stop only for missing business authority, substantial
  destructive personal-data changes, real secret exposure, policy boundaries,
  or irreversible external actions that were not already requested.
- For reversible risk, create a backup, task branch, checkpoint, or rollback
  note and continue.
- Inspect the repository structure before changing code. Read `CONTEXT.md` for
  complex business or scope work and check `docs/adr/` before revisiting durable
  decisions.
- Prefer the smallest complete change, follow existing patterns, and keep
  unrelated refactors out of scope.
- Use `docs/requirements/` for complex business rules, permissions, state
  transitions, public contracts, or rollout risk.

## Project Structure Gate

- When creating a persistent multi-module project and the user has not supplied
  a structure, propose the recommended structure for user audit before
  scaffolding it.
- For a one-file utility, disposable prototype, or clearly conventional minimal
  project, choose the smallest standard structure, proceed autonomously, and
  report the structure in the handoff instead of pausing.

## Context Tool Readiness

- Check that a tool is available and ready for the current repository before
  treating it as a context gate. A failed readiness check is enough to use the
  documented fallback; do not repeatedly call an unready tool.
- Use GitNexus only when the current repository is indexed and Git history,
  dependency relationships, commits, branches, or pull requests affect the
  task. Otherwise use local Git inspection and `gh` when needed.
- Use Context7 when framework, SDK, API, or library behavior may have changed and
  current external documentation affects the implementation. Do not call it for
  purely internal edits.
- Use OpenSpec when it is initialized and a new project, complex feature,
  permission model, state transition, public contract, or architecture change
  benefits from a reviewable spec. If it is uninitialized, use
  `docs/requirements/` and `docs/adr/` unless initializing OpenSpec is itself
  justified by the task.

## Branch And Review Thresholds

- Use a `codex/<short-task-name>` branch for production code, shared tracked
  workflow changes, schema changes, dependencies, or any task intended for PR
  review.
- Documentation-only edits, local machine configuration, and disposable
  investigations may stay on the current branch when no shared code is affected.
- Open a pull request instead of pushing shared code directly to `main`. Keep the
  PR description filled with summary, validation, risks, and rollback notes, and
  check CI after pushing.

## Scope Control

- Respect explicit boundaries for files, modules, algorithms, contracts, and UI
  behavior. Do not modify protected logic without explicit approval.
- Keep frontend and backend validation aligned when both exist.
- Avoid adding UI prompts or behavior that the user did not request.

## Windows Commands

- Use PowerShell-compatible commands.
- Prefer `npm.cmd` over `npm` in automation to avoid `.ps1` execution-policy
  surprises.
- Use `python` rather than `py`; the Python launcher may not be installed.
- Prefer `rg` for searching, with PowerShell search cmdlets as fallback.

## Verification

- Add or update persisted tests for behavior changes and bug fixes. Do not leave
  new test cases only in chat.
- For documentation, policy, configuration, generated artifacts, or environment
  changes, use the most meaningful static, parser, smoke, or manual validation;
  do not create a meaningless test solely to satisfy a rule.
- Run focused checks first, then all saved tests covering the affected behavior
  and the broader regression checks justified by the change's risk.
- Deliver only after required checks pass. When automation is impractical, state
  why and record the smallest reliable manual verification.
- Include a test audit in the final handoff or PR description: persisted test
  files, case names or assertions, scenarios, affected regressions, commands,
  and pass/fail results.

Run the repository baseline before opening or updating a PR:

```powershell
.\scripts\verify.ps1
```

Use stack-specific checks when relevant:

```powershell
npm.cmd run lint
npm.cmd run build
npm.cmd test
python -m pytest
python -m py_compile path\to\file.py
```

## Project Tracking

- Use Linear issues and Notion documents as source context when they are
  connected and relevant.
- Update external task state only at meaningful checkpoints and only when the
  requested action is authorized.

## Current Stack

- `frontend`: React, TypeScript, Vite, ESLint, Playwright, and generated OpenAPI
  types.
- `backend`: FastAPI, SQLModel, Alembic, live/readiness checks, Pytest, and Ruff.
- `docker-compose.yml`: PostgreSQL and Redis integration services.
- `.devcontainer`: reproducible development-container configuration.
- CI should run repository verification, frontend lint/build, backend lint/test,
  Docker integration, Playwright E2E, image builds, dependency review, and
  CodeQL when supported source files exist.

## Safety

- Never commit credentials, tokens, private keys, database dumps, or
  machine-specific secrets.
- Keep `.env.example` current when environment variables change.
- Do not use destructive Git commands unless the user explicitly requests them.
