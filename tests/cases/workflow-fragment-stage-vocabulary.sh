#!/usr/bin/env bash
# Scenarios (mechanical half only): A resuming session names the stage without
# interpreting prose; Writing tests and running tests are not one word; A
# change waiting on a deploy is distinguishable from one waiting on a merge.
#
# The vocabulary is closed and its members are fixed by the specification, so
# a case can assert every one of them is stated. That is what makes the
# report readable by a session that was not present: a name absent from the
# fragment is a state a resuming session has to describe in prose instead.
#
# What a case cannot reach: whether each name is classified transient or
# persistent, and whether each persistent one has its trace named. Those are
# prose and are verified by reading (tasks 1.8, 6.7). The cross-family check
# below is the one part of "not one word" that is mechanical — the two names
# exist and neither family has borrowed the other's word.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

stages="plan:draft plan:review plan:revise plan:approved plan:committed plan:tests
build:doing build:verify build:review build:fix build:clear
ship:pr ship:merged ship:deployed ship:confirmed ship:record ship:done
blocked: abandoned"

missing=""
for stage in $stages; do
  if ! grep -q -F -- "$stage" "$fragment"; then
    missing="$missing $stage"
  fi
done

if [ -n "$missing" ]; then
  echo "FAIL: $fragment does not state every name in the stage vocabulary" >&2
  echo "      missing:$missing" >&2
  exit 1
fi

# `plan:tests` is tests written from the specification deltas and
# `build:verify` is tests run against the implementation. Neither name may be
# used for the other, so the crossed forms must not appear at all.
for crossed in "plan:verify" "build:tests"; do
  hits="$(grep -n -F -- "$crossed" "$fragment")"
  if [ -n "$hits" ]; then
    echo "FAIL: $fragment uses $crossed — the vocabulary does not reuse a word across the two families" >&2
    echo "$hits" >&2
    exit 1
  fi
done
