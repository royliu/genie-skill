# Orchestrate — dream mode (idle-time consolidation)

The per-run retro captures evidence fast and shallow; dreaming consolidates
it slow and deep, when the agent is idle. Three tempos: retro (capture) →
dream (consolidate + draft) → human/Workshop gate (commit). A dream never
deploys anything.

## Triggering — how idleness is detected

The skill cannot watch for idleness itself; the host fires a timer and a
**token-free shell guard** (`scripts/dream-guard.sh`) decides whether the
model wakes at all. The guard's definition of idle uses the harness's own
exhaust: active runs touch `state.json` and `agents/*.status.json`
constantly, so *no mtime under any `.genie/` dir in 30 minutes* means
no orchestration is happening. It also skips if a dream ran in the last
~20h, another dream holds the lock, or nothing (ledger, memory) changed
since the last dream — so idle nights cost zero tokens.

Per-host wiring:

- **OpenClaw / Hermes**: add to the heartbeat checklist or a cron job:
  `dream-guard.sh && <invoke agent with "/genie dream">`. Heartbeats
  already fire only between tasks, which adds a native busy-gate on top.
- **Claude Code**: a scheduled agent (cron) whose first action is to run
  the guard via Bash and end the turn if it exits non-zero.
- **Any host / manual**: the user can always invoke `dream` explicitly;
  manual invocation skips the recency/novelty checks but still honors the
  lock and active-run check.

## The dream pass

On waking: write `~/.genie/dream.lock`, and re-run the guard's
active-run check **before each write batch** — if a run has started, stop
immediately, clean the lock, leave a partial-dream note. Runs outrank
dreams, always.

Stages, in order:

1. **Consolidate the memory stores.** Read every memory across all
   namespaces (global + any project stores listed in dream scope). Merge
   duplicates, resolve contradictions (newer evidence wins), promote
   tentatives with 2+ confirmations to standing, demote or prune
   tentatives unconfirmed after ~10 runs or 60 days, rebuild INDEX.md
   files to match reality. Mark every touched memory with
   `consolidated: <date>` in its frontmatter. Prune by **salience**, not
   age alone: `times_applied: 0` after ~10 runs is the prune signal;
   high-`times_applied` memories are protected, and the dream report
   names the most load-bearing memories. **Tend the link graph**:
   repair links left dangling by pruned or renamed memories, add missing
   `[[links]]` between plainly related memories (sparingly — links must
   be decision-relevant), and read topology as consolidation signal:
   densely linked clusters are merge/promote candidates, long-unlinked
   orphans are prune candidates, and every `contradicts` edge is a work
   order.
2. **Cross-run analysis.** Read the FULL ledger (`runs.jsonl`), not the
   retro's 5-line window: metric trends (verifier escapes, iteration
   averages, escalation mix), recurring escalations across projects
   (candidates for never-ask memories), recurring orchestrator decisions
   (candidates for standing defaults). New findings enter as `tentative`
   memories citing the ledger lines as evidence.
3. **Draft amendments.** If a standing, general process rule is not yet
   reflected in the skill files: draft ONE proposal (the best one).
   On OpenClaw ≥ 2026.6.1: file it as a pending `skill_workshop` proposal
   citing memory id + evidence runs — never apply. Elsewhere: write the
   diff to `~/.genie/dreams/proposals/` for the next interactive
   session to surface for approval.
4. **Dream report.** Write `~/.genie/dreams/<date>.md`: exactly what
   was merged/promoted/pruned, findings, proposal filed (or "none"), and
   anything that looked wrong but lacked evidence to act on. Touch
   `~/.genie/last-dream`. Remove the lock. The next run's recall
   reads the latest dream report. Notify the user's channel ONLY if a
   proposal was filed — otherwise silence.

## Safety bounds (these make unsupervised consolidation survivable)

- **No new facts, ever.** A dream may reorganize, merge, promote, demote,
  prune, and draft — only from evidence already recorded in memories and
  the ledger. If a pattern needs information that isn't on disk, it goes
  in the report as a question, not into a memory. This is the line between
  consolidation and confabulation.
- **No live writes.** Never edit skill files, project files, or apply
  Workshop proposals. Drafts and pending proposals only.
- **At most one amendment proposal per dream**, same protected zones as
  self-improvement.md (never the amendment/dream protocols, destructive-op
  rules, or approval gates — and a dream may never relax its own bounds).
- **Atomic memory writes** (write temp file, rename) so an interrupted
  dream never leaves a half-written memory.
- **Everything attributable**: dream-touched memories are marked, the
  report lists every change, and `git`-less rollback is possible because
  pruned memories are moved to `~/.genie/dreams/pruned/<date>/`
  rather than deleted for the first 90 days.
