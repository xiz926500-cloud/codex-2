# Codex Environment Restore

Use this document to recreate the practical Codex setup from this Windows
machine on another computer. It separates what can be restored by script from
what must be re-authorized through the Codex app or GitHub.

## What This Restores

- Local Codex skills installed under `%USERPROFILE%\.codex\skills`.
- The recommended Windows command conventions used by this workspace.
- The project delivery baseline in this repository.
- The plugin/connector checklist that must be installed and authorized again.

This does not copy secrets, OAuth tokens, chat history, local `.env` files, or
machine-specific caches.

## Machine Prerequisites

Install these first on the new computer:

- Codex desktop app.
- Git.
- GitHub CLI (`gh`).
- Python 3.12+ available as `python`.
- Node.js 24+ with `npm.cmd`.
- Docker Desktop, if you want Docker-backed local integration checks.

Windows notes:

- Prefer `npm.cmd` over `npm` in PowerShell.
- Prefer `python` over `py`.
- If `.ps1` execution is blocked, set the current-user policy:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Use one-off bypasses only when needed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify.ps1
```

## Restore This Repository

Clone the repository, then run:

```powershell
.\scripts\bootstrap.ps1
.\scripts\verify.ps1
```

Useful checks:

```powershell
.\scripts\codex-check.ps1
.\scripts\test-template.ps1
```

This repository already contains the project scaffold:

- `AGENTS.md` for agent rules.
- `CONTEXT.md` for shared project vocabulary.
- `docs/requirements/` for PRDs, business rules, acceptance cases, state
  machines, and risk reviews.
- `docs/adr/` for hard-to-reverse decisions.
- `scripts/bootstrap.ps1` for fresh checkout setup.
- `scripts/new-project.ps1` for generating a new project from the template.
- `scripts/test-template.ps1` for CI-backed template smoke testing.
- GitHub CI, CodeQL, Dependency Review, container image builds, Docker
  integration checks, browser E2E checks, and branch protection.

## Restore Local Skills

Run:

```powershell
.\scripts\restore-codex-skills.ps1
```

Then restart Codex.

The script installs these skill groups:

### Matt Pocock Skills

From `mattpocock/skills`:

- `diagnose`
- `tdd`
- `grill-with-docs`
- `to-prd`
- `zoom-out`
- `to-issues`
- `triage`
- `handoff`
- `improve-codebase-architecture`
- `prototype`

### OpenAI Curated Skills

From `openai/skills`:

- `playwright`
- `security-threat-model`
- `security-best-practices`

### Superpowers Skills

From `obra/superpowers`:

- `using-superpowers`
- `brainstorming`
- `writing-plans`
- `executing-plans`
- `verification-before-completion`
- `systematic-debugging`
- `test-driven-development`
- `requesting-code-review`
- `receiving-code-review`
- `finishing-a-development-branch`
- `dispatching-parallel-agents`
- `subagent-driven-development`
- `using-git-worktrees`
- `writing-skills`

`using-superpowers` is intentionally strong. If it feels too noisy on the new
machine, remove only this folder and keep the rest:

```powershell
Remove-Item -LiteralPath "$env:USERPROFILE\.codex\skills\using-superpowers" -Recurse
```

## Restore Plugins And Connectors

Plugins and connectors require account authorization and should be restored from
the Codex app UI, not by copying local cache folders.

Reinstall or enable:

- GitHub.
- Linear.
- Notion.
- OpenAI Developers.
- Documents.
- Presentations.
- Spreadsheets.

Optional:

- Slack. It was previously unavailable or region-limited for this account, so
  only reconnect it if the new environment supports it.

After authorizing GitHub, verify:

```powershell
gh auth status
gh repo view xiz926500-cloud/codex-2
```

For package registry access, refresh scopes if needed:

```powershell
gh auth refresh -h github.com -s read:packages
```

## What Not To Copy

Do not copy these directly between computers:

- `%USERPROFILE%\.codex\sessions`
- `%USERPROFILE%\.codex\plugins\cache`
- OAuth tokens or app credentials.
- Project `.env` files.
- `.venv`, `node_modules`, `dist`, or other generated build output.

Use GitHub for repository state and re-authorize plugins on the new machine.

## Verification Checklist

After restoring:

```powershell
Get-ChildItem "$env:USERPROFILE\.codex\skills" -Name | Sort-Object
.\scripts\verify.ps1
.\scripts\pre-commit.ps1
gh auth status
gh pr status
```

Expected local skills should include `diagnose`, `tdd`,
`improve-codebase-architecture`, `playwright`, `security-threat-model`,
`using-superpowers`, `systematic-debugging`, and
`verification-before-completion`.

## Practical Working Pattern

The optimized workflow on this machine is:

1. Inspect the project structure first.
2. Read `AGENTS.md`, `CONTEXT.md`, and relevant docs.
3. Make the smallest scoped change.
4. Use task branches named `codex/<short-task-name>`.
5. Run local verification.
6. Open a PR instead of pushing straight to `main`.
7. Watch CI and merge only after green checks.

For real project handoff, keep the repo state in GitHub and keep machine-local
state reproducible through scripts, not copied folders.
