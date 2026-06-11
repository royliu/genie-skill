#!/bin/sh
# dream-guard.sh — token-free preflight for genie dream mode.
# Exit 0 = clear to dream. Non-zero = busy or nothing to dream about.
# Wire it ahead of the agent invocation so the model only wakes when needed:
#   dream-guard.sh && <agent-cmd> "/genie dream"
#
# Override the scanned project roots with ORCH_PROJECT_ROOTS (space-separated).

ORCH="$HOME/.genie"
ROOTS="${ORCH_PROJECT_ROOTS:-$HOME/Projects}"

# 1. Another dream in progress? (stale locks >2h are ignored)
if [ -f "$ORCH/dream.lock" ] && find "$ORCH/dream.lock" -mmin -120 2>/dev/null | grep -q .; then
  echo "skip: dream already running" >&2; exit 1
fi

# 2. Any genie run active in the last 30 min? Active runs touch
#    state.json and agents/*.status.json constantly; silence = idle.
for root in $ROOTS; do
  if find "$root" -maxdepth 5 -path '*/.genie/*' \
       \( -name 'state.json' -o -name '*.status.json' \) -mmin -30 2>/dev/null | grep -q .; then
    echo "skip: active run detected under $root" >&2; exit 2
  fi
done

# 3. Already dreamed in the last ~20h?
if [ -f "$ORCH/last-dream" ] && find "$ORCH/last-dream" -mmin -1200 2>/dev/null | grep -q .; then
  echo "skip: dreamed recently" >&2; exit 3
fi

# 4. Anything new since the last dream? (ledger lines or memory changes)
if [ -f "$ORCH/last-dream" ]; then
  if ! find "$ORCH/runs.jsonl" "$ORCH/memory" -newer "$ORCH/last-dream" 2>/dev/null | grep -q .; then
    echo "skip: nothing new since last dream" >&2; exit 4
  fi
fi

exit 0
