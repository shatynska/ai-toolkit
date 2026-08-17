#!/usr/bin/env bash
# Scenario: A non-default harness is selected.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" --tools agents >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_file "$work/openspec/config.yaml" "specification tooling initialized"
assert_file "$work/.agents/skills/openspec-propose/SKILL.md" "non-default harness (agents) targeted, not the claude default"
assert_file_absent "$work/.claude/commands" "the claude-specific output is not also produced"
