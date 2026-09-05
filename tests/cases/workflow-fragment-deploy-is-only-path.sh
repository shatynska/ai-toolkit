#!/usr/bin/env bash
# Scenario (mechanical half only): Production is not reached from a local
# machine.
#
# "**The deploy pipeline SHALL be the only path to production.** The fragment
# SHALL state that the command that deploys is never run locally against
# production, and that a change reaches production by merging and by nothing
# else. Local credentials for the production environment, where they exist at
# all, are for reading — a plan, a status, a log — and not for applying."
#
# This clause is what the rest of the delivery sequence rests on: "Without
# this, every gate above is optional. A session that can deploy from its own
# machine can reach production without a pull request, without continuous
# integration, and without the review that the pull request exists to
# obtain." A fragment that states the whole sequence and omits this one
# sentence states a convention rather than a constraint, and nothing reports
# the one time it was skipped — so its absence is worth a case even though
# only the co-occurrence, not the sentence, is mechanically reachable.
#
# The anchor is DERIVED: the requirement fixes the obligation and no wording
# for it. What the scan requires is that some single line names both
# production and the locality the clause excludes. Two independent sentences
# of the requirement carry that pair — "run locally against production" and
# "Local credentials for the production environment" — so a faithful fragment
# has more than one way to satisfy it, which is what keeps a wording change
# from failing a compliant file.
#
# Not asserted: that the fragment says a change reaches production by merging
# and by nothing else, that read-only local credentials are distinguished
# from applying ones, or that the clause sits where the sequence can be read
# against it. All three are prose, verified by reading (task 1.10).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

# Vacuity guards: the clause bounds a delivery sequence in which merging
# deploys. A fragment stating neither states nothing this case is about, and
# the scan below would pass or fail for the wrong reason.
assert_contains "$fragment" "pull request" \
  "the delivery route this clause makes the only one"
assert_contains "$fragment" "deploy" \
  "the pipeline the clause names as the only path to production"
assert_contains "$fragment" "production" \
  "the environment the clause bounds access to"

if ! grep -q -i -E -- 'local[a-z]*.*production|production.*local[a-z]*' "$fragment"; then
  echo "FAIL: $fragment never bounds local access to production" >&2
  echo "      The deploy pipeline is the only path to production: the command that deploys is" >&2
  echo "      never run locally against it, and local production credentials are for reading." >&2
  echo "      Without the clause every gate in the delivery sequence is optional, because a" >&2
  echo "      session that can deploy from its own machine reaches production without any." >&2
  exit 1
fi
