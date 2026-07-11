# Codex Workflow Runbook (Windows)

This document explains the normal delivery path. `AGENTS.md` is the normative
repository policy, and `~/.codex/AGENTS.md` is the normative global Sol-only
policy. When wording differs, the applicable `AGENTS.md` wins.

## Fast Path

1. Inspect the repository, current Git state, relevant tests, and runtime
   evidence.
2. Read `CONTEXT.md`, `docs/requirements/`, or `docs/adr/` only when the task
   depends on those decisions.
3. Check whether an external context tool is ready before calling it.
4. Let Sol handle requirements, architecture, implementation, review, and
   verification directly. Do not delegate to subagents.
5. Implement the smallest complete change.
6. Run focused validation, affected saved tests, and risk-appropriate regression
   checks.
7. Review the diff and deliver a test audit with risks and rollback notes.

## Sol-Only Execution

- Use `gpt-5.6-sol` with reasoning `high` as the default balance of depth and
  latency.
- Keep `agents.max_depth = 1`, the minimum accepted by Codex, disable custom
  agent TOML files, and enforce no delegation through the Sol-only policy.
- Sol performs discovery and execution in one continuous context, then reviews
  its own diff and reruns the relevant verification before delivery.
- Raise reasoning effort only for exceptional high-impact work where the extra
  latency is justified.

## Apply Sol-Only Globally

Run the audited migration from a normal PowerShell terminal:

```powershell
pwsh -NoProfile -File .\scripts\apply-sol-only-codex.ps1
```

The migration backs up `~/.codex`, disables active custom-agent TOML files,
installs the Sol-only guidance and verifier, then requires a Codex restart.

## Context Tool Gate

| Tool | Ready when | Use for | Fallback |
| --- | --- | --- | --- |
| GitNexus | Current repo is indexed and current enough | History and code relationships | Local Git, `rg`, `gh` |
| Context7 | Current library/API behavior matters | Official framework, SDK, and API usage | Primary official docs |
| OpenSpec | Current repo is initialized | Reviewable complex specs and contracts | `docs/requirements/`, `docs/adr/` |

An unavailable or uninitialized tool is a normal fallback condition, not a
reason to retry it repeatedly or block implementation.

## Git Threshold

Use a task branch for shared code or workflow changes:

```powershell
git switch -c codex/<short-task-name>
```

Open a PR for shared changes intended for review. Local machine configuration,
documentation-only work, and disposable investigations do not require a branch
or PR unless the user or repository policy says otherwise.

## Verification Commands

Run the repository baseline:

```powershell
.\scripts\verify.ps1
```

Use only the stack checks affected by the change:

```powershell
cd frontend
npm.cmd run lint
npm.cmd run build
npm.cmd run test:e2e

cd ..\backend
python -m ruff check .
python -m pytest
```

For Docker integration work:

```powershell
.\scripts\dev.ps1
.\scripts\migrate.ps1
.\scripts\test-integration.ps1 -KeepRunning
.\scripts\test-e2e.ps1 -KeepRunning
.\scripts\stop.ps1
```

Documentation and configuration changes should use parser, policy, smoke, or
manual checks that actually validate the changed behavior. Do not add empty or
tautological tests merely to produce a test file.

## Delivery

Before delivery, use `docs/DELIVERY_CHECKLIST.md`. For a new project created from
this scaffold, also use `docs/TEMPLATE_USAGE.md`.

The final handoff records changed files, persisted tests or policy assertions,
commands and outcomes, affected regressions, residual risks, and rollback path.
