#!/usr/bin/env bash
# Scenario: implicit in "Every run ends in one of three outcomes" — a
# command genuinely missing (not merely failing) for a concern that is
# still outstanding must block, with nothing attempted.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Build a PATH with git available but openspec genuinely absent (not
# stubbed-to-fail — actually missing from PATH resolution).
filtered_path="$(echo "$PATH" | tr ':' '\n' | grep -v npm-global | paste -sd: -)"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
PATH="$filtered_path" bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 2 "$status" "BLOCKED — specification tooling is outstanding and its command is missing"
assert_contains "$report" "Outcome: BLOCKED"
assert_file_absent "$work/.git" "no filesystem change was attempted at all"
assert_file_absent "$work/openspec" "no filesystem change was attempted at all"
