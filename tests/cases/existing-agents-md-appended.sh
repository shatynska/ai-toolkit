#!/usr/bin/env bash
# Scenarios: An existing conventions file receives only the managed block;
# Project content below the block survives (including across a repeated run).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
cat > AGENTS.md <<'PROJECT'
# My Project

Some project-specific conventions the tool must never touch.
PROJECT
report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_contains "$work/AGENTS.md" "Some project-specific conventions the tool must never touch." "original content survives"
assert_contains "$work/AGENTS.md" "ai-toolkit:development-workflow" "block appended"
assert_contains "$report" "conventions file: block appended" "reported as appended"

# Run again: original content must still be present, unmodified.
bash "$PROJECT_INIT" >"$TESTDIR/report2.txt" 2>&1
assert_contains "$work/AGENTS.md" "Some project-specific conventions the tool must never touch." "survives a second run"

# Exactly one opening marker — the block was not duplicated.
count="$(grep -c '<!-- ai-toolkit:development-workflow' "$work/AGENTS.md")"
if [ "$count" != "1" ]; then
  echo "FAIL: expected exactly one managed block marker, found $count" >&2
  exit 1
fi
