#!/usr/bin/env bash
# Scenario: An explicit target is acted on and stated.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Invoke from an unrelated cwd, naming a different directory as the target —
# only the target should be touched.
elsewhere="$TESTDIR/elsewhere"
target="$TESTDIR/target"
mkdir -p "$elsewhere" "$target"
cd "$elsewhere" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" "$target" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_contains "$report" "Target: $target" "report states which directory it acted on"
assert_file "$target/AGENTS.md" "the named target was initialized"
assert_file_absent "$elsewhere/AGENTS.md" "the cwd was not touched"
assert_file_absent "$elsewhere/.git" "the cwd was not touched"
