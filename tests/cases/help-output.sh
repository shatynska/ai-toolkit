#!/usr/bin/env bash
# Scenario: A non-skill-aware tool can use it.
# --help is the tool's portable interface — anything readable by a shell
# reaches it, and it must be sufficient on its own, with no side effects.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" --help >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_contains "$report" "--tools" "flags documented"
assert_contains "$report" "TARGET" "the target argument is documented, not only the flags"
assert_contains "$report" "0" "exit codes documented"
assert_contains "$report" "SUCCESS" "outcomes documented"
assert_contains "$report" "BLOCKED" "outcomes documented"
assert_contains "$report" "ERROR" "outcomes documented"

# No side effects: --help makes no filesystem change.
assert_file_absent "$work/.git" "--help makes no filesystem change"
assert_file_absent "$work/AGENTS.md" "--help makes no filesystem change"
assert_file_absent "$work/.gitignore" "--help makes no filesystem change"

# -h is accepted as a synonym.
bash "$PROJECT_INIT" -h >/dev/null 2>&1
assert_exit 0 "$?" "-h is accepted as a synonym for --help"
