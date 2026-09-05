#!/usr/bin/env bash
# Scenario (mechanical half only): A working tree carrying no change is not
# held by these rules.
#
# The predecessor requirement obliged the fragment to *state* an exclusion for
# a working tree that tooling creates for a single act. This change keys every
# working-tree rule to the change instead, which puts such a tree outside the
# rules without an exclusion being written — and then forbids writing one:
# "The fragment SHALL NOT carry the exclusion. A scope statement defending
# against a reading the text no longer invites is text a reader must
# understand before discovering it is inert, and the case that motivated it —
# `agent-authoring`'s mandated cold-run working tree — exists in this library
# and not in the projects the fragment is written for."
#
# So the mechanical half here is an absence, and it is the half that changed:
# a fragment carrying the exclusion satisfies the scenario's outcome by the
# wrong route and pays for it on every read in every adopting project.
#
# The anchor is DERIVED. The requirement fixes no token for the exclusion; it
# names the motivating case, and the motivating case is what an exclusion
# would have to invoke to be one. `cold-run`, `cold run` and `agent-authoring`
# are the words the predecessor fragment and this requirement both use for it.
# A differently worded exclusion would pass this case and remains a reading
# check (task 1.4).
#
# Not asserted: that every rule is positively keyed to the change rather than
# to the session — "a change's branch", "a change's working tree". The keying
# is a property of how each sentence is phrased, and the words themselves
# occur freely in a fragment keyed either way.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

# Vacuity guards: an absence is only evidence where the rules the exclusion
# would have carved out of are present. A fragment stating no working-tree
# rule at all satisfies the scan below for the wrong reason.
assert_contains "$fragment" "working tree" \
  "the rules an exclusion would carve a tooling-created tree out of"
assert_contains "$fragment" ".worktrees/" \
  "the working-tree root those rules are checked against"

for token in "cold-run" "cold run" "agent-authoring"; do
  hits="$(grep -n -i -F -- "$token" "$fragment")"
  if [ -n "$hits" ]; then
    echo "FAIL: $fragment carries the scope exclusion for a tooling-created working tree" >&2
    echo "      matched: $token" >&2
    echo "      Keying every rule to the change already puts such a tree outside them. An" >&2
    echo "      exclusion defends against a reading the text no longer invites, and the case it" >&2
    echo "      names exists in this library rather than in the projects the fragment is for." >&2
    echo "$hits" >&2
    exit 1
  fi
done
