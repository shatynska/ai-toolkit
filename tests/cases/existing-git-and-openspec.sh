#!/usr/bin/env bash
# Scenario: Existing specification tooling is skipped, not reinitialized.
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
openspec init --tools claude --no-animation . >/dev/null 2>&1

sum_before="$(md5sum "$work/openspec/config.yaml" | awk '{print $1}')"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status" "both satisfied, run still succeeds"
assert_contains "$report" "repository: already present"
assert_contains "$report" "specification tooling: already present"
assert_unchanged "$work/openspec/config.yaml" "$sum_before" "not reinitialized"
