#!/usr/bin/env bash
# Scenario: A project with only a CLAUDE.md.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
echo "@AGENTS.md" > CLAUDE.md
sum_before="$(md5sum CLAUDE.md | awk '{print $1}')"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_file "$work/AGENTS.md" "AGENTS.md created"
assert_contains "$work/AGENTS.md" "ai-toolkit:development-workflow" "block present"
assert_unchanged "$work/CLAUDE.md" "$sum_before" "CLAUDE.md not read into, written to, or modified"

# Already imports AGENTS.md, so no import-needed line should be printed.
if grep -q "Import needed:" "$report"; then
  echo "FAIL: CLAUDE.md already imports AGENTS.md, no import line should be reported" >&2
  exit 1
fi
