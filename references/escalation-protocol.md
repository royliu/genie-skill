# Orchestrate — escalation protocol & state schemas

Exact message and file formats for the harness. All JSON, all on disk, so any
agent (or human) can audit or resume a run. Sections 2–4 have
machine-checkable versions in `../schemas/` — the orchestrator validates
every supervisor/verifier reply against them and bounces malformed output
back (parse error + schema) for up to 2 retries before marking the module
`failed`.

## 1. Escalation rules (who answers what)

| Level | May decide alone | Must escalate up |
|---|---|---|
| Worker / supervisor internal loop | Implementation details: naming, library choice within stated stack, code structure, test style | Anything in the next column |
| Module Supervisor | Module-internal tradeoffs consistent with intent; recoverable errors (retry, alternate approach) | Contradicts stated intent; needs credentials/secrets/access; destructive or hard to reverse; changes module scope or interfaces other modules depend on; 5 internal iterations without convergence |
| Orchestrator | Anything answerable from the plan, prior decisions, the codebase, or a quick check; cross-module sequencing; relaxing a criterion that was orchestrator-authored | Taste/preference forks; scope changes vs. the original request; spending money / external side effects; conflicting user requirements; 3 supervisor↔verifier iterations without convergence |
| User | Everything | — |

Two invariants:

- **No silent guesses.** Every decision made on the user's behalf is logged in
  `state.json.decisions` and reported at the end.
- **Non-blocking questions never stop work.** Mark `blocking: false`, continue,
  batch for later.

## 2. Escalation object

```json
{
  "id": "esc-3",
  "module": "auth-api",
  "type": "question | blocker | suggestion",
  "blocking": true,
  "question": "Sessions table conflicts with existing `sessions` used by analytics. Rename ours or merge?",
  "context": "Migration 0042 would collide. Analytics reads sessions.id hourly (cron/rollup.ts:18).",
  "options": [
    { "label": "Rename ours to auth_sessions", "consequence": "No analytics impact; slightly longer name." },
    { "label": "Merge into existing table", "consequence": "One table, but analytics schema changes and backfill needed." }
  ],
  "recommendation": "Rename ours to auth_sessions",
  "resolution": null,
  "resolved_by": null
}
```

`resolution` / `resolved_by` (`"orchestrator"`, `"user"`, or `"memory"` when
a recalled memory pre-answers it) are filled in when answered, then the
object is appended to `state.json.escalations`.

## 3. Supervisor result (final message of every supervisor agent — JSON only)

```json
{
  "module": "auth-api",
  "status": "done | needs-input | blocked | failed",
  "summary": "Implemented login/logout/refresh endpoints with rate limiting.",
  "artifacts": ["src/auth/routes.ts", "src/auth/session.ts", "test/auth.test.ts"],
  "criteria": [
    { "criterion": "npm test exits 0", "met": true, "evidence": "42 passed, 0 failed" },
    { "criterion": "POST /login returns 429 after 5 bad attempts", "met": true, "evidence": "test/auth.test.ts:88 asserts this; passes" }
  ],
  "decisions": [
    { "what": "Used httpOnly cookies over Authorization header", "why": "Existing frontend fetch layer has no auth-header plumbing" }
  ],
  "escalations": [],
  "iterations_used": 2
}
```

`needs-input` = stopped on a blocking escalation, partial work saved.
`blocked` = external impediment (missing dep, broken env).
`failed` = exhausted internal iterations; include best diagnosis in `summary`.

## 4. Verifier verdict (final message of every verifier agent — JSON only)

The verifier is prompted to **refute** completion, gets only the module goal,
criteria, and artifact list — not the supervisor's reasoning.

```json
{
  "module": "auth-api",
  "verdict": "pass | fail",
  "criteria": [
    { "criterion": "npm test exits 0", "met": true, "evidence": "ran it: 42 passed" },
    { "criterion": "POST /login returns 429 after 5 bad attempts", "met": false, "evidence": "Test exists but rate limiter is per-process; restarting resets the counter. Criterion as written technically passes the test but not the behavior." }
  ],
  "additional_findings": ["session.ts:71 token compare is not constant-time"]
}
```

On `fail`, the orchestrator forwards `criteria` (failed ones) +
`additional_findings` to the supervisor via SendMessage as the next
iteration's input.

## 5. `state.json`

```json
{
  "run": "add-auth-2026-06-10",
  "intent": "One-paragraph restatement of the user's goal and what done looks like.",
  "created": "2026-06-10",
  "mode": "full | lite",
  "paused": false,
  "budget": {
    "max_parallel_supervisors": 4,
    "max_total_agents": 30,
    "agents_spawned": 0,
    "cost_ceiling_usd": null,
    "deadline_minutes": null,
    "tokens_estimated": null,
    "confirm_mode": "always | over-threshold | autopilot",
    "confirm_over_tokens": 60000,
    "on_exhausted": "pause-and-ask"
  },
  "modules": [
    {
      "id": "auth-api",
      "goal": "Login/logout/refresh endpoints with rate limiting",
      "deps": ["db-schema"],
      "criteria": ["npm test exits 0", "POST /login returns 429 after 5 bad attempts"],
      "open_questions": ["Cookie vs header auth?"],
      "status": "pending | ready | running | verifying | done | blocked | failed",
      "attempts": 0,
      "agent_id": null,
      "dispatched_at": null,
      "stale_after_minutes": 10,
      "last_result": null
    }
  ],
  "decisions": [
    { "id": "dec-1", "what": "...", "why": "...", "by": "orchestrator | user | memory", "module": "auth-api", "memory_id": null }
  ],
  "escalations": []
}
```

## 6. Agent files (the filesystem message bus)

Sub-agent liveness and results never depend on the host's agent-tracking.
Each agent maintains two files under `.genie/<run>/agents/`:

- `<module>.status.json` — heartbeat, overwritten each internal iteration:
  `{"iteration": 2, "phase": "self-check", "note": "criterion 3 failing, fixing"}`
  The orchestrator's watchdog compares the file's mtime against the
  module's `stale_after_minutes`; a stale file means a lost agent →
  re-dispatch once (work is resumable by contract), then synchronous
  fallback for verifiers.
- `<module>.result.json` — the final result JSON, written immediately
  before the agent's final message. **Authoritative over the return
  channel**: if the channel is silent or disagrees, use the file. Verifiers
  write `<module>.verdict.json` the same way.

The run dir also holds `events.jsonl` — the orchestrator appends one line
per transition (`{"ts", "event", "module", "detail"}`): the replayable
timeline for resume, retro, and dreams. And `run.lock` at the project's
`.genie/` root holds the active run slug so concurrent orchestrators
on one project refuse to start (stale locks may be taken over, logged).
Module objects in `state.json` carry `tokens_used` (from agent usage
reports); the ledger line carries the run total as `tokens`.

## 7. `plan.md` skeleton

```markdown
# Run: <run-slug>
## Intent
<one paragraph + "done looks like">
## Modules
| id | goal | deps | acceptance criteria | risks/open questions |
|---|---|---|---|---|
## Dependency order
<topological order, noting which modules run in parallel>
## Verification strategy
<per-module verifier approach + integration checks>
```
