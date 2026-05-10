# Security Policy

## Supported Versions

This repository is currently maintained from the `main` branch.

## Reporting A Vulnerability

Please do not open a public issue for sensitive security reports.

For this repository, use one of these paths:

- Create a private Linear or Notion task if you have access.
- Contact the repository owner directly.
- If GitHub private vulnerability reporting is enabled later, use that channel.

Include:

- Affected files or feature area
- Reproduction steps
- Expected and actual behavior
- Potential impact
- Suggested mitigation, if known

## Secret Handling

- Never commit real secrets, tokens, private keys, database dumps, or local credentials.
- Store local values in `.env`.
- Keep placeholders documented in `.env.example`.
- Rotate any secret immediately if it was committed, even if later removed.

## Baseline Automation

This repository uses:

- Dependabot for GitHub Actions updates
- Dependency Review on pull requests
- CodeQL when supported source files are present
- A lightweight repository secret scan in `scripts/secret-scan.ps1`
