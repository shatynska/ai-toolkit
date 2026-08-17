#!/usr/bin/env bash
# Scenario: Missing fragment blocks rather than degrades.
# Builds a decoy toolkit copy missing rules/development-workflow.md, so the
# real repository is never touched.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

decoy="$TESTDIR/decoy-toolkit"
mkdir -p "$decoy/scripts" "$decoy/rules"
cp "$TOOLKIT_ROOT/scripts/project-init" "$decoy/scripts/project-init" || exit 1
# Deliberately do not copy rules/development-workflow.md.

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
bash "$decoy/scripts/project-init" >"$report" 2>&1
status=$?

assert_exit 2 "$status" "BLOCKED when the fragment is absent"
assert_contains "$report" "Outcome: BLOCKED"
assert_file_absent "$work/.git" "no filesystem change was attempted"
assert_file_absent "$work/AGENTS.md" "no conventions file written without the rules"
