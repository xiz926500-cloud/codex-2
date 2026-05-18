# codex-2 Context

This repository is a delivery scaffold for Codex-assisted software projects. It
defines the shared language for turning an unclear request into scoped work,
verified changes, and reviewable delivery evidence.

## Language

**Task**:
A bounded unit of work requested by the user and completed through inspection,
implementation, verification, and reporting.
_Avoid_: vague job, random change

**Scope Boundary**:
The explicit limit on files, modules, behavior, or algorithms that a task may
touch.
_Avoid_: cleanup opportunity, nearby refactor

**Protected Logic**:
Logic the user has explicitly said must not be changed without approval.
_Avoid_: convenient edit target

**Requirement Artifact**:
A PRD, business rule note, state machine, acceptance case list, or risk
checklist that makes business behavior testable before implementation.
_Avoid_: loose notes, chat-only spec

**Business Rule**:
A domain rule that determines what must happen for a role, state, permission,
or data condition.
_Avoid_: validation detail, implementation branch

**Acceptance Case**:
A concrete scenario that proves a requirement is satisfied through automated or
manual verification.
_Avoid_: hope, demo idea

**ADR**:
A short record of a decision that is hard to reverse, surprising without
context, and based on a real trade-off.
_Avoid_: meeting note, exhaustive design doc

**Repository Baseline**:
The minimum expected project structure, workflow documentation, security
configuration, and verification scripts for this repo.
_Avoid_: optional polish

**Bootstrap**:
The repeatable setup path that turns a fresh checkout into a verified local
development environment.
_Avoid_: manual setup memory

**Project Template**:
The reusable scaffold produced from this repository for a new project.
_Avoid_: copied working directory

**Delivery Evidence**:
The commands, CI checks, PR links, risk notes, and rollback notes that prove a
task was completed responsibly.
_Avoid_: "it works on my machine"

**Agent Skill**:
A reusable local instruction package that improves how Codex performs a class
of work, such as diagnosis, TDD, PRD creation, triage, or handoff.
_Avoid_: model upgrade, plugin magic

## Relationships

- A **Task** may define one or more **Scope Boundaries**.
- A **Protected Logic** area is always inside a **Scope Boundary**.
- A **Requirement Artifact** can produce many **Acceptance Cases**.
- A **Business Rule** should map to at least one **Acceptance Case** when it is
  risky or user-visible.
- An **ADR** explains durable choices that are not obvious from the code.
- A **Bootstrap** proves the **Repository Baseline** can be recreated on a new
  machine.
- A **Project Template** starts from tracked files and must not include local
  secrets or generated machine state.
- **Delivery Evidence** proves that the **Repository Baseline** still holds
  after a **Task** is completed.
- An **Agent Skill** improves execution style, but does not replace **Delivery
  Evidence**.

## Example Dialogue

> **Developer:** "This feature touches permissions. Should we start coding?"
> **Domain expert:** "First write the **Business Rules** and **Acceptance
> Cases**. The admin path and normal-user path must be separate."
>
> **Developer:** "The implementation would be simpler if I changed the
> encryption helper."
> **Domain expert:** "That helper is **Protected Logic**. Keep the **Scope
> Boundary** around caller behavior unless I approve the algorithm change."

## Flagged Ambiguities

- "Optimize Codex" can mean model choice, tool installation, repo workflow, or
  delivery discipline. In this repo, prefer concrete workflow and verification
  improvements over abstract capability claims.
- "Plugin" and **Agent Skill** are different. Plugins/connectors provide
  external context or actions; skills provide local process instructions.
- "Done" means the task has **Delivery Evidence**, not only that code or
  documentation was edited.
