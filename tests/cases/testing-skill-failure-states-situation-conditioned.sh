#!/usr/bin/env bash
# Scenarios (mechanical half only): The first-run alarm is not relied on
# where it cannot discriminate.
#
# The failure-states section routes its enumeration by a condition, and that
# condition changes. It reads "where the target already exists" today, and
# presence now spans two situations that read the second and fourth states
# differently from each other — so the routing has to key on the situation
# instead. Two further phrases in the same section were written for a world
# with two situations and are wrong at three: the third state's "in either
# situation" and the introducing paragraph's "the third is the same either
# way". Both are situation-independent claims whose count is wrong, and both
# are fixed strings.
#
# The positive half is that the fourth state carries its third-situation
# reading explicitly — the alarm fires on every check whose assertion does
# not execute the behaviour it asserts, sound ones included, so it
# discriminates among none of them. A case cannot assert that reasoning, but
# it can assert that the section names the situation it is now conditioned
# on. A section still routing by the target's presence names no situation at
# all, which is exactly the state this case exists to catch.
#
# The scans are bounded to that section. Every phrase below is one a
# compliant document may well use elsewhere — the situations section itself
# discusses all three — so a whole-file scan would report the wrong thing in
# both directions.
#
# Not asserted: that the reading sits beside the enumeration rather than
# inside the fourth bullet, that a check red at authoring is said not to
# raise the fourth state at all, and that the pass is answered by the fixture
# obligation rather than by investigating the pass. The first is a layout
# property with no token to key on, and the other two are propositions the
# requirement obliges without fixing wording. Verified by reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

SKILL_REL="skills/testing/SKILL.md"
STATES="## What a failing test establishes"

section() {
  awk -v h="$2" '$0==h{f=1;next} f&&/^## /{exit} f' "$1"
}

check() {
  local root="$1"
  local file="$root/$SKILL_REL"
  local body problems="" stale=""

  if [ ! -f "$file" ]; then
    echo "FAIL: $file does not exist — the scans below would pass vacuously" >&2
    return 2
  fi

  body="$(section "$file" "$STATES")"
  if [ -z "$body" ]; then
    echo "FAIL: $file states no '$STATES' section — the scans below would pass vacuously" >&2
    return 2
  fi

  # The fourth state's third-situation reading, in the section that states the
  # four states. Naming the situation is the least a section conditioned on it
  # can do; a section still routing by the target's presence names none.
  if ! printf '%s\n' "$body" | grep -qi -- 'discriminates among none'; then
    problems="$problems
  the section does not carry the fourth state's third-situation reading — that
  the alarm fires on every such check and discriminates among none of them"
  fi

  while IFS= read -r phrase; do
    [ -n "$phrase" ] || continue
    if printf '%s\n' "$body" | grep -qF -- "$phrase"; then
      stale="$stale
  \"$phrase\""
    fi
  done <<'PHRASES'
Where the target already exists
in either situation
the third is the same either way
PHRASES

  if [ -n "$stale" ]; then
    problems="$problems
  the section still routes by the target's presence, or states of two
  situations what is now true of three:$stale"
  fi

  if [ -n "$problems" ]; then
    echo "FAIL: $file$problems" >&2
    return 1
  fi
  return 0
}

check "$TOOLKIT_ROOT" || exit 1

# A static read again, so the check is run over material this test supplies.
# The fixture names the third situation in a neighbouring section and leaves
# the failure-states section exactly as it stands today: a whole-file scan
# finds the situation named and reports the section as amended.
fixture="$TESTDIR/falsifying"
mkdir -p "$fixture/skills/testing"
cat >"$fixture/$SKILL_REL" <<'FIXTURE'
# testing

## Which situation you are in

Three situations, and the third situation is the one where the assertion does not execute the behaviour it asserts.

## What a failing test establishes

The enumeration below is stated for the absent-target situation. Where the target already exists, the second and fourth states read differently, per *Which situation you are in*; the third is the same either way.

3. **The test itself is broken.** It establishes nothing about the code — in either situation.
4. **It passed on its first run, before any implementation existed.** An alarm, not a result.
FIXTURE


# `assert_file` is the harness's own guard and is used here rather than left
# sourced-but-unused: it reports the write failing in the harness's voice,
# before the status check below reads an unusable fixture as a rejection.
assert_file "$fixture/$SKILL_REL" "the falsifying fixture was not written"
# The fixture trips several of the scans above at once, so a status alone
# establishes only that the check failed somehow — not that it failed on the
# property this case exists to assert. Capture the reason and require the
# named one, so deleting that scan is detectable rather than masked by its
# neighbours. The scan named here is routing by presence rather than by situation.
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
  echo "      The fixture names the third situation only in a neighbouring section and" >&2
  echo "      leaves the failure-states section routing by the target's presence. A" >&2
  echo "      check that passes there is reading the document, not the section." >&2
  exit 1
fi

case "$fixture_reason" in
  *"still routes by the target's presence"*) ;;
  *)
    echo "FAIL: the fixture was rejected, but not on the property this case" >&2
    echo "      exists to assert. A neighbouring scan fired instead, so deleting" >&2
    echo "      the scan for 'still routes by the target's presence' would go unnoticed." >&2
    echo "      Rejection reason was:" >&2
    printf '%s\n' "$fixture_reason" >&2
    exit 1 ;;
esac
