#!/usr/bin/env bash
# Scenario (mechanical half only): A commit made while applying is not
# blocked by tests written to fail.
#
# The commit rules direct running the verification relevant to what changed
# before committing, and the tests derived before the implementation fail by
# design until it is complete — so for the whole of `build:applying` the rule
# requires a check that cannot pass. The specification resolves this by
# naming the bypass rather than describing one: "The fragment SHALL name the
# bypass — `--no-verify` — rather than describing one". A named flag is a
# token, so this half is mechanical.
#
# Not asserted: that the fragment says the failure is expected rather than a
# defect, and that the bypass suspends the pre-commit check and not the gate
# — a bypass stated without its bound reads as permission to skip what it
# stands in for. Both are prose, verified by reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

# Vacuity guard: the bypass exists only against a stated verification gate.
assert_contains "$fragment" "verification" \
  "the gate the bypass suspends the pre-commit check for, and does not suspend"

assert_contains "$fragment" "--no-verify" \
  "the bypass is named rather than described, so a session need not work it out at every commit of the longest stage"
