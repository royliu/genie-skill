# 🧞 Genie

**State a wish. Get a verified result. It gets better while you sleep.**

Genie is a portable, self-improving work harness packaged as a single
[Agent Skill](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) —
plain markdown and JSON, no framework, no server. Drop it into Claude Code,
OpenClaw, Codex CLI, or any SKILL.md-compatible agent and it turns that
agent into a trustworthy employee with a memory: it **quotes the cost and
dispatches on autopilot** (brakes, not asks), decomposes and
**independently verifies** everything it builds or researches, interrupts
you only for money, danger, or real scope changes, **learns passively
from your ordinary sessions** via dream mode, and **amends its own
playbook autonomously** — every change evidence-cited, version-tagged,
and auto-reverted if the ledger later disproves it.

```
You
 └─ Orchestrator            ← decomposes, dispatches, audits, reports
     ├─ Supervisor agents   ← one per work module, loop until done
     ├─ Verifiers           ← independent; self-reports never count
     └─ Integrator          ← cross-module verification at the end
```

## The thesis

Today's agents are amnesiacs with good intentions. Every session starts
from zero: the lesson learned at 2pm dies with the context window at 3pm,
the preference you explained on Monday gets asked again on Thursday, and a
mistake fixed on one machine is faithfully repeated on every other. The
industry's answer has been bigger context windows and better models —
making the amnesiac smarter, not curing the amnesia.

Genie's answer is three nested loops, each feeding the next:

1. **Trust** — within a run, nothing is done until independently verified.
   This is the foundation: an agent whose claims you can't trust has
   nothing worth remembering.
2. **Learning** — across runs *and across your ordinary sessions* (dream
   mode), verified outcomes and observed preferences distill into memory,
   reusable task templates, a quality ledger (including *verifier
   escapes* — defects that got past verification), and ultimately
   **amendments to the harness's own instructions**. The skill you run in
   month two is provably better than the one you installed — and every
   change carries its evidence, its target metric, and its rollback.
3. **Evolution** — across agents, proven practices travel as
   evidence-cited amendment bundles. The receiving agent doesn't take
   them on faith: every imported practice **re-earns standing locally**
   against its own ledger before being trusted. Knowledge propagates the
   way science does — by replication — not the way gossip does, by
   repetition.

## Loops all the way down

The central design primitive is not the agent — it's the **bounded loop**.
Every loop has a convergence test and a bound:

| Loop | Cycle time | Converges when | Bounded by |
|---|---|---|---|
| Worker self-check | seconds | own criteria self-pass | 5 internal iterations |
| Supervisor ↔ verifier | minutes | independent verifier passes | 3 rounds, then escalate |
| Run execution | hours | all modules verified + integrated | budget caps, watchdog |
| Dream (passive learning) | 6-hourly | new signals distilled or silence | ≤10k tokens/pass, trust boundary |
| Memory | days | eager-applied → standing (2nd confirmation or 7 unvetoed days) | provenance, "forget that" veto |
| Amendment | per retro | target metric validated on the ledger | validation-debt brake, auto-revert on refute |

Every layer's failure is the next layer's input, and the innermost rule
propagates all the way out: the same skepticism a verifier applies to a
worker's "done" is applied to a memory's "true," an amendment's "better,"
and an imported practice's "proven."

## Install

**Claude Code**
```bash
git clone https://github.com/royliu/genie ~/.claude/skills/genie
```

**OpenClaw / Hermes**
```bash
git clone https://github.com/royliu/genie ~/.openclaw/skills/genie
```

Then, in a session on that host:

```
genie setup
```

One command does everything: creates the data stores (`~/.genie/`),
offers git-versioning for the memory store, **installs the dream cron**
(passive learning every 6h, announced with its removal one-liner), runs
the first dream pass, and **wires a recall block** into the host's
AGENTS.md/CLAUDE.md so every future session starts with the memory index.
Each automated step is announced with its undo — brakes, not asks.

Other hosts (Codex CLI, single-agent setups): see
[references/porting.md](references/porting.md).

## How to use

**State a wish** — just describe a big multi-part task; the skill
triggers on intent:

```
genie: build me a REST API for my notes app with tests, docs, and deploy config
genie: research the best vector DB for my use case and recommend one
```

Genie recalls relevant memories, applies a proven template if the task
shape repeats, quotes the cost (±30%, with cheaper alternatives), and
dispatches immediately on autopilot. You'll be interrupted only if a
brake trips or a question is genuinely yours.

**All modes:**

| Say | Get |
|---|---|
| `genie: <wish>` | full orchestrated run: decompose → execute → verify → report |
| `genie audit <analysis>` | red-team an existing analysis without redoing its research (~30k) |
| `genie status` | dashboard: version, validation debt, last dream pass, memory census, runs |
| `genie know <question>` | any question over its memory/history, answered with citations |
| `genie dream` | manual passive-learning pass (the cron does this automatically) |
| `genie setup` | install wiring + readiness check (idempotent) |

**Mid-run steering:** `status` · `pause` · `resume` · `cancel` ·
`skip <module>` — or describe a scope change in plain words and it
re-plans with a cost delta. Incomplete runs end with a salvage report
(verified / unverified / not started), not an apology.

**Vetoes and reverts** (each one line, anytime):
- `forget that` — delete a memory it learned
- `ask me again before runs` — restore the ask-first concurrence gate
- `revert genie to vX.Y.Z` — roll back any self-amendment (git-tagged)

## Best practices

**Use genie when:**
- The task has **3+ verifiable pieces** — decomposition and parallel
  supervisors pay off
- **Being wrong is expensive** — research you'll act on with money or
  time; the red-team verification is the product
- **You'll walk away** — unattended runs are exactly what the brakes,
  watchdog, and resumable state are for
- **The task shape repeats** — the 2nd occurrence mints a template;
  the 3rd run is faster and cheaper than the 1st

**Skip genie when** it's a quick question or one-file edit — native chat
is cheaper, and genie's own triage will tell you so. Cost rule of thumb
from its ledger: lite mode ≈ native cost with verification added; full
mode ≈ 2.3× on builds, ~3× on inquiry — worth it only for parallel,
high-stakes, or unattended work. Dream mode needs nothing from you
either way; it learns from ordinary sessions regardless.

**Day-0 seeding (5 minutes, recommended):** state a preference or two in
plain chat ("from now on, always …"), then say `genie dream`. You'll see
it learn immediately, and the preference acts in your next relevant task
— flagged as INFERRED, vetoable with two words.

**Cap what you care about:** every brake is per-run overridable in plain
language — "hard cap 50k", "max 2 agents", "ask before dispatching this
one". Defaults: 250k hard cap, pause at 1.5× estimate, 4 parallel
supervisors, 3 verification rounds before escalation.

**Check in weekly:** `genie status` shows what it learned, what it
published, which self-improvements are still awaiting validation, and
the run ledger trend. The memory store is a valid Obsidian vault — open
`~/.genie/memory/` to *see* what your agent believes and why.

**Trust the trust boundary:** genie never distills third-party content
(web pages, API responses, other people's text) into memory — only your
words and its own verified decisions. If a "lesson" from a document
matters, confirm it once and it becomes a user-statement. This is the
one gate that never loosens, and only you can change it.

## How it learns (and why that's safe)

```
ordinary sessions ──→ dream (6-hourly distill) ──┐
                                                 ├─→ memory + templates
genie runs ──→ retro (evidence capture) ─────────┘        │
                                                          ▼
            every session recalls ←── store ←── eager belief (loud,
                                                vetoable, standing after
                                                2nd confirmation or 7
                                                unvetoed days)
retro ──→ self-amendment (speed/token-targeted, ledger-evidenced)
            → VERSION bump + git tag → validated or AUTO-REVERTED
```

Hard bounds, by design: memories carry provenance and arrive quarantined
if instruction-shaped or unsourced (a poisoned memory is persistent
prompt injection — treated accordingly); third-party content is never
distilled directly; eager-applied lessons are always announced and
vetoable; autonomous amendments are limited to speed/token optimizations
with named target metrics, blocked while >2 prior await validation, and
auto-reverted when refuted. Weakening verification independence, safety
rules, the trust boundary, or any brake **always requires the human** —
that list is itself amendment-proof. Destructive operations are always
blocking escalations, no matter how confident an agent is.

Skill publication is announce-gated: a template proven over ≥2 verified
runs publishes as a standalone skill with a one-line removal command,
and auto-retires after 30 days of zero use.

## Layout

```
SKILL.md           the harness (what the agent runs) — ~14KB
AMENDMENTS.md      evidence-cited changelog of every self-improvement
VERSION            semver + latest-improvement one-liner (shown at startup)
schemas/           JSON Schemas for agent results (single source of truth)
scripts/state.sh   one-call state transition + event logging
references/
  memory.md        recall / distill / eager belief / templates / trust boundary
  dream.md         passive learning pass: signals, watermark, hard rules
  porting.md       host mappings, recall wiring, containment, token budget
```

The version number is the public self-improvement counter — every minor
bump is a logged, evidence-cited amendment in
[AMENDMENTS.md](AMENDMENTS.md), and every version is a git tag you can
revert to. Run data lives outside the repo in `~/.genie/` (memory,
templates, ledger, dream state) and per-project `.genie/` dirs (run
state, events, locks).

## License

MIT
