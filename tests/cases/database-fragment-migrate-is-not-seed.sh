#!/usr/bin/env bash
# Accounts for no scenario of its own, and is recorded that way in the
# change's `test-plan.md`. It asserts two obligations the binding-fragment
# requirement states in one sentence and that none of its four scenarios
# names: "The fragment SHALL state that migrating is not seeding, and that a
# session reads a failing test's assertion message before concluding a
# failure is pre-existing."
#
# Both are the provisioning end state seen from inside the binding. A
# database that has been migrated and not seeded is a working tree that has
# reached one provisioning step and not the last — the partially provisioned
# environment that "fails in ways that read as defects in the change under
# test", which is also why the second half is stated beside the first: the
# session that meets those failures concludes they are pre-existing unless it
# has been told to read the message.
#
# `migrat` and `seed` are SPECIFIED — the requirement fixes both words. The
# `assertion` anchor is DERIVED: the obligation is fixed and the wording is
# not, and "assertion" is the word the requirement itself reaches for.
#
# Not asserted: that the two are stated as one rule rather than two, that
# either is phrased as an action rather than as a defect, or where in the
# fragment they sit. All are prose, verified by reading (task 2.3).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow-database.md"
assert_file "$fragment" "the database binding fragment"

# Vacuity guard: both obligations are about the database the binding names.
# A fragment naming none states nothing either scan is about.
assert_contains "$fragment" "database" \
  "the service the binding names, which the workflow fragment states neutrally"

if ! grep -q -i -E -- 'migrat(e|es|ed|ing|ion|ions)' "$fragment"; then
  echo "FAIL: $fragment does not state what migrating does" >&2
  echo "      Migrating is not seeding, and a database that reached one step and not the other" >&2
  echo "      fails in ways that read as defects in the change under test." >&2
  exit 1
fi

if ! grep -q -i -E -- 'seed(s|ed|ing)?' "$fragment"; then
  echo "FAIL: $fragment does not distinguish seeding from migrating" >&2
  echo "      A session that treats the two as one step reaches a provisioned schema with no" >&2
  echo "      data in it and reads the resulting failures as the change's." >&2
  exit 1
fi

if ! grep -q -i -F -- "assertion" "$fragment"; then
  echo "FAIL: $fragment does not direct reading a failing test's assertion message" >&2
  echo "      Without it a session concludes a failure is pre-existing from the fact that it" >&2
  echo "      failed, which is the conclusion a partially provisioned database produces." >&2
  exit 1
fi
