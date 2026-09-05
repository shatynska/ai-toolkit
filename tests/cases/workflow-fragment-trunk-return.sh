#!/usr/bin/env bash
# Scenario (mechanical half only): A long-running change does not first meet
# the trunk at its pull request.
#
# A change keeps one branch from proposal to record, so the branch is brought
# back to the freshly fetched trunk after each merge, and fetched-and-rebased
# onto periodically in between rather than only when it is cut. The
# requirement additionally scopes the three operations separately and obliges
# a route for each part of the change's life: "Fetching is not destructive
# and continues throughout. Before the branch is pushed, the trunk is brought
# in by rebasing. After, it is brought in by merging, since a rebase then
# needs a force push over a branch under review where a merge does not."
#
# The discriminating half is `rebase`. A fragment that states only where the
# branch is cut from names the trunk and names fetching, and stops there —
# which is exactly the incomplete route the requirement says is worse than a
# stated one, because "a session that needs the trunk and has been told only
# what not to do will force-push". A fragment carrying no rebase instruction
# anywhere fails this case, and that is the failure the requirement asks for.
#
# The fetch-beside-trunk check is deliberately a co-occurrence on one line
# rather than a pinned phrase: "brought back to the freshly fetched trunk"
# and "fetch the trunk" both satisfy it, and neither wording is fixed by the
# requirement.
#
# Not asserted: that the rebase is directed *periodically* rather than once,
# that the pre-push and post-push routes are given as two routes, and that
# the reason for each is stated. Each is a property of the prose that no
# token scan separates from a mention. Verified by reading (task 1.12).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

# Vacuity guards: the return to the trunk is a rule about a change's one
# branch inside a delivery sequence that merges it more than once. A fragment
# stating neither states nothing this case is about.
assert_contains "$fragment" "pull request" \
  "the delivery sequence whose repeated merges the return to the trunk answers"
assert_contains "$fragment" "trunk" \
  "the branch the change's own branch is brought back to"

if ! grep -q -i -E -- 'rebas(e|ing|ed)' "$fragment"; then
  echo "FAIL: $fragment directs no rebase onto the trunk" >&2
  echo "      A change spanning several sessions otherwise first meets the trunk at its pull" >&2
  echo "      request. Fetching, rebasing and merging are scoped separately, and a rule that" >&2
  echo "      stops before the rebase leaves a session no route to stay current." >&2
  exit 1
fi

if ! grep -q -i -E -- 'fetch[a-z]*.*trunk|trunk.*fetch' "$fragment"; then
  echo "FAIL: $fragment never names fetching and the trunk together" >&2
  echo "      The trunk a change returns to is a freshly fetched one; a return to a stale local" >&2
  echo "      copy diverges from the trunk other changes are merging into rather than meeting it." >&2
  exit 1
fi
