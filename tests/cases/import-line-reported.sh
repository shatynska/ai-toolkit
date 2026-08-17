#!/usr/bin/env bash
# Scenario: Rules written but not yet loadable are reported as such.
# Case: CLAUDE.md exists but does not import AGENTS.md — the import-needed
# report obligation applies to this branch too, not only when CLAUDE.md is
# absent (task 1.6's finding: the condition is a harness property, not tied
# to which ordered-rule branch fired).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
echo "# unrelated conventions, no AGENTS.md import" > CLAUDE.md

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_file "$work/AGENTS.md" "AGENTS.md created"
assert_contains "$report" "Import needed:" "import line reported — CLAUDE.md does not import AGENTS.md"
assert_contains "$report" "@AGENTS.md" "the specific import line is named"

# CLAUDE.md is never written to, regardless of the import-needed report.
if ! grep -q "unrelated conventions" "$work/CLAUDE.md"; then
  echo "FAIL: CLAUDE.md was modified — the tool must write nothing into it" >&2
  exit 1
fi
