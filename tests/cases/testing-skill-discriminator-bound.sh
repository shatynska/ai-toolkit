#!/usr/bin/env bash
# Scenarios (mechanical half only): A discriminating case that falsifies
# nothing further is labelled; The bound is stated without a quantity.
#
# The bound on how much of a discriminator a check is owed lands in the
# classification requirement rather than in a rule of its own, because that
# requirement already owns the machinery: a case an author cannot say what it
# falsifies is a derived assertion and is labelled like any other. Two things
# about that are mechanical.
#
# The first is placement and vocabulary. The bound is stated in the
# classification section, in the term the situations section defines — "the
# term as *The Skill States the Situations It Can Be Entered In* defines it"
# — and it is stated by what a case *falsifies*, which is the whole content
# of the bound. `falsif` is matched as a root, covering falsify, falsifies
# and falsifying, rather than a clause: the requirement fixes what the bound
# turns on, not the sentence that says it.
#
# The second is the negative, and it is the sharper of the two: the skill
# SHALL NOT state a number of cases, a proportion, or a size — "the bound is
# what the case establishes, which is reviewable, rather than how many there
# are, which is not." A numeral or a percent sign in this section is a
# quantity, and the section carries neither today.
#
# That negative is partial and worth naming as such: a quantity written in
# words — "at least one case per check" — is a violation this case does not
# see. There is no scan that separates a counted bound from the ordinary
# English numbers this section already uses ("one of three things"), so what
# is reachable is the numeral. Verified by reading for the rest.
#
# Not asserted: that the bound sits after the reason-for-labelling paragraph
# rather than between the classifications and the reason. The delta does not
# fix the order — the change's own task list does, as a reading — and a case
# anchored on an unamended paragraph would fail on a reword that changed
# nothing the requirement cares about.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

SKILL_REL="skills/testing/SKILL.md"
CLASSIFICATION="## Specified, derived, deliberately untested"

section() {
  awk -v h="$2" '$0==h{f=1;next} f&&/^## /{exit} f' "$1"
}

check() {
  local root="$1"
  local file="$root/$SKILL_REL"
  local body problems="" quantities

  if [ ! -f "$file" ]; then
    echo "FAIL: $file does not exist — the scans below would pass vacuously" >&2
    return 2
  fi

  body="$(section "$file" "$CLASSIFICATION")"
  if [ -z "$body" ]; then
    echo "FAIL: $file states no '$CLASSIFICATION' section — the scans below would pass vacuously" >&2
    return 2
  fi

  if ! printf '%s\n' "$body" | grep -qiF -- 'fixture-driven discriminator'; then
    problems="$problems
  the classification section does not state what a fixture-driven
  discriminator is for, which is where the bound on one lives"
  fi

  if ! printf '%s\n' "$body" | grep -qi -- 'falsif'; then
    problems="$problems
  the classification section does not state the bound by what a case
  falsifies, which is the only form of it that is reviewable"
  fi

  # DERIVED, and it over-reports: any digit trips it — a cross-reference, "state
  # 4", a version. The header discloses the false-negative side (a quantity
  # written in words is invisible here); this is the other side, and it is the
  # likelier one to fire on prose that obeys the rule.
  quantities="$(printf '%s\n' "$body" | grep -n -- '[0-9%]')"
  if [ -n "$quantities" ]; then
    problems="$problems
  the classification section states a quantity, where the requirement bounds a
  discriminator by what each case establishes and by nothing countable:
$quantities"
  fi

  if [ -n "$problems" ]; then
    echo "FAIL: $file$problems" >&2
    return 1
  fi
  return 0
}

check "$TOOLKIT_ROOT" || exit 1

# A static read, so the check is run over material this test supplies. The
# fixture states the bound in a neighbouring section — where a whole-file
# scan finds it — and gives the classification section a counted one instead,
# which is the form the requirement forbids.
fixture="$TESTDIR/falsifying"
mkdir -p "$fixture/skills/testing"
cat >"$fixture/$SKILL_REL" <<'FIXTURE'
# testing

## Which situation you are in

A fixture-driven discriminator establishes that the check can fail, by falsifying it on the property the check exists to assert.

## Specified, derived, deliberately untested

Every assertion is one of three things, and which one is recorded, not left implicit:

- **Specified** — it traces to a stated requirement.
- **Derived** — you inferred it; no stated requirement covers it.
- **Deliberately untested** — a case you identified and knowingly left uncovered, recorded with the reason.

Write at least 3 discriminating cases per check, or about 30% of the check's own length.
FIXTURE


# `assert_file` is the harness's own guard and is used here rather than left
# sourced-but-unused: it reports the write failing in the harness's voice,
# before the status check below reads an unusable fixture as a rejection.
assert_file "$fixture/$SKILL_REL" "the falsifying fixture was not written"
# The fixture trips several of the scans above at once, so a status alone
# establishes only that the check failed somehow — not that it failed on the
# property this case exists to assert. Capture the reason and require the
# named one, so deleting that scan is detectable rather than masked by its
# neighbours. The scan named here is the bound stated as something other than what a case falsifies.
fixture_reason="$(check "$fixture" 2>&1)"
fixture_status=$?
if [ "$fixture_status" -eq 2 ]; then
  echo "FAIL: the fixture could not be read — it was never written, or its section" >&2
  echo "      is missing. The discriminator below would pass without discriminating," >&2
  echo "      which is the failure this case exists to detect." >&2
  exit 1
fi
if [ "$fixture_status" -eq 0 ]; then
  echo "FAIL: the check passed over material chosen to falsify it" >&2
  echo "      The fixture states the bound outside the classification section and" >&2
  echo "      replaces it there with a count and a proportion. A check that passes" >&2
  echo "      there asserts neither where the bound lives nor what form it takes." >&2
  exit 1
fi

case "$fixture_reason" in
  *"does not state the bound by what a case"*) ;;
  *)
    echo "FAIL: the fixture was rejected, but not on the property this case" >&2
    echo "      exists to assert. A neighbouring scan fired instead, so deleting" >&2
    echo "      the scan for 'does not state the bound by what a case' would go unnoticed." >&2
    echo "      Rejection reason was:" >&2
    printf '%s\n' "$fixture_reason" >&2
    exit 1 ;;
esac
