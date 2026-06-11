# Orchestrate — self-improvement (harness retro & skill amendments)

The memory layer (memory.md) learns about the **user and project**. This
layer learns about the **harness itself**: every run is also an experiment
in how to orchestrate, and the retro turns its outcome into better future
runs — first as process memories, eventually as amendments to the skill's
own files.

## Run ledger

After every run, append exactly one JSON line to `~/.genie/runs.jsonl`:

```json
{"run": "add-auth-2026-06-10", "date": "2026-06-10", "outcome": "done | abandoned | user-blocked",
 "modules": 4, "modules_reverified": 1, "supervisor_iterations_avg": 1.7,
 "escalations": {"total": 5, "by": {"orchestrator": 2, "user": 2, "memory": 1}},
 "memory_vetoes": 0, "verifier_escapes": 0, "tokens": 109000,
 "budget": {"agents_spawned": 9, "caps_hit": false}}
```

`verifier_escapes` = defects found at integration (or reported by the user
afterwards) in a module a verifier had already passed. This is the single
most important quality signal the harness has about itself — when a defect
surfaces later, go back and increment it on the original run's line.

## Harness retro (runs in Phase 3, after the distill pass)

A short self-analysis — plain reading of this run's `state.json` plus the
last ~5 ledger lines, no agents needed. Five questions:

1. **Decomposition sizing.** Modules that needed 3+ supervisor↔verifier
   iterations: too big, or criteria not mechanical? Modules done trivially
   in one pass: should they have been merged into a neighbor?
2. **Criteria quality.** Any criterion whose verification evidence was
   prose-only ("read the code, looks correct") rather than an executed
   check? That criterion was unverifiable as written — note the rewrite
   pattern.
3. **Escalation calibration.** User answers that were obviously derivable
   from context → over-escalation (candidate for a never-ask memory).
   Vetoed memory- or orchestrator-decisions → under-escalation (that fork
   should have been asked).
4. **Verifier rigor.** Ratio of evidence fields showing executed commands vs
   prose; any verifier escapes on the ledger.
5. **Trends.** Across the recent ledger lines, is any metric worsening
   (escapes rising, iterations climbing, user-escalations not shrinking)?

Each finding becomes a `process/` memory through the standard consolidation
path in memory.md — `tentative` on first observation, promoted to
`standing` when a later retro confirms it. The retro's output is one short
section at the end of the final report: what the harness learned about
itself this run (or "nothing new").

## Skill amendment protocol (the self-modification path)

When a process memory reaches `standing` AND expresses a general rule
rather than a personal preference (e.g. "acceptance criteria must name the
exact command to run", "this machine should default to 2 parallel
supervisors"), the harness may propose editing its own files:

1. Draft a concrete diff to SKILL.md / references/ / schemas/.
2. Present it to the user: the memory, the evidence runs from the ledger,
   and the exact before/after text. Apply **only on explicit approval** —
   never silently. A harness that edits its own instructions unsupervised
   can drift, or be steered by one bad run; the human gate is the safety
   property, not a formality.
3. On approval: apply the edit and log it in `AMENDMENTS.md` at the skill
   root (create on first use): date, what changed, source memory id,
   evidence runs.
4. The amended rule now supersedes the memory — delete the memory (note
   "promoted to skill" in the AMENDMENTS entry) so recall doesn't
   double-apply it.

Bounds:

- At most **one** amendment proposal per run — the best one. A harness that
  proposes edits every run is optimizing for self-modification, not for the
  user's work.
- **Never** propose amendments to this protocol itself, to the
  destructive-operations escalation rule, or to any user-approval gate.
  If evidence suggests those need changing, raise it as a discussion point
  in the final report — words, not diffs.
- Keep the skill's total size in check: an amendment that adds a rule
  should prefer tightening existing text over appending new sections.

## Agent-to-agent exchange (importing others' best practices)

Best practices arrive from other agents as **amendment bundles**: a skill
diff or rule + sanitized rationale + a *claim* of evidence + provenance +
hash — via a shared git repo / PR, a Skill Workshop proposal, or an
adopted published skill version. Import rules:

- Foreign evidence is a testable claim, never proof — you cannot audit
  another agent's ledger. An imported practice enters the local store as
  `tentative` with `provenance: third-party`, no matter how proven it was
  at its source, and is applied only as a default-with-recommendation.
  It reaches `standing` exclusively through the local ledger confirming
  it across the usual two runs. Practices re-earn standing here.
- Imported skill diffs go through the normal amendment gate (user
  approval / Workshop scanner) before touching skill files — being
  pre-approved elsewhere counts for nothing locally.
- Never wire live agent-to-agent memory access; exchange is asynchronous
  and artifact-based so every import has a reviewable gate in front of it.
- Exports must be sanitized (no paths, names, project details, secrets) —
  the amendment format does most of this by construction; check anyway.
