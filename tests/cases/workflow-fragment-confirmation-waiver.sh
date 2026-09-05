#!/usr/bin/env bash
# Scenarios (mechanical half only): A change with no observable effect
# reaches its record; The wrong change reaches its record rather than
# stalling; A waived change carries the reason to the trunk.
#
# A healthy deploy is not the change working, so a further gate sits between
# the deploy and the record: the change's intended effect is confirmed in
# production. The gate states its own exemption in advance, by class, because
# a gate with no exemption forecloses a refactor permanently — the record is
# never written, the teardown gate is conditioned on the record's pull
# request, and the branch and working tree become unremovable. Both waivable
# classes are recorded in the change's own artifacts.
#
# The half a case can reach is that the fragment states a waiver at all, and
# states it about production rather than about some other gate. A fragment
# that states the confirmation gate and no waiver is the dead end the
# requirement exists to close, and that is what this case fails on.
#
# Not asserted: that the exemption is stated in advance rather than
# improvised at the gate, that both classes are named, that the waiver names
# a successor's queue entry or proposal branch where one is intended, and
# that saying so plainly is still owed. Each is a property of the prose that
# no token scan separates from a mention. Verified by reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

# Vacuity guard: the waiver is a gate in the delivery sequence, so a fragment
# stating no delivery states nothing this case is about.
assert_contains "$fragment" "pull request" \
  "the delivery sequence the confirmation gate sits inside"

for token in "production" "waiv"; do
  if ! grep -q -i -F -- "$token" "$fragment"; then
    echo "FAIL: $fragment does not state the production-confirmation gate's waiver ($token)" >&2
    echo "      Without it a change with no externally observable effect can never reach its" >&2
    echo "      record, and its branch and working tree can never be removed." >&2
    exit 1
  fi
done
