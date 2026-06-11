# Amendments log

Changes to the skill's own files driven by run evidence. Every entry was
explicitly user-approved.

## 2026-06-10 — batch 1 (evidence: run expense-cli-2026-06-10)

- **Fixed supervisor contract escalation shape** (SKILL.md): the contract's
  field list omitted `module` and `type`, so it taught agents a shape that
  violated `schemas/escalation.schema.json`. Evidence: 3-of-3 early
  supervisor replies deviated from schema. Source memory:
  `process/schema-in-supervisor-prompts` (promoted to skill, deleted).
- **Schema-in-prompt rule** (SKILL.md dispatch step): dispatch prompts must
  paste the literal result JSON shape with met-boolean / no-extra-fields
  warnings. Evidence: same run — after this was done for the cli module,
  compliance was perfect. Same source memory.
- **Heartbeat/result-file protocol, watchdog, idempotent resume**
  (SKILL.md, escalation-protocol.md §6): filesystem as message bus;
  `dispatched_at`/`stale_after_minutes`; re-dispatch once then synchronous
  fallback for verifiers. Evidence: both background verifiers went
  untracked mid-run; only a synchronous fallback saved the run. Source
  memory: `process/verify-synchronously-on-tracking-loss` (behavioral part
  promoted; machine-specific fact retained as
  `process/machine-python-needs-venv`).
- **Containment recipe** (porting.md): non-admin user / container with
  project-only writable mount as the physical safety layer on hosts
  without a permission system.

## 2026-06-10 — rename (user decision)

- **Skill renamed `orchestrate` → `genie`** for memorability and
  non-English-speaker friendliness; chosen by the user from three rounds of
  candidates. The old name remains a documented alias in the description
  ("orchestrate" still triggers it). On-disk protocol paths
  (`~/.genie/`, project `.genie/` dirs) deliberately unchanged —
  they are protocol, not branding, like git's `.git/` — so all existing
  memories, ledger lines, and run state remain valid.
