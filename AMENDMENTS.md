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

## 2026-06-11 — gbrain adoptions (user-directed; ideas imported from garrytan/gbrain)

Six design ideas adopted from gbrain, infrastructure deliberately not:
- **Mechanical auto-linking at distill** (typed edges, zero judgment):
  same-source_run siblings get `derived-from`; UPDATEs record `supersedes`;
  AMENDMENTS entries cite promoted memories as `[[id]]`.
- **Gap-aware recall**: recall ends with a known/unknown split; uncovered
  forks are named explicitly and become the escalation candidates.
- **Salience tracking**: `times_applied` counter; recall increments,
  dreams prune by disuse and protect load-bearing memories.
- **Git as system of record**: setup offers `git init ~/.genie`
  (versioned beliefs, diffable dreams, sync = pull); amendment-bundle
  imports content-hashed to short-circuit re-review.
- **`know <topic>` mode**: two-tier query (composed answer with memory/
  ledger citations + honest gaps), no agents, no run.
- **gbrain bridge documented as the scale exit ramp** (>~50 memories/
  namespace → index the store into gbrain; markdown stays authoritative).
Rejected: vector/hybrid search and schema packs (wrong scale for a
curated ≤50/namespace store). Provenance: user statement.

## 2026-06-11 — startup weight loss (user-directed)

- User reported genie on OpenClaw "burns tokens from the get-go before
  delivering anything." Measured causes and fixes:
  frontmatter description 1,192 → 370 chars (injected into EVERY OpenClaw
  prompt); SKILL.md ~5.8k → ~3.7k tokens (-37%, re-carried per turn of a
  run) via a compression pass with zero rules removed; new **token
  discipline** block (never preload references — each phase/mode reads
  only its own doc at the moment of need; pre-quote work limited to
  memory indexes + a project listing + two small file writes); the
  state.json skeleton inlined so escalation-protocol.md is no longer a
  mandatory 1.8k read per run; porting.md gains an OpenClaw token-budget
  note. Provenance: user statement.

## 2026-06-11 — SkillOpt adoptions (user-directed; ideas imported from microsoft/SkillOpt)

- **Amendment efficacy tracking**: every proposal names a target ledger
  metric + expected direction; AMENDMENTS entries carry
  `efficacy: pending|validated|refuted`; retros (new rubric item 7) and
  dreams audit pending entries against the ledger; refuted → rollback
  proposal through the normal gate. Improvements are claims that re-earn
  their place — closes the "who verifies the improvements?" hole.
- **Rejected-edit buffer**: `~/.genie/dreams/rejected.md` logs rejected
  and refuted proposals with reasons; dreams/retros consult it before
  drafting; re-proposal requires new evidence.
- Considered and NOT adopted: SkillOpt's optimizer-model training loop
  (epochs/batches over scored benchmarks) — genie improves from real
  work, not synthetic rollouts; no benchmark score function exists for
  the user's actual tasks. Convergences noted for the record:
  SkillOpt-Sleep ≈ dream mode; their 300–2k-token artifact cap
  corroborates [[watch-always-loaded-weight]]. Provenance: user statement.

## 2026-06-11 — efficacy data (retro, run bookmarks-api-2026-06-11)

- **Cost preflight** (target metric: estimate accuracy): first live audit —
  quoted 53–98k (center 75k), actual subagent tokens 84,104: IN RANGE,
  +12% over center. One clean hit; `efficacy: pending` until a second run
  confirms (two-confirmation discipline).
- **Concurrence gate** (target: no unapproved spend): held twice this
  session, including once when conversational momentum assumed results
  existed. Behavioral validation; `efficacy: pending` formally, working
  observably.

## 2026-06-11 — sequential-chain continuation + tiering teeth (user-directed)

- User: run-4 full mode at 2.3x native is too expensive. Root cause from
  the ledger: context duplication across sequential agents (cli-docs 47k
  re-learned what api-core knew; one module ~= one whole native run).
  Changes (target metric: `tokens` on the next sequential full run,
  expect ~1.4-1.5x native; efficacy: pending):
  (1) Dispatch rule: agent count = parallel tracks — sequential chains
  share one continued supervisor with verification gates between modules;
  (2) contract: command-shaped criteria self-checked ONCE (orchestrator
  re-runs them anyway — double verification was paid at agent prices);
  (3) model tiering hardened from optional to default-with-logged-
  deviation (run 4's orchestrator skipped it; rule lacked teeth).
  Source memory: [[sequential-chains-one-agent]]. Provenance: user
  statement + retro-analysis.

## 2026-06-11 — v1.12.0: version discipline + startup announcement (user-directed)

- **VERSION file** (semver + latest-improvement one-liner): minor bump per
  applied amendment, patch for efficacy/doc updates — the version number
  is the public self-improvement counter. Retroactive count: v1.0.0 =
  initial publication; 12 minors = the evolution events logged above.
- **Startup announcement**: every invocation opens with
  "🧞 Genie vX.Y.Z — latest self-improvement: <one-liner>" (one tiny file
  read; token-discipline compliant). Self-improvement stays visible to
  the user instead of buried in the changelog. Provenance: user statement.

## 2026-06-11 — v1.13.0: second-tier token optimizations (user-directed)

- Target metric: `tokens` + orchestrator overhead on future runs;
  efficacy: pending. (1) `scripts/state.sh`: one-call state transition +
  event append, replacing inline Python heredocs (~75% less orchestration
  chatter, ~3-6k/run); (2) contract: batch shell into compound commands
  (run-4 supervisors averaged 17 tool round-trips), result brevity caps
  (summary ≤2 sentences, ≤5 decisions); (3) setup creates shared
  `~/.genie/venv` so runs stop re-installing pytest. Honest note: this
  approaches the floor — remaining cost is the guarantees themselves.
  Provenance: user statement.

## 2026-06-12 — v1.14.0: stakes-weighted inquiry + audit mode (user-directed)

- User: run-5 inquiry at 3.8x tokens / ~6x wall is unacceptable. Ledger
  root cause: UNIFORM RIGOR — red-team (64.6k, 55% of run) attacked all
  claims equally; provenance ceremony applied to every claim. Changes
  (target metrics: next inquiry run `tokens` <=2.4x native, draft
  delivered at native-comparable wall time; efficacy: pending):
  (1) load-bearing-claims enumeration — full ceremony + hard attack on
  the 3-6 claims the money rests on, spot-checks elsewhere;
  (2) progressive delivery — draft ships when research verifies, red-team
  runs concurrently, verdict lands as addendum;
  (3) new `audit` mode — red-team any existing analysis standalone
  (~30k): pay for verification only when about to act. Run-5 evidence
  that the attack is where inquiry value concentrates: it refuted the
  $52k anchor that the native arm shipped as its highest-conviction zone.
  Source memory: [[inquiry-agents-cost-more]]. Provenance: user statement
  + retro-analysis.

## 2026-06-12 — v2.0.0: the deletion release (user-approved; reviewed by Claude Code's native harness)

- Two independent native-harness reviewers (architecture critic +
  minimalist) audited genie against its own usage evidence (5 runs, 7
  memories). Convergent verdict: core (~40%) earned and validated; ~60%
  speculative protocol that had never fired. User approved the cut.
- DELETED: dream subsystem (dreaming.md, dream-guard.sh, cron, lock,
  retention — replaced by one consolidation trigger in the distill pass);
  agent-exchange protocol (re-add when a second agent exists; all real
  imports arrived via user statement); typed link relations, salience
  ceremony, topology heuristics (plain [[id]] mentions remain); know
  mode (behavior = answering from memory, needs no mode);
  events-consumers claims fixed (state.sh still writes events.jsonl —
  minimalist kept it); over-threshold confirm mode; deadline descoping;
  rejected-edit buffer (referenced a file that never existed);
  escalation-protocol.md, self-improvement.md, inquiry.md dissolved into
  SKILL.md/schemas/memory.md. Protocol: 71KB → 16KB (-77%).
- ADDED: validation-debt brake — no new optimization amendment while >2
  prior are efficacy-pending (reviewer: "the loop ships 3x faster than
  it validates"). Schemas/ made the single source of truth for result
  shapes (the schema-drift fix had added a copy instead of removing one).
- KEPT against reviewer advice, with cause: the version banner (minimal
  form) — explicit user request outranks reviewer taste, per the
  provenance hierarchy. audit mode kept (architect: EARNED, run-5
  evidence). Every deleted mechanism is re-derivable by the same
  evidence process when its trigger first actually occurs.
- Efficacy status of this amendment: its target metric is the protocol
  itself — measured: -77% protocol mass, zero guarantees lost.

## 2026-06-12 — v2.0.1: efficacy audit (retro, run predmarket-research-2026-06-12)

- **Cost preflight → `efficacy: validated`**: 2 in-range quotes of 3
  (run-4 hit, run-5 miss root-caused into the task-type constant, run-6
  hit using that correction: quoted 95–175k, actual 113.1k).
- **v1.14 stakes-weighted token target → `efficacy: refuted`**: actual
  3.4x native vs ≤2.4x target. Mechanism retained (harmless, focused the
  attack — all 6 claims still verified at 61.8k vs run-5's 64.6k for
  broader scope) but the COST CLAIM is dead: multi-source live
  verification is irreducibly ~55–65k/agent. Inquiry floor ≈ 3–3.5x
  native when claims need web corroboration; the cost levers for inquiry
  are lite (no red-team) and audit mode (verification only), not thinner
  full mode. **Progressive delivery → validated** (draft delivered
  before verdict, both runs).
- Memory [[inquiry-agents-cost-more]] promoted to STANDING (2nd
  confirmation: 56.5k/agent).

## 2026-06-12 — v2.1.0: procedural memory / task templates (user-directed; ideas imported from NousResearch/hermes-agent)

- Hermes' core idea adopted with genie gates: experience is generative —
  completed task patterns become reusable procedure. Templates
  (~/.genie/templates/) hold proven decomposition + criteria + pre-made
  decisions; the retro distills one when a run shape repeats (2nd
  occurrence); triage auto-applies matches (cited in the quote,
  vetoable); deviations update the template; standing templates may
  GRADUATE to standalone skills — user-approved, Skill Workshop on
  OpenClaw. Generation autonomous, publication gated. Plus experience
  search: run dirs are the corpus, grep past plans for similar intents.
  Evidence: runs 1–3 were the same shape, re-planned from scratch 3x —
  first template (small-python-cli) seeded standing from them.
  NOT adopted: hermes' ungated autonomous skill creation; Honcho user
  modeling; periodic nudges (= dreams; convergence noted — 3rd sibling
  after SkillOpt-Sleep and Claude Dreaming — trigger still unfired).
  Target metric: planning tokens + escalations on the next
  template-matched run; efficacy: pending. Provenance: user statement.

## 2026-06-12 — v3.1.0: ambient mode — passive distill from host sessions (user-directed)

- User directive: make genie ambiently self-improve the host (OpenClaw)
  the way hermes does. This is the documented re-add trigger firing for
  the dream subsystem deleted in v2.0.0 ("re-derivable by the same
  evidence process when its trigger first actually occurs") — re-added
  in scoped form: a bounded distill pass, not the full dreams machinery.
- **New `ambient` mode** (references/ambient.md): host heartbeat/cron
  fires `genie ambient`; the pass scans NEW host-session transcript
  content since a watermark, detects hermes-taxonomy signals (repeated
  workflow, correction, stated preference, hard-won fact, ≥5-tool-call
  success), and persists through the existing memory/template lifecycle.
  Closes the one structural gap vs hermes (invocation-gated vs ambient
  learning) while keeping the gates hermes lacks: trust boundary at
  distill (third-party transcript content NEVER distills — standing
  prompt-injection defense), tentative→standing two-confirmation,
  user-gated skill publication.
- **Cost discipline (KPI-compliant)**: ≤10k tokens/pass hard cap, <1k
  silent pass when nothing is new, no agents, no web, read+distill only,
  concurrency lock. Silent unless something was learned (one-line report
  with the "forget that" veto). Every pass appends a `mode: "ambient"`
  ledger line.
- porting.md gains the wiring: OpenClaw transcript paths + cron/
  HEARTBEAT.md recipes; Claude Code via /loop or /schedule.
- Target metrics: ≥1 memory or template per week distilled from
  NON-genie sessions (the loop is live); first triage hit on an
  ambiently-learned template (the loop pays); ambient pass cost within
  caps on the ledger. Efficacy: pending. Provenance: user statement.

## 2026-06-12 — v3.0.0: autonomous self-improvement, KPI declaration, autopilot default (user-directed)

- User directive: "make genie improve faster and autonomously; speed and
  token efficiency are top KPIs; reduce user approval unless really
  necessary — this is acceptable." Major bump: this changes approval
  gates and the autonomy boundary, both previously immutable-by-default.
- **KPI declaration (prime directive 4)**: wall-clock speed + tokens are
  the top-2 ledger metrics; every optimization amendment targets one.
  Quality guard: verifier escapes must not rise — a cost win that raises
  escapes counts as a regression (prevents metric tunnel-vision; escapes
  already ledger-tracked, 0 across runs 1–7). Ledger line gains
  `wall_minutes` so the speed KPI is measured, not vibes.
- **Autonomous amendment lane**: optimization amendments (speed/token
  target, ledger-cited evidence, reversible) self-apply at retro — entry,
  VERSION minor bump, git commit + tag, announced in the run report with
  a one-line revert. `refuted` efficacy → AUTO-REVERT of that commit
  (rollback becomes mechanism, not proposal — adopts the one Hermes
  Curator strength genie lacked, via the git tags already present since
  v1.12). Validation-debt brake (>2 pending blocks new optimization
  amendments) RETAINED as the governor on the faster loop.
- **Still user-gated ("really necessary")**: weakening verification
  independence or safety rules, raising spend caps / loosening brakes,
  changing the autonomy boundary itself, publishing templates as skills,
  removing user-directed features.
- **`confirm_mode` default flipped `always` → `autopilot`** per standing
  user memory [[kpi-speed-tokens-autonomy]]. Brakes replace asks: budget
  caps + `hard_cap_tokens` (default 250k, ~2× the largest run to date)
  + pause at actuals >1.5× estimate. "Ask me again before runs" reverts.
  Supersedes the v1.x concurrence-gate default (the gate itself remains
  available, and the no-unapproved-spend guarantee is re-expressed as
  hard caps rather than a wait).
- **Escalation list narrowed**: taste calls are now orchestrator
  decisions (logged, vetoable in the report); only money, danger/
  irreversibles, credentials, and genuine scope changes escalate.
  Inquiry user-parameters: recall from memory or proceed on flagged
  assumptions instead of blocking asks.
- **Triage tie-breaker**: equal guarantees → KPIs decide the mode.
- Target metrics: user asks per run (expect →0 for in-scope runs),
  wall_minutes vs same-shape priors, amendment cycle time (proposal →
  applied). Efficacy: pending. Provenance: user statement.

## 2026-06-12 — v2.1.1: experience-search trust boundary (self-caught)

- v2.1.0's experience search allowed grepping run REPORTS, which contain
  synthesized third-party content — a provenance-boundary bypass.
  Restricted to orchestrator-authored artifacts only (plan.md,
  state.json decisions). Caught in the hermes-comparison review, one day
  after introduction. Provenance: retro-analysis.
