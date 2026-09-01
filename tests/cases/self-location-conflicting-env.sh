#!/usr/bin/env bash
# Scenario: Fragments come from the copy the script belongs to.
# The script must ignore AI_TOOLKIT_ROOT entirely and always read fragments
# relative to its own invocation path — proven here by pointing the env var
# at a decoy toolkit with a fabricated, distinguishable version number while
# invoking the REAL script directly by path.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

decoy="$TESTDIR/decoy-toolkit"
mkdir -p "$decoy/rules"
cat > "$decoy/rules/development-workflow.md" <<'DECOY'
---
kind: standing-constraint
version: 999
---

# Decoy fragment — must never be read by a script invoked from elsewhere.
DECOY

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
AI_TOOLKIT_ROOT="$decoy" bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"

if grep -q "version 999" "$report"; then
  echo "FAIL: the script read the decoy toolkit's fragment via AI_TOOLKIT_ROOT — it must self-locate, not consult the environment" >&2
  exit 1
fi
assert_contains "$work/AGENTS.md" "v$(fragment_version)" "the real fragment's version was inlined, not the decoy's"
