# Risk Checklist Template

Use this before opening a PR for features with meaningful business behavior.

## Scope And Product Risk

- [ ] The business outcome is explicit.
- [ ] Out-of-scope behavior is documented.
- [ ] Open questions are either resolved or called out in the PR.
- [ ] User-facing copy matches the actual rules.

## Security And Privacy

- [ ] Authorization is checked on the server side.
- [ ] Sensitive data is not exposed in logs, errors, analytics, or URLs.
- [ ] Secrets stay in environment configuration, not source control.
- [ ] Abuse cases and rate limits were considered.

## Data Integrity

- [ ] Writes are transactional where partial state would be harmful.
- [ ] Duplicate requests are idempotent or safely rejected.
- [ ] Migrations have backward-compatible defaults.
- [ ] Rollback impact on data is documented.

## Business Rules

- [ ] Role and permission rules are covered.
- [ ] Status or lifecycle transitions are constrained.
- [ ] Edge cases have explicit expected behavior.
- [ ] Rule conflicts have a chosen winner.

## Operations

- [ ] Metrics, logs, or audit events exist for important actions.
- [ ] Failure modes have actionable diagnostics.
- [ ] External dependency failures have a defined behavior.
- [ ] Performance impact is understood for the expected data size.

## Verification

- [ ] Unit tests cover pure business rules.
- [ ] Integration tests cover contracts and persistence.
- [ ] End-to-end tests cover critical user workflows.
- [ ] Manual smoke test steps are listed when automation is impractical.

## Rollout

- [ ] Feature flag or staged rollout is defined if needed.
- [ ] Backward compatibility is documented.
- [ ] Rollback plan is included in the PR.
- [ ] Support or operational notes are ready if users may be affected.
