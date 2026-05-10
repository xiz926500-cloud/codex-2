$ErrorActionPreference = "Stop"

$patterns = @(
    @{
        Name = "GitHub token"
        Regex = 'gh[pousr]_[A-Za-z0-9_]{30,}'
    },
    @{
        Name = "OpenAI API key"
        Regex = 'sk-[A-Za-z0-9_-]{20,}'
    },
    @{
        Name = "AWS access key"
        Regex = 'AKIA[0-9A-Z]{16}'
    },
    @{
        Name = "Slack token"
        Regex = 'xox[baprs]-[A-Za-z0-9-]{20,}'
    },
    @{
        Name = "Private key"
        Regex = '-----BEGIN ([A-Z ]+)?PRIVATE KEY-----'
    }
)

$trackedFiles = git ls-files --cached --others --exclude-standard
$findings = New-Object System.Collections.Generic.List[string]

foreach ($file in $trackedFiles) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        continue
    }

    $content = Get-Content -LiteralPath $file -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) {
        continue
    }

    foreach ($pattern in $patterns) {
        $matches = [regex]::Matches($content, $pattern.Regex)
        foreach ($match in $matches) {
            $findings.Add("$file`: possible $($pattern.Name)")
        }
    }
}

if ($findings.Count -gt 0) {
    Write-Host "Potential secrets found:"
    $findings | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
    throw "Secret scan failed"
}

Write-Host "Secret scan passed."
