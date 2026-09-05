#!/usr/bin/env bash
# Scenarios (mechanical half only): A session does not substitute a reachable
# double for the real database; Absence is asserted only after looking.
#
# The ordering is normative, not stylistic: a fragment that only warns the
# database may be hard to reach leaves a session free to substitute something
# reachable, violating nothing it says while proving the code works against
# something other than the engine production runs. So the affordance — a real
# database is running and the integration tests run against it — is stated
# before what must be provisioned before a result means anything.
#
# Ordering is one of the few properties of prose a case can observe, so it is
# asserted here rather than left to reading: the first line stating the
# affordance must precede the first line stating the provisioning obligation.
# A fragment that mentions provisioning in an opening sentence, before the
# affordance, fails this case — which is the strictness the requirement asks
# for, not a false positive.
#
# What is not asserted: that the fragment restates no obligation the workflow
# fragment already states, and that the check-before-concluding rule is
# phrased as an action rather than as a defect. Both are prose, verified by
# reading (tasks 2.3, 2.5).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow-database.md"
assert_file "$fragment" "the database binding fragment"

# The requirement obliges the binding to name the database and the container
# the project actually runs, where the workflow fragment states the same
# obligations service-neutrally. Also the vacuity guard for the ordering
# check below: a fragment naming no container states no affordance to order.
assert_contains "$fragment" "container" \
  "the binding names the container the project runs, which the workflow fragment must not"

affordance="$(grep -n -i -E 'integration test|real database' "$fragment" | head -n1 | cut -d: -f1)"
obligation="$(grep -n -i -E 'provision' "$fragment" | head -n1 | cut -d: -f1)"

if [ -z "$affordance" ]; then
  echo "FAIL: $fragment states no affordance — that a real database runs and the integration tests run against it" >&2
  exit 1
fi
if [ -z "$obligation" ]; then
  echo "FAIL: $fragment states no provisioning obligation — the ordering check below would pass vacuously" >&2
  exit 1
fi

if [ "$affordance" -eq "$obligation" ]; then
  echo "FAIL: $fragment states the affordance and the provisioning obligation on one line ($affordance)" >&2
  echo "      The requirement is an order, so the two must be separable: a reader who stops after the" >&2
  echo "      obligation must already have met the affordance, which one line cannot guarantee." >&2
  exit 1
fi
if [ "$affordance" -gt "$obligation" ]; then
  echo "FAIL: $fragment states the provisioning obligation (line $obligation) before the affordance (line $affordance)" >&2
  echo "      The defensive statement does not imply the permissive one: stated in that order, a session may" >&2
  echo "      substitute something reachable for the real database and violate nothing the fragment says." >&2
  exit 1
fi
