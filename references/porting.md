# Genie on other hosts (one page)

| Harness concept | Claude Code | OpenClaw / Hermes | Codex CLI | Single-agent host |
|---|---|---|---|---|
| Install | `~/.claude/skills/genie/` | `~/.openclaw/skills/genie/` (workspace `skills/` to scope per-agent; workspace wins on name collision) | SKILL.md body into `~/.codex/prompts/genie.md` | Prepend SKILL.md to the first prompt |
| Supervisor | Agent tool (background, worktree isolation) | sub-session spawn | `codex exec` subprocess per module | Orchestrator works modules sequentially, verification as a separate later pass |
| Reply to a waiting agent | SendMessage / respawn with carried contract | session message | `codex exec resume` or respawn | n/a |
| Ask the user | AskUserQuestion | channel message (batched) | print + wait | print + wait |
| State | `.genie/` files — identical everywhere | same | same | same |

**Token budget (the OpenClaw lesson):** the skill description is injected
into every prompt — keep it ≤~300 chars; SKILL.md rides every turn of a
run — keep it lean, use prompt caching where the deployment supports it;
references load only at the moment of need. "Burns tokens before
delivering anything" means a rule above is being violated.

**Containment, not interception (unattended safety):** you cannot
intercept a sub-agent's commands without host hooks. Two layers: the
contract's destructive-ops-always-escalate rule (behavioral), and running
supervisors as a non-admin user or in a container with only the project
mounted writable, secrets absent (physical). Never weaken either.

**Parallel file-mutating modules without native worktrees:**
`git worktree add .genie/<run>/wt/<module> -b genie/<run>/<module>`, the
supervisor works only there, merge one module at a time after its
verification passes; a merge conflict is a blocking escalation.

**Ambient mode wiring (ambient.md):** OpenClaw — session transcripts
live under the agent dir (typically
`~/.openclaw/agents/<agent>/sessions/*.jsonl`; confirm with
`openclaw --help` / the agent config); schedule via OpenClaw cron
(`openclaw cron add` with prompt `genie ambient`, every 6h) or one
HEARTBEAT.md line ("if >6h since the last `genie ambient` pass, run
it"). Claude Code — transcripts at
`~/.claude/projects/<project-dir>/*.jsonl`; schedule via the /loop or
/schedule skill. Hosts without cron: run `genie ambient` manually at
session end. The pass reads transcripts and writes only `~/.genie/` —
grant nothing else.

**Reliability:** host agent-tracking is the least reliable layer
everywhere. Heartbeat/result files + the watchdog (SKILL.md) are the
defense; any process that can read the run dir can answer "status".
