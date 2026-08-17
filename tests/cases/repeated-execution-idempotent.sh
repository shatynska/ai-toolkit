#!/usr/bin/env bash
# Scenario: Repeated execution is not destructive.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

bash "$PROJECT_INIT" >/dev/null 2>&1
first_status=$?
assert_exit 0 "$first_status" "first run should succeed"

sum_gitignore_1="$(md5sum .gitignore | awk '{print $1}')"
sum_agents_1="$(md5sum AGENTS.md | awk '{print $1}')"
sum_config_1="$(md5sum openspec/config.yaml | awk '{print $1}')"

report2="$TESTDIR/report2.txt"
bash "$PROJECT_INIT" >"$report2" 2>&1
second_status=$?

assert_exit 0 "$second_status" "second run should also succeed"
assert_unchanged "$work/.gitignore" "$sum_gitignore_1" "gitignore not modified"
assert_unchanged "$work/AGENTS.md" "$sum_agents_1" "AGENTS.md not modified or duplicated"
assert_unchanged "$work/openspec/config.yaml" "$sum_config_1" "specification tooling not reinitialized"
assert_contains "$report2" "repository: already present"
assert_contains "$report2" "specification tooling: already present"
assert_contains "$report2" "ignore file: already present"
