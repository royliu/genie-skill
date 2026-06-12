#!/bin/sh
# state.sh RUN_DIR MODULE STATUS [TOKENS] [EVENT] [DETAIL]
# One call = state.json module update + events.jsonl append.
# MODULE "-" skips the module update (run-level events).
RUN_DIR=$1; MODULE=$2; STATUS=$3; TOKENS=${4:-}; EVENT=${5:-$STATUS}; DETAIL=${6:-}
if [ "$MODULE" != "-" ]; then
python3 - "$RUN_DIR" "$MODULE" "$STATUS" "$TOKENS" <<'EOF'
import json, sys
rd, mod, st, tok = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
p = f"{rd}/state.json"
s = json.load(open(p))
for m in s["modules"]:
    if m["id"] == mod:
        m["status"] = st
        if tok:
            m["tokens_used"] = int(tok)
json.dump(s, open(p, "w"), indent=2)
EOF
fi
printf '{"ts":"%s","event":"%s","module":"%s","detail":"%s"}\n' \
  "$(date +%FT%H:%M)" "$EVENT" "$MODULE" "$DETAIL" >> "$RUN_DIR/events.jsonl"
