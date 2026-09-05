#!/usr/bin/env bash
# Scenarios (mechanical half only): A resuming session names the stage without
# interpreting prose; A change waiting on a deploy is distinguishable from one
# waiting on a merge.
#
# The *transitions* are the closed set and a case can assert every one is
# stated. The derived state names are not: the requirement forbids the
# fragment enumerating them, so a case asserting a particular derived name
# would fail a compliant fragment. That is why this case reads the transition
# list and the derivation rule, not a roster of states.
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

# The vocabulary is generative: the transitions are the closed set and the
# states derive from them, so the fragment states the transitions, the rule,
# examples, the two states whose derivation reorders, and the off-path names.
# It deliberately does not enumerate every derived state.
# The transitions are read from the fenced block that states them, not from
# the document at large: every one of them — `review`, `fix`, `apply`,
# `merge`, `confirm` — is also an ordinary English word the fragment's prose
# uses freely, so a whole-file scan passes even if the block is deleted
# outright, which is the one thing this case exists to catch.
# Anchored on the sentence that introduces the block: a bare `^```$` scan is
# shifted by any language-tagged block added above it, and would then check
# the wrong region while still passing the non-empty guard below.
block="$(awk '/The acts are the transitions/{f=1} f&&/^```/{n++; next} f&&n==1' "$fragment")"

if [ -z "$block" ]; then
  echo "FAIL: $fragment states no fenced transition block" >&2
  exit 1
fi

missing=""
for stage in explore draft review fix approve commit apply verify merge deploy confirm archive; do
  if ! printf '%s\n' "$block" | grep -q -F -- "$stage"; then
    missing="$missing $stage"
  fi
done

if [ -n "$missing" ]; then
  echo "FAIL: the transition block in $fragment does not state every transition" >&2
  echo "      missing:$missing" >&2
  exit 1
fi

# The derived-state exceptions and the off-path names are stated in prose
# beside the block rather than inside it, so these are read from the file.
for token in "plan:tests-derived" "ship:pr-open" "blocked:" "abandoned"; do
  if ! grep -q -F -- "$token" "$fragment"; then
    echo "FAIL: $fragment does not state the derived-state exception or off-path name: $token" >&2
    exit 1
  fi
done

# `plan:tests-derived` is tests written from the specification deltas and
# `build:verifying` is tests run against the implementation. Neither name may be
# used for the other, so the crossed forms must not appear at all.
for crossed in "plan:verify" "build:tests"; do
  hits="$(grep -n -F -- "$crossed" "$fragment")"
  if [ -n "$hits" ]; then
    echo "FAIL: $fragment uses $crossed — the vocabulary does not reuse a word across the two families" >&2
    echo "$hits" >&2
    exit 1
  fi
done
