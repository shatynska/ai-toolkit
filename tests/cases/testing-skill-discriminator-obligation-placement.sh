#!/usr/bin/env bash
# Scenarios (mechanical half only): A static read is not mistaken for a
# covered behaviour; A discriminator that fails to falsify says the check
# asserts nothing; A negative finding reported rather than repaired is still
# recorded; A discriminator that cannot be run here is recorded rather than
# assumed.
#
# Three of the delta's obligations here are about *where* something is said,
# and a placement obligation is the one kind of prose property a static read
# reaches cleanly.
#
# First, the term. The requirement names `fixture-driven discriminator` and
# says the skill SHALL name it in the third situation's own text, "so the
# term is defined where the obligation is" — a term defined away from its
# obligation drifts from it. So the scan is over that section, not the file.
#
# Second, the routing for a discriminator that comes back negative. The
# requirement puts it "in the third situation's own text rather than leaving
# it to be inferred from the fourth state", because the fourth state's alarm
# is precisely what stops discriminating here. `repair` is matched as a root
# — repair, repaired, repairing — rather than the whole clause: the
# requirement fixes that such a check is repaired or reported and never left
# standing, not the sentence that says so.
#
# Third, the record's surface. The requirement states twice, with reasons,
# that neither the unrunnable-discriminator record nor the red-at-authoring
# record belongs in the baseline. That is a negative about a named section
# and is read there.
#
# Not asserted: that the obligation is stated as binding rather than as
# optional rigour, that it is scoped to a check as authored or modified, and
# the shared-machinery clause in either direction. Each is a proposition the
# requirement obliges without fixing a token, and a case matching one
# author's phrasing of them would fail a compliant rewording. Verified by
# reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

SKILL_REL="skills/testing/SKILL.md"
SITUATIONS="## Which situation you are in"
BASELINE="## Take a baseline first"

section() {
  awk -v h="$2" '$0==h{f=1;next} f&&/^## /{exit} f' "$1"
}

check() {
  local root="$1"
  local file="$root/$SKILL_REL"
  local body baseline problems=""

  if [ ! -f "$file" ]; then
    echo "FAIL: $file does not exist — the scans below would pass vacuously" >&2
    return 2
  fi

  body="$(section "$file" "$SITUATIONS")"
  if [ -z "$body" ]; then
    echo "FAIL: $file states no '$SITUATIONS' section — the scans below would pass vacuously" >&2
    return 2
  fi

  baseline="$(section "$file" "$BASELINE")"
  if [ -z "$baseline" ]; then
    echo "FAIL: $file states no '$BASELINE' section — the negative scan below would pass vacuously" >&2
    return 2
  fi

  # The term, defined where the obligation is stated.
  # SPECIFIED — "SHALL NOT present it as optional rigour". Scanned separately from
  # the term above, because the term appears in several paragraphs of this section
  # and the obligation in exactly one: without this, deleting the obligation
  # paragraph outright leaves the term behind and the case green. Found by mutation
  # rather than by reading, which is the only way this class shows itself.
  if ! printf '%s\n' "$body" | grep -qiE -- 'not optional rigou?r'; then
    problems="$problems
  the situations section states no obligation for the third situation — the term
  may be named, but nothing says a green check owes a discriminator, and the
  requirement's 'SHALL NOT present it as optional rigour' is unmet"
  fi

  if ! printf '%s\n' "$body" | grep -qiF -- 'fixture-driven discriminator'; then
    problems="$problems
  the situations section does not name a fixture-driven discriminator, so the
  term is either absent or defined away from the obligation it belongs to"
  fi

  # The negative result's routing, in the same section rather than left to be
  # inferred from a failure state whose alarm does not fire here.
  if ! printf '%s\n' "$body" | grep -qi -- 'repair'; then
    problems="$problems
  the situations section does not say what a discriminator coming back
  negative leaves the author to do — repair the check or report it"
  fi

  # The surface. The baseline record is about the state of the suite before
  # these tests were written; a discriminator record is a fact about one test
  # in this pass, and a reader sweeping for outstanding discriminator work
  # does not look in the baseline.
  # DERIVED, and it over-reports in one direction: a compliant cross-reference in
  # the baseline section — "a discriminator that could not be run is recorded
  # under *Which situation you are in*, not here" — is prose obeying the rule and
  # this scan fails it. Disclosed rather than narrowed: the delta forbids siting
  # the record there, and no cheap scan separates siting it from naming it.
  if printf '%s\n' "$baseline" | grep -qi -- 'discriminator'; then
    problems="$problems
  the baseline section carries the discriminator record, which the requirement
  places wherever the project records the classification and its reasons"
  fi

  if [ -n "$problems" ]; then
    echo "FAIL: $file$problems" >&2
    return 1
  fi
  return 0
}

check "$TOOLKIT_ROOT" || exit 1

# This check is itself a static read, so a pass over the committed file
# establishes nothing until the check is run over material this test supplies.
# The fixture states every obligation above and puts each in the wrong place:
# the term and the routing in the failure-states section, the record in the
# baseline. A file-wide scan passes against it; this check must not.
fixture="$TESTDIR/falsifying"
mkdir -p "$fixture/skills/testing"
cat >"$fixture/$SKILL_REL" <<'FIXTURE'
# testing

## Which situation you are in

Three situations. Establish which one applies before anything else.

- **The target does not exist yet.** Tests are written against a stated requirement.
- **The target already exists.** Tests are written for code that is already there.
- **The assertion does not execute the behaviour it asserts.** A pass reports only that the target could be read.

## Take a baseline first

Record the baseline, and record beside it any fixture-driven discriminator that could not be run here.

## What a failing test establishes

A fixture-driven discriminator that passes over material chosen to falsify the check establishes that the check asserts nothing; repair it or report it, and never leave it standing as coverage.
FIXTURE


# `assert_file` is the harness's own guard and is used here rather than left
# sourced-but-unused: it reports the write failing in the harness's voice,
# before the status check below reads an unusable fixture as a rejection.
assert_file "$fixture/$SKILL_REL" "the falsifying fixture was not written"
# The fixture trips several of the scans above at once, so a status alone
# establishes only that the check failed somehow — not that it failed on the
# property this case exists to assert. Capture the reason and require the
# named one, so deleting that scan is detectable rather than masked by its
# neighbours. The scan named here is the term defined away from the obligation it belongs to.
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
  echo "      The fixture defines the term away from its obligation, leaves the" >&2
  echo "      negative result to be inferred from a failure state, and files the" >&2
  echo "      record in the baseline. A check that passes there is reading the" >&2
  echo "      whole file rather than the places the requirement names." >&2
  exit 1
fi

case "$fixture_reason" in
  *"does not name a fixture-driven discriminator"*) ;;
  *)
    echo "FAIL: the fixture was rejected, but not on the property this case" >&2
    echo "      exists to assert. A neighbouring scan fired instead, so deleting" >&2
    echo "      the scan for 'does not name a fixture-driven discriminator' would go unnoticed." >&2
    echo "      Rejection reason was:" >&2
    printf '%s\n' "$fixture_reason" >&2
    exit 1 ;;
esac
