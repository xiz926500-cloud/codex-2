# Requirements Templates

Use these templates when a task has business rules, roles, state changes,
money, permissions, data retention, or acceptance risk. They are meant to make
the problem crisp before implementation starts.

Read the root [`CONTEXT.md`](../../CONTEXT.md) first when terminology, scope
boundaries, or protected logic matter.

## Template Map

- [PRD template](prd-template.md): define the feature, users, scope, metrics,
  dependencies, and open questions.
- [Business rules template](business-rules-template.md): capture permissions,
  rule conflicts, edge cases, audit needs, and testable outcomes.
- [State machine template](state-machine-template.md): model lifecycle states,
  allowed transitions, guards, side effects, and invariants.
- [Acceptance cases template](acceptance-cases-template.md): turn requirements
  into concrete scenarios for unit, integration, end-to-end, and manual checks.
- [Risk checklist](risk-checklist-template.md): review security, data,
  operations, migration, observability, and rollback risk before a PR.

## Recommended Flow

1. Fill the PRD for any non-trivial feature.
2. Add business rules when behavior depends on role, status, pricing,
   ownership, compliance, or external system state.
3. Add a state machine when an entity can move through lifecycle states.
4. Write acceptance cases before implementation so tests match the business
   outcome, not only the code path.
5. Revisit the risk checklist before opening a PR.

## Definition Of Ready

A task is ready for Codex-assisted implementation when it includes:

- A clear user or business outcome.
- The actors and permissions involved.
- In-scope and out-of-scope boundaries.
- The core rules and at least one concrete example per risky rule.
- Acceptance cases for happy paths, negative paths, and important regressions.
- Known dependencies, rollout notes, and rollback expectations.

## Naming

Create feature-specific copies under this folder when useful:

```text
docs/requirements/<feature-name>-prd.md
docs/requirements/<feature-name>-business-rules.md
docs/requirements/<feature-name>-acceptance-cases.md
```
