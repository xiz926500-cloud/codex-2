# Template Usage

This repository can be used as a practical starting point for new Codex-assisted
projects. The goal is to preserve the delivery baseline while letting each new
project rename the app, install dependencies, and start cleanly.

## Fresh Checkout Bootstrap

Run this after cloning the repository on a new Windows machine:

```powershell
.\scripts\bootstrap.ps1
```

The bootstrap script:

- Checks Git, Python, Node, `npm.cmd`, optional GitHub CLI, and optional Docker.
- Copies `.env.example` to `.env` when `.env` is missing.
- Installs backend development dependencies.
- Installs frontend dependencies with `npm.cmd`.
- Installs the Chromium browser for Playwright.
- Refreshes the generated OpenAPI client.
- Installs repository-local Git hooks.
- Runs `.\scripts\verify.ps1`.

Useful options:

```powershell
.\scripts\bootstrap.ps1 -SkipInstall
.\scripts\bootstrap.ps1 -SkipPlaywright
.\scripts\bootstrap.ps1 -RequireDocker
.\scripts\bootstrap.ps1 -ForceNpmInstall
```

## Create A New Project From This Template

Create a sibling project directory:

```powershell
.\scripts\new-project.ps1 -Name my-project
```

Create the project somewhere specific:

```powershell
.\scripts\new-project.ps1 -Name my-project -DestinationRoot C:\Users\www_z\Documents\Codex
```

Initialize Git in the generated project:

```powershell
.\scripts\new-project.ps1 -Name my-project -InitializeGit
```

Preview the target without copying files:

```powershell
.\scripts\new-project.ps1 -Name my-project -DryRun
```

Run the same smoke test used by CI:

```powershell
.\scripts\test-template.ps1
```

## What Gets Copied

`new-project.ps1` copies tracked files from Git, not every file in the working
directory. That keeps local-only files out of generated projects:

- `.git` is not copied.
- `.env` is not copied.
- `node_modules`, virtual environments, logs, and other untracked local output
  are not copied.

The script refuses to generate the new project inside the source repository, so
template copies do not accidentally become nested worktrees.

## What Gets Renamed

The generated project replaces the default names used by this template:

- `codex-2` becomes the new project slug.
- `codex-2-web` becomes `<project-slug>-web`.
- `codex2-api` becomes `<project-slug>-api`.
- Example database names are adjusted to match the project slug.
- GitHub Container Registry examples are changed to `your-github-owner/<project-slug>`.

Review generated files before publishing, especially README links, package
names, environment defaults, and container image names.

## Recommended First Commit

After generating a new project:

```powershell
cd <generated-project>
.\scripts\bootstrap.ps1
git status --short
git commit -m "chore: initialize project from codex template"
```

Then create a GitHub repository and push using the same PR-first workflow
documented in [CODEX_WORKFLOW.md](CODEX_WORKFLOW.md).
