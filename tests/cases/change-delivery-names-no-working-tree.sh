#!/usr/bin/env bash
# Scenario (mechanical half only): A project adopts delivery without
# isolation.
#
# A project that runs sessions serially has every use for the delivery
# fragment and none for isolation, and that project shape is half the reason
# the cut is by applicability rather than by phase. A delivery rule naming a
# working tree is unsatisfiable there.
#
# The scenario's other clause — that the rules state no branch-per-session
# obligation and are satisfiable from whatever branch the project works on —
# is not asserted here. The fragment legitimately says "the branch" throughout
# (archive as the last commit on it, push it, open a pull request from it),
# and no lexical rule separates that from "a branch of its own"; verified by
# reading, per task 2.7.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/change-delivery.md"
assert_file "$fragment" "session-scoped fragment: change-delivery"

# Without this the absence check below passes against a stub, an empty file,
# or a fragment that states no delivery route at all.
assert_contains "$fragment" "pull request" "the fragment states the delivery route it is named for"

offenders="$(grep -n -i -E 'worktree|working tree' "$fragment")"
if [ -n "$offenders" ]; then
  echo "FAIL: $fragment names a working tree — it must be satisfiable in a project that keeps none" >&2
  echo "$offenders" >&2
  exit 1
fi
