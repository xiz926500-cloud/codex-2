# Architecture Decision Records

Use ADRs for decisions that are hard to reverse, surprising without context,
and based on a real trade-off. Keep them short: the value is preserving why the
decision happened, not filling out a long form.

## When To Create One

- A major architectural shape changes.
- A technology choice creates meaningful lock-in.
- A module, data, or ownership boundary is intentionally drawn.
- A non-obvious alternative was rejected and will likely come up again.
- A constraint is important but not visible from the code.

## Naming

Use sequential numbering:

```text
docs/adr/0001-short-slug.md
docs/adr/0002-another-decision.md
```

Start from [0000-template.md](0000-template.md), then delete sections that do
not add value.
