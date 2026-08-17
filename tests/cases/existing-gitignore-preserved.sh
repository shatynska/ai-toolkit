#!/usr/bin/env bash
# Scenario: An existing ignore file is preserved exactly.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
printf 'node_modules/\n*.log\n' > .gitignore
sum_before="$(md5sum .gitignore | awk '{print $1}')"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_unchanged "$work/.gitignore" "$sum_before" "byte-for-byte unchanged"
assert_contains "$report" "ignore file: already present" "presence reported"
