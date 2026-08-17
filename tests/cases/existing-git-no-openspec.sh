#!/usr/bin/env bash
# Scenario: A partially initialized directory is completed, not refused.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
git init -q
git config user.email "t@t.com"
git config user.name "t"
echo "x" > tracked.txt
git add . && git commit -q -m "initial"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status" "should complete the missing concern"
assert_contains "$report" "repository: already present" "repository concern reported separately"
assert_contains "$report" "specification tooling: created" "specification tooling completed"
assert_file "$work/openspec/config.yaml" "specification tooling initialized"
assert_contains "$report" "Outcome: SUCCESS" "reports success"
