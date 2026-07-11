# Global Sol-Only Workflow

These rules define the default single-agent operating model across repositories.
An explicit user instruction for the current task takes precedence.

## Operating Mode

- The root/main model is always Sol (`gpt-5.6-sol`).
- Sol handles requirements, architecture, implementation, review, verification,
  and the final user response directly.
- Do not spawn subagents, delegate work, or select another model. Codex requires
  `agents.max_depth >= 1`, so keep it at `1` and enforce no delegation through
  this policy.
- Preserve one continuous context from discovery through delivery so decisions
  and implementation evidence stay together.

## Execution

- Inspect repository, runtime, tests, and current documentation before changing
  code. Resolve uncertainty locally before asking the user.
- Ask only when business authority, a hard safety boundary, or an irreversible
  external action cannot be resolved from available evidence.
- Use external context tools only after confirming they are ready and relevant
  to the current repository. Fall back immediately when they are unavailable.
- Prefer the smallest complete change and avoid unrelated refactors.
- Add meaningful persisted tests for behavior changes, then run focused and
  affected regression checks.
- Review the final diff and verify all delivery claims with fresh command output.

## Permissions

- Treat the current task's effective sandbox and approval mode as the real
  security boundary.
- Keep `workspace-write` as the default and escalate only the minimum operation
  and scope required.
