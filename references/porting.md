# Orchestrate — running this harness outside Claude Code

The harness is host-agnostic: it needs only (a) some way to run focused
sub-sessions, (b) some way to ask the user a question, (c) file read/write.
SKILL.md + escalation-protocol.md define the behavior; this file maps the
three capabilities onto common hosts.

## Capability mapping

| Harness concept | Claude Code | OpenClaw | Codex CLI | Bare/single-agent host |
|---|---|---|---|---|
| Install | `~/.claude/skills/genie/` | `~/.openclaw/skills/genie/` (or workspace `skills/`) — same SKILL.md format | Paste SKILL.md body into `AGENTS.md` or a custom prompt in `~/.codex/prompts/genie.md` | Prepend SKILL.md to the system/first prompt |
| Module Supervisor | Agent tool (`run_in_background`, worktree isolation) | sessions_spawn / sub-agent tool | `codex exec "<supervisor prompt>"` as a subprocess, one per module (parallelize via shell `&`) | Sequential: orchestrator plays each supervisor role one module at a time, in dependency order |
| Reply to a waiting supervisor | SendMessage to agent id | session message to the spawned session | Re-invoke `codex exec` with prior context: pass the result JSON + the answer in the prompt (or `codex exec resume <session>`) | N/A — same context |
| Independent Verifier | Fresh Agent call | Fresh sub-session | Fresh `codex exec` with ONLY goal+criteria+artifacts (omit supervisor reasoning) | Fresh "verifier hat" turn that re-runs the checks mechanically; weaker than a truly fresh context — prefer a new session if the host allows |
| Ask the user | AskUserQuestion | Ask in the channel (Telegram/Discord/etc.), batched | Print batched questions, exit loop, wait for next invocation | Print and wait |
| State | `.genie/<run>/state.json` + `plan.md` | same | same | same |

`state.json` is what makes the degraded modes workable: any host that can
read it can pick up the run mid-flight, because module status, decisions,
and unresolved escalations are all on disk rather than in any one context.

## Cross-host hybrid (mixing agents)

Because supervisors communicate only via the result/escalation JSON and the
state file, supervisors don't all have to be the same agent. Practical mixes:

- Claude Code orchestrator dispatching a module to Codex:
  `codex exec --json "<supervisor contract + module spec>"` from Bash, parse
  the final JSON like any supervisor result.
- Use a second-opinion agent as the Verifier (e.g. codex verifying a
  Claude-built module) — cheap diversity that catches same-model blind spots.

The only hard requirements on a foreign supervisor: it receives the
supervisor contract verbatim, and its final output is exactly the result
JSON from escalation-protocol.md section 3.

## OpenClaw / Hermes operations

The pieces Claude Code's harness provides invisibly that you must do
explicitly when the host is OpenClaw or Hermes.

### Progress & notifications

There is no live progress tree, so the channel (Telegram / Discord /
WhatsApp / etc.) is the UI:

- Post a compact one-line-per-module status table on every module status
  change; for long quiet stretches, a heartbeat at most every ~15 minutes.
- Proactively ping the user on exactly three events: **escalation batch
  ready**, **run complete**, **run stalled**. Nothing else — a noisy
  channel trains the user to ignore it.
- Treat any "status" message from the user as a request to render
  `state.json` as that table immediately.

### Budget & concurrency defaults

OpenClaw sub-sessions are heavier than Claude Code subagents — default
`state.json.budget` to `max_parallel_supervisors: 3`,
`max_total_agents: 30`. When a ceiling is hit: pause dispatching, post
status, ask the user. Never silently continue past a budget. Model
tiering applies here too: if the deployment exposes per-session model
selection, run docs/config supervisors and checklist verifiers on the
cheaper tier — it's the single biggest lever on the harness's cost
overhead (~30–40% of a typical run is tierable work).

### Unattended safety — containment, not interception

Most OpenClaw installs have no permission layer between the agent and the
machine, and you cannot intercept a sub-agent's commands without host
hooks — so don't try; change where it runs. Two layers, mirroring Claude
Code's prompt + permission split:

1. **Behavioral brake**: the supervisor contract's "destructive ops are
   ALWAYS a blocking escalation" rule. Never weaken it for convenience.
2. **Physical brake**: run supervisors as a non-admin user, or in a
   container/devcontainer with only the project directory mounted
   writable, e.g.
   `docker run --rm -v "$PROJECT":/work -w /work --network host <agent-image> <supervisor-cmd>`
   (drop `--network host` too if modules don't need the network). Keep
   prod credentials out of the runtime environment unless a module's spec
   explicitly needs them; never bake them into the image.

### Sub-session reliability — the filesystem is the message bus

Host agent-tracking (notifications, session handles) is the least reliable
part of every host, OpenClaw and Claude Code alike. The harness therefore
never depends on it: supervisors heartbeat to
`.genie/<run>/agents/<module>.status.json` and write results to
`<module>.result.json` (protocol doc §6), and the orchestrator polls files
with a staleness watchdog. On OpenClaw this also means any process that
can read the run directory can answer "status" — a cron one-liner can post
the table to your channel without waking the orchestrator. Lost agent →
re-dispatch once from the same self-contained prompt; lost verifier twice
→ orchestrator runs the checklist synchronously.

### Worktree recipe (parallel file-mutating modules)

No `isolation: "worktree"` parameter exists here — do it with git:

```bash
# at dispatch, per parallel module that mutates files:
git worktree add .genie/<run>/wt/<module-id> -b orch/<run>/<module-id>
# the supervisor works ONLY inside that directory

# after that module's verifier passes (merge ONE module at a time):
git checkout <base-branch>
git merge --no-ff orch/<run>/<module-id>
git worktree remove .genie/<run>/wt/<module-id>
git branch -d orch/<run>/<module-id>
```

A merge conflict is a blocking escalation to the orchestrator (resolve it or
dispatch a rebase task) — never let a supervisor resolve a conflict against
another module's verified work. Add `.genie/` to `.gitignore`.

### Skill amendments → route through Skill Workshop

OpenClaw ≥ 2026.6.1 ships Skill Workshop: a governed proposal lifecycle for
skill changes (pending → apply/reject/quarantine, scanner checks, content
hashes, rollback metadata, approval prompts). On these hosts the
self-improvement amendment protocol (self-improvement.md) MUST use it as
the write path: instead of presenting a diff in chat and editing files on
approval, call the `skill_workshop` tool to create/update a proposal whose
body is the amended skill content and whose description cites the source
memory id and evidence runs from the ledger. Never write or edit skill
files directly on these hosts — Workshop's tool gate, scanner, and
rollback then physically enforce what the protocol's human gate can only
request. The one-proposal-per-run cap and amendment-proof safety zones
still apply on top. (On hosts without Workshop, the chat-approval path in
self-improvement.md remains the fallback.)

### Memory store

Identical on every host — plain files per
[memory.md](memory.md). The global store (`~/.genie/memory/`) is
shared across hosts on the same machine, so a preference learned during a
Claude Code run pre-answers escalations in OpenClaw runs and vice versa.

## Single-agent degradation rules

When the host has no sub-agents at all, the hierarchy collapses but the
discipline survives:

1. Still write `plan.md` + `state.json` before any work.
2. Work modules strictly one at a time, in dependency order, updating
   `state.json` between modules — never interleave.
3. Verification = a separate, later pass that re-runs every criterion
   command from scratch and trusts nothing remembered from the build pass.
4. Escalation = the same two-tier filter: questions answerable from
   plan/decisions/code get decided and logged; the rest are batched and
   asked at module boundaries, not mid-module.
