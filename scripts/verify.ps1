$ErrorActionPreference = "Stop"

function Assert-File {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required file is missing: $Path"
    }
}

function Assert-Directory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Required directory is missing: $Path"
    }
}

function Assert-ReadmeLinks {
    $readme = Get-Content -LiteralPath "README.md" -Raw
    $matches = [regex]::Matches($readme, '\[[^\]]+\]\(([^)]+)\)')

    foreach ($match in $matches) {
        $target = $match.Groups[1].Value
        if ($target -match '^(https?:|mailto:|#)') {
            continue
        }

        $normalized = $target -replace '/', [IO.Path]::DirectorySeparatorChar
        if (-not (Test-Path -LiteralPath $normalized)) {
            throw "README link target does not exist: $target"
        }
    }
}

Write-Host "Checking required project files..."
Assert-File "README.md"
Assert-File "AGENTS.md"
Assert-File "CONTEXT.md"
Assert-File ".dockerignore"
Assert-File ".editorconfig"
Assert-File ".gitattributes"
Assert-File ".gitignore"
Assert-File ".env.example"
Assert-File "docker-compose.yml"
Assert-File ".devcontainer\devcontainer.json"
Assert-File ".devcontainer\post-create.sh"
Assert-File ".githooks\pre-commit"
Assert-File ".github\pull_request_template.md"
Assert-File ".github\ISSUE_TEMPLATE\bug_report.md"
Assert-File ".github\dependabot.yml"
Assert-File ".github\workflows\ci.yml"
Assert-File ".github\workflows\codeql.yml"
Assert-File ".github\workflows\container-publish.yml"
Assert-File ".github\workflows\dependency-review.yml"
Assert-File "docs\CODEX_WORKFLOW.md"
Assert-File "docs\adr\README.md"
Assert-File "docs\adr\0000-template.md"
Assert-File "docs\ENGINEERING_STANDARDS.md"
Assert-File "docs\DELIVERY_CHECKLIST.md"
Assert-File "docs\PROJECT_STACK.md"
Assert-File "docs\SECURITY_BASELINE.md"
Assert-File "docs\TEMPLATE_USAGE.md"
Assert-File "docs\requirements\README.md"
Assert-File "docs\requirements\prd-template.md"
Assert-File "docs\requirements\business-rules-template.md"
Assert-File "docs\requirements\state-machine-template.md"
Assert-File "docs\requirements\acceptance-cases-template.md"
Assert-File "docs\requirements\risk-checklist-template.md"
Assert-File "SECURITY.md"
Assert-File "backend\pyproject.toml"
Assert-File "backend\Dockerfile"
Assert-File "backend\.dockerignore"
Assert-File "backend\alembic.ini"
Assert-File "backend\app\main.py"
Assert-File "backend\app\database.py"
Assert-File "backend\app\health.py"
Assert-File "backend\app\models.py"
Assert-File "backend\migrations\env.py"
Assert-File "backend\migrations\script.py.mako"
Assert-File "backend\migrations\versions\202605180001_create_project_events.py"
Assert-File "backend\scripts\export_openapi.py"
Assert-File "backend\openapi.json"
Assert-File "backend\tests\test_health.py"
Assert-File "backend\tests\integration\test_runtime_readiness.py"
Assert-File "backend\tests\test_models.py"
Assert-File "frontend\package.json"
Assert-File "frontend\package-lock.json"
Assert-File "frontend\Dockerfile"
Assert-File "frontend\.dockerignore"
Assert-File "frontend\index.html"
Assert-File "frontend\playwright.config.ts"
Assert-File "frontend\e2e\readiness.spec.ts"
Assert-File "frontend\src\App.tsx"
Assert-File "frontend\src\lib\api-client\index.ts"
Assert-File "frontend\src\lib\api-client\types.gen.ts"
Assert-File "frontend\src\lib\api.ts"
Assert-File "scripts\codex-check.ps1"
Assert-File "scripts\bootstrap.ps1"
Assert-File "scripts\dev.ps1"
Assert-File "scripts\generate-api.ps1"
Assert-File "scripts\install-git-hooks.ps1"
Assert-File "scripts\logs.ps1"
Assert-File "scripts\migrate.ps1"
Assert-File "scripts\new-project.ps1"
Assert-File "scripts\pre-commit.ps1"
Assert-File "scripts\secret-scan.ps1"
Assert-File "scripts\stop.ps1"
Assert-File "scripts\test-e2e.ps1"
Assert-File "scripts\test-integration.ps1"
Assert-File "scripts\verify.ps1"
Assert-Directory ".devcontainer"
Assert-Directory ".githooks"
Assert-Directory ".github"
Assert-Directory "backend"
Assert-Directory "backend\migrations"
Assert-Directory "backend\migrations\versions"
Assert-Directory "backend\scripts"
Assert-Directory "backend\tests\integration"
Assert-Directory "frontend"
Assert-Directory "frontend\e2e"
Assert-Directory "frontend\src\lib\api-client"
Assert-Directory "docs"
Assert-Directory "docs\adr"
Assert-Directory "docs\requirements"
Assert-Directory "scripts"

Write-Host "Checking README links..."
Assert-ReadmeLinks

Write-Host "Checking git whitespace rules..."
git diff --check
if ($LASTEXITCODE -ne 0) {
    throw "git diff --check failed"
}

Write-Host "Checking for obvious secret patterns..."
& ".\scripts\secret-scan.ps1"

Write-Host "Repository verification passed."
