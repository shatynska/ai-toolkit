#!/usr/bin/env bash
# Scenario (mechanical half only): An opened-and-left branch does not become
# the session's working branch.
#
# The branch a session opens for a change it identified but will not work on
# carries a `handoff.md` and no proposal, "so it is not named for a proposal
# — the term this requirement's predecessor used, and the one this change
# replaces". The predecessor's own scenario was titled for that term, and its
# rules called the thing a *proposal-only branch* throughout; this change
# renames both the artifact and the branch that carries it.
#
# The half a case can reach is the name. It is SPECIFIED — the requirement
# states outright which term is replaced — and it is an absence rather than a
# presence, because the replacement term is "a branch of its own", which is
# ordinary English no scan can distinguish from any other use of it.
#
# A fragment naming the branch for a proposal while placing a handoff on it
# is the half-applied rename, and it reinstates exactly the reading the
# handoff decision exists to prevent: that what sits on that branch is a
# proposal in draft, to be reviewed rather than read.
#
# Not asserted: that the branch is created and left, that it takes no working
# tree, and that it does not become the branch this session works on. All
# three are session behavior, verified by reading (task 1.15).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

# Vacuity guards: the branch is one of the two routes the change-queue rule
# states, and what it carries is the handoff. A fragment stating neither
# states nothing this case is about, and the absence below would be evidence
# of nothing.
assert_contains "$fragment" "docs/change-queue.md" \
  "the change-queue rule whose branching option this branch is"
assert_contains "$fragment" "handoff.md" \
  "what the opened-and-left branch carries in place of a proposal"

for superseded in "proposal-only" "proposal only"; do
  hits="$(grep -n -i -F -- "$superseded" "$fragment")"
  if [ -n "$hits" ]; then
    echo "FAIL: $fragment names the opened-and-left branch for a proposal" >&2
    echo "      matched: $superseded" >&2
    echo "      The branch carries a handoff and no proposal. Naming it for a proposal invites the" >&2
    echo "      treatment the handoff decision exists to prevent — a review round the change has" >&2
    echo "      not earned, on a document nobody has thought through." >&2
    echo "$hits" >&2
    exit 1
  fi
done
