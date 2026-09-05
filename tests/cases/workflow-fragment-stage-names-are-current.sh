#!/usr/bin/env bash
# Scenario (mechanical half only): A resuming session names the stage without
# interpreting prose.
#
# The vocabulary was aligned with the wider OpenSpec ecosystem's when this
# change was written: `apply` replaced `doing` as the `build` transition
# because `apply` is the ecosystem's load-bearing verb and `doing` names no
# operation, and `archive` replaced `record` as the last `ship` transition
# because `archive` is unambiguous across the tooling while `record` is also
# a plain verb this fragment uses several times. The sibling case
# `workflow-fragment-stage-vocabulary.sh` asserts that every transition of
# the new closed set is stated. This case asserts the other side of a
# rename, which that one does not reach: that no member of the superseded set
# survives beside it.
#
# The property is worth its own case because a half-applied rename is the
# failure mode a scan for the new names cannot see. A fragment carrying both
# sets publishes two vocabularies for one report, and a session resuming a
# change it did not start reads whichever it meets first — which is the
# prose-interpretation the closed set exists to remove. That is this
# scenario's outcome, read from the direction of the thing that defeats it.
#
# The anchor is DERIVED. The requirement fixes the closed set of transitions
# and states no prohibition on the names it replaced; what the superseded
# names violate is membership, not a stated ban. The tokens are therefore
# colon-anchored so that "the record", "recording", "recorded" and "doing" —
# all of which the fragment uses freely as ordinary English — cannot trip
# them. Only a stage name can match. A superseded name reintroduced in some
# other form would pass this case and remains a reading check (task 6.7).
#
# Not asserted, and deliberately: that the fragment names a build-family
# state for running the tests. An earlier draft of this case required
# `build:verifying` verbatim, on the strength of the requirement's sentence
# "`plan:tests-derived` is tests written from the change's specification
# deltas; `build:verifying` is tests run against the implementation". That
# assertion was DERIVED rather than specified and is withdrawn here, recorded
# in the change's `test-plan.md` as a change to a derived assertion rather
# than performed as a repair: the scenario's own WHEN is "a report names a
# stage involving tests", so its subject is what a session reports, not what
# the fragment enumerates — and the same requirement obliges the fragment to
# name only the states the derivation rule does not generate cleanly
# (`plan:tests-derived`, `ship:pr-open`) and forbids it from enumerating the
# rest. `build:verifying` derives cleanly, so requiring it in the text would
# demand the enumeration the requirement prohibits.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

# Vacuity guard: an absence is evidence only where a vocabulary is stated at
# all. A fragment stating none carries no superseded name either, and would
# pass the scan below for the wrong reason.
assert_contains "$fragment" "plan:tests-derived" \
  "the stage vocabulary whose superseded members the scan below looks for"

for superseded in ":doing" "plan:record" "build:record" "ship:record"; do
  hits="$(grep -n -F -- "$superseded" "$fragment")"
  if [ -n "$hits" ]; then
    echo "FAIL: $fragment carries a superseded stage transition" >&2
    echo "      matched: $superseded" >&2
    echo "      apply replaced doing and archive replaced record. Two vocabularies published for" >&2
    echo "      one report leave a resuming session reading whichever it meets first, which is" >&2
    echo "      the interpretation a closed set of names exists to remove." >&2
    echo "$hits" >&2
    exit 1
  fi
done
