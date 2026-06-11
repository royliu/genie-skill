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

## 2026-06-10 — inquiry mode (user-directed)

- **Added references/inquiry.md + Phase 0/1 hooks**: genie now explicitly
  handles research / analysis / strategy / thinking tasks. Modules are
  investigative angles; criteria are provenance-shaped (citations,
  counter-evidence, invalidation conditions); the red-team module replaces
  pytest; user parameters (risk tolerance, horizon, budget, intended use)
  are escalation-worthy forks. Trigger description widened to match.
  Evidence: live OpenClaw session declined a market-analysis request as
  "not a software project" — correct triage logic, too-narrow task model.
  Provenance: user statement.

## 2026-06-11 — cost preflight (user-directed)

- **Phase 1 cost gate**: before dispatch, estimate the run (planned agents
  × ledger-calibrated per-agent cost + 15% overhead, ±30% range), record
  as `budget.tokens_estimated`, present alongside the module breakdown
  with lite/native alternatives, and WAIT for go-ahead when the user is
  present and the estimate exceeds `confirm_over_tokens` (default 60k).
  Retro rubric gains estimate-accuracy check; the estimator self-calibrates
  from ledger actuals. Evidence: user reported surprise token burn kicking
  off runs on OpenClaw. Provenance: user statement.

## 2026-06-11 — concurrence gate with autopilot opt-out (user-directed)

- **`budget.confirm_mode`, default `always`**: the cost preflight now
  requires explicit user concurrence before dispatching any agent on
  every run. No reply = run held `pending` with plan+estimate saved (one
  notification, no polling, no spend). `over-threshold` keeps the old 60k
  behavior; `autopilot` never asks (estimate still posted, budget caps
  still brake). Saying "autopilot"/"don't ask again" persists as a
  standing user memory across runs and hosts; "ask me again before runs"
  reverts; per-run overrides always win. Provenance: user statement.

## 2026-06-11 — memory linking, Obsidian-style (user-directed)

- **`[[memory-id]]` wikilinks between memories** with optional typed
  relations (supports / refines / supersedes / contradicts / derived-from).
  Recall expands one hop through links (bounded); a `contradicts` edge
  between recalled memories is surfaced, never silently applied. Dreams
  tend the graph: repair dangling links, add decision-relevant ones,
  read topology (clusters → merge, orphans → prune, contradictions →
  work orders). The store remains a valid Obsidian vault for visual
  inspection of the genie's knowledge graph. Provenance: user statement.
