# 🧞 Genie

**State a wish. Get a verified result.**

Genie is a portable, self-improving multi-agent work harness packaged as a
single [Agent Skill](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) —
plain markdown and JSON, no framework, no server. Drop it into Claude Code,
OpenClaw, Codex CLI, or any SKILL.md-compatible agent and it turns that
agent into a delegation system that decomposes big tasks, loops until done,
verifies everything independently, and gets measurably better with every run.

```
You
 └─ Orchestrator            ← decomposes, dispatches, audits, reports
     ├─ Supervisor agents   ← one per work module, loop until done
     ├─ Verifiers           ← independent; self-reports never count
     └─ Integrator          ← cross-module verification at the end
```

## Why

Handing an agent a big task usually buys you a confident summary you then
have to re-audit yourself. Genie inverts that:

- **Nothing is "done" until independently verified.** Every acceptance
  criterion is re-executed by a verifier that didn't do the work — or by
  the orchestrator running the commands itself. The orchestrator's own
  final report is audited against the state files before delivery.
- **Questions travel up, not at you.** Worker → supervisor → orchestrator →
  you. Each level resolves what it can; you get one batched set of
  questions with recommendations, only for calls that are genuinely yours
  (taste, scope, credentials, destructive risk).
- **Every run is on disk.** Decisions with rationale, an event timeline, a
  resumable state file, per-module heartbeats and result files. Kill it
  mid-run, resume from any session — even a different agent.
- **It learns.** Escalation answers and run outcomes distill into a memory
  store, so repeat runs ask less. A run ledger tracks its own quality
  metrics (including *verifier escapes* — defects that got past a passing
  verdict). An idle-time **dream pass** consolidates memories and drafts
  improvements. Proven practices become amendments to the skill's own
  files — **only with your explicit approval**, logged in
  [AMENDMENTS.md](AMENDMENTS.md).
- **It right-sizes.** A triage gate declines tasks that don't need
  orchestration, runs small ones in lite mode (one supervisor, scriptable
  verification), and saves the full parallel machinery for work that earns
  it.

## Benchmarks (from the bundled ledger format, three real runs)

Same-class task, orchestrated arm vs. a plain single-agent control arm:

| | Run 1 | Run 2 | Run 3 (lite) | Native control |
|---|---|---|---|---|
| Agents | 6 | 5 | **1** | 1 |
| Tokens | ~158k | ~109k | **32.7k** | 37.6k |
| Questions to user | 0 | 0 | 0 | 0 |
| Unverified claims shipped | 0 | 0 | 0 | n/a (self-reported) |

Run 1 found the defects (schema drift, lost background agents); run 2
validated the fixes; run 3 hit cost parity with native while keeping
verification, audit, and memory. The improvements between runs were made
*by the harness's own retro → amendment loop*, human-approved.

## Install

**Claude Code**
```bash
git clone https://github.com/USER/genie ~/.claude/skills/genie
```

**OpenClaw / Hermes**
```bash
git clone https://github.com/USER/genie ~/.openclaw/skills/genie
```

Then, from your agent: `/genie setup` — creates the data stores
(`~/.genie/`), checks the dream guard, detects Skill Workshop, and prints
the one cron/heartbeat line that enables idle-time dreaming.

Other hosts (Codex CLI, single-agent setups): see
[references/porting.md](references/porting.md).

## Use

```
/genie build me a REST API for my notes app with tests, docs, and deploy config
```

Or just describe a big multi-part task — the skill's description triggers
on intent. Mid-run you can say `status`, `pause`, `skip <module>`,
`cancel`, or change scope in plain words; incomplete runs end with a
salvage report, not an apology.

Other modes:

- `/genie dream` — idle-time consolidation (normally fired by cron via
  `scripts/dream-guard.sh`, which makes idle checks token-free)
- `/genie setup` — install wiring and readiness check

## How it learns (and why that's safe)

```
run → retro (capture evidence) → memory (tentative → standing after a
2nd run confirms) → dream (consolidate, draft) → amendment (human gate)
→ better skill → next run
```

Hard bounds, by design: memories carry provenance and are quarantined if
they arrive instruction-shaped or unsourced (a poisoned memory is
persistent prompt injection — treated accordingly); third-party content is
never distilled directly; dreams may reorganize recorded evidence but never
invent facts and never write live; at most one amendment proposal per run,
never to safety rules or approval gates, applied only on explicit approval
(via OpenClaw's Skill Workshop where available). Destructive operations are
always blocking escalations, no matter how confident an agent is.

Best practices can travel between agents as evidence-cited amendment
bundles — and imported practices **re-earn standing locally** through the
receiving agent's own ledger before being trusted. Replication, not
gossip.

## Layout

```
SKILL.md                          the harness (this is what the agent runs)
AMENDMENTS.md                     evidence-cited changelog of self-improvements
schemas/                          JSON Schemas for all agent result formats
scripts/dream-guard.sh            token-free idle/novelty preflight for dreams
references/
  escalation-protocol.md          message formats, state files, decision rights
  memory.md                       recall / distill / consolidate + poisoning rules
  self-improvement.md             ledger, retro, amendments, agent-to-agent exchange
  dreaming.md                     idle-time consolidation protocol
  porting.md                      host mappings, ops recipes, containment
```

Run data lives outside the repo in `~/.genie/` (memory, ledger, dreams)
and per-project `.genie/` dirs (run state, events, locks).

## License

MIT
