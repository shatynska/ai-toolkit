#!/usr/bin/env bash
# Scenario (mechanical half only): A project without a deploy is not served by
# a conditional.
#
# The workflow fragment assumes a remote, a forge that reports a pull
# request's merged state, continuous integration, and that merging to the
# trunk deploys — and states no conditional for their absence. The half a
# shell case can reach is that each of the four is named, so that a reader
# meeting a rule which rests on one can find the assumption stated rather
# than inferring it. That a project of another shape is served by a
# publication of its own is prose, verified by reading (task 1.2).
#
# The negative scan below is bounded deliberately: no lexical rule
# distinguishes a conditional from any other sentence, so it looks only for
# the two conditional forms the predecessor fragments used verbatim and the
# design names as the cost being removed. It catches a resurrection, not a
# newly worded conditional; that remains a reading check.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

for token in "remote" "forge" "continuous integration" "deploy"; do
  if ! grep -q -i -F -- "$token" "$fragment"; then
    echo "FAIL: $fragment does not name the assumption: $token" >&2
    exit 1
  fi
done

# Without this the assumptions above could be named anywhere; the fragment
# must also state the delivery route they exist to support.
assert_contains "$fragment" "pull request" "the fragment states the delivery route its assumptions serve"

for conditional in "where the project has a remote" "where the project has one"; do
  hits="$(grep -n -i -F -- "$conditional" "$fragment")"
  if [ -n "$hits" ]; then
    echo "FAIL: $fragment carries a conditional for an assumption it is required to state plainly" >&2
    echo "      matched: $conditional" >&2
    echo "$hits" >&2
    exit 1
  fi
done
