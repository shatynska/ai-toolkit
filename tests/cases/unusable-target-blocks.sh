#!/usr/bin/env bash
# Scenario: An unusable target blocks.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

nonexistent="$TESTDIR/does-not-exist"
report="$TESTDIR/report.txt"

bash "$PROJECT_INIT" "$nonexistent" >"$report" 2>&1
status=$?

assert_exit 2 "$status" "BLOCKED — target does not exist"
assert_contains "$report" "Outcome: BLOCKED"
assert_file_absent "$nonexistent" "nothing was created at the unusable target"

# Also verify the not-a-directory case: a target that exists as a file.
not_a_dir="$TESTDIR/im-a-file"
echo "x" > "$not_a_dir"
report2="$TESTDIR/report2.txt"
bash "$PROJECT_INIT" "$not_a_dir" >"$report2" 2>&1
status2=$?

assert_exit 2 "$status2" "BLOCKED — target is not a directory"
assert_contains "$report2" "Outcome: BLOCKED"
