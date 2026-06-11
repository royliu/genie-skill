# Genie — inquiry mode (research, analysis, strategy, thinking)

Genie is not only for building artifacts. An **inquiry** produces a
defensible answer — and *defensibility is verifiable even when truth
isn't*. Do not decline a task for being research-shaped; decline only
single-pass questions a native answer serves better ("what's X's price").
A multi-angle question with stakes is a genie task.

## Decomposition: modules are angles, not components

- **Research question** → one module per investigative angle (different
  sources/methods per module, so they fail independently) → an
  **adversarial red-team module** → a synthesis module.
- **Strategy / decision** → evidence modules (current state, data,
  constraints) ∥ option-generation → red-team that tries to break each
  option → synthesis with a recommendation.
- **Analytics** → data modules (criteria: queries reproducible, totals
  reconcile) → interpretation → review.

3–6 modules typical. **The red-team module is inquiry's pytest** — a
fresh agent whose only job is to attack the emerging conclusions. Lite
mode applies as usual: small inquiry = one researcher + one refuting
verifier.

## Acceptance criteria: provenance, not truth

A verifier cannot check "the analysis is correct." It can check:

- every factual claim cites a source; load-bearing claims cite ≥2
  independent sources
- every number traces to a named query/dataset/document, with its date
- counter-evidence was explicitly searched; the report has a "what would
  change this conclusion" section
- every sub-question from the plan is addressed or explicitly marked
  unanswerable
- sources resolve (mechanical) and fall within a stated freshness window
- recommendations state their assumptions and invalidation conditions
  ("this is wrong if X happens")
- each conclusion carries a confidence label

## Verification

- **Mechanical (orchestrator, zero agent cost):** links resolve, dates in
  window, required sections present, numbers internally consistent.
- **Judgment (fresh verifier, prompted to REFUTE):** find the weakest
  claim and attack it; hunt for disconfirming evidence the report missed;
  check that conclusions actually follow from the cited evidence, not
  past it. A fail returns specific holes, not vibes.

## Escalation: personal parameters are user-level forks

In inquiry, the things an agent must never guess are the user's
parameters, not the world's facts: **risk tolerance, time horizon,
budget, jurisdiction, and what the answer will be used for**. A trading
strategy delivered without asking the user's risk profile is a guess
wearing a report's clothing — batch these in Phase 0.

## Artifacts and memory

The deliverable is a file (`report.md` / `analysis.md`) with citations —
not chat prose. Distill afterwards as usual: source-quality lessons
("X's data lagged badly"), the user's analytical preferences (depth,
format, risk posture once stated), and durable domain facts.

## Composition

Module supervisors should use the host's research tools as tools — a
deep-research skill, web search, data APIs (e.g. crypto/market skills).
Genie's job is decomposition, adversarial verification, escalation, and
memory; the searching itself belongs to the best available tool.
