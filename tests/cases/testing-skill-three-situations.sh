#!/usr/bin/env bash
# Scenarios (mechanical half only): A test passing on first run is read
# correctly in each situation; A reader can tell which rules are in force;
# The third situation is distinguished from the second by what the assertion
# executes.
#
# The skill's situations section goes from two situations to three, and the
# third is defined by what the assertion does rather than by what the target
# is. Three things about that are mechanical: the section enumerates three
# situations rather than two; it draws the line on whether the assertion
# executes *the behaviour it asserts* — the delta fixes that wording as one
# test rather than two; and the two-way phrasings the old count left behind
# do not survive anywhere in the file.
#
# The superseded phrases are matched as fixed strings, quoted from the
# change's own task list. A count word alone is no use here: "two" and "both"
# occur in this document for reasons that have nothing to do with the
# situations, so only the whole clause identifies the claim being corrected.
#
# British and American spellings of "behaviour" are both accepted. The delta
# is written in British spelling and the skill in American; which one lands
# is an authoring choice the requirement does not fix, and a case that picked
# one would fail a compliant file for a reason the requirement does not care
# about.
#
# The assertions are read from the situations section, not from the file at
# large. The separator sentence would be satisfied by a whole-file scan even
# if the section it belongs in said nothing about the third situation, which
# is the failure the fixture below falsifies against.
#
# Not asserted: that the three situations are stated to read one test at one
# moment rather than to partition tests, and that a static check whose target
# is absent is arbitrated into the first situation. Both are propositions the
# requirement obliges without fixing any token, so a case reaching them would
# be asserting one author's phrasing. Verified by reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

SKILL_REL="skills/testing/SKILL.md"
SITUATIONS="## Which situation you are in"

# Extracts one `## ` section's body, subsections included, stopping at the
# next `## `. Cases below read from this rather than from the whole file.
section() {
  awk -v h="$2" '$0==h{f=1;next} f&&/^## /{exit} f' "$1"
}

check() {
  local root="$1"
  local file="$root/$SKILL_REL"
  local body problems="" bullets

  if [ ! -f "$file" ]; then
    echo "FAIL: $file does not exist — the scans below would pass vacuously" >&2
    return 2
  fi

  body="$(section "$file" "$SITUATIONS")"
  if [ -z "$body" ]; then
    echo "FAIL: $file states no '$SITUATIONS' section — the scans below would pass vacuously" >&2
    return 2
  fi

  # Three situations, enumerated where the section enumerates them. A lower
  # bound rather than an exact count: the requirement fixes how many
  # situations there are, not that no other bolded bullet may sit beside them.
  bullets="$(printf '%s\n' "$body" | grep -c '^- \*\*')"
  if [ "$bullets" -lt 3 ]; then
    problems="$problems
  the section enumerates $bullets situations, not three"
  fi

  # The third situation, stated by what the assertion does not do.
  if ! printf '%s\n' "$body" | grep -qiE 'does not execute the behaviou?r it asserts'; then
    problems="$problems
  the section does not state the third situation as one whose assertion does
  not execute the behaviour it asserts"
  fi

  # Its affirmative half, which is what makes the line one test rather than
  # two: where the assertion does execute that behaviour, the second applies.
  if ! printf '%s\n' "$body" | grep -qiE 'executes the behaviou?r it asserts'; then
    problems="$problems
  the section does not state the separator's affirmative half — that where the
  assertion executes the behaviour it asserts, the second situation applies"
  fi

  # The rejected criterion. A file cannot behave, so a line drawn on what the
  # target can do puts a shell script read without being run on the wrong side
  # of it — the case the delta's own evidence turns on.
  if printf '%s\n' "$body" | grep -qiF -- 'can behave'; then
    problems="$problems
  the section still draws the line on what the target can do rather than on
  what the assertion executes"
  fi

  # The two-way phrasings, scanned over the whole file: each states a claim
  # about all the situations there are, and each is wrong once there are three.
  local stale=""
  while IFS= read -r phrase; do
    [ -n "$phrase" ] || continue
    if grep -qF -- "$phrase" "$file"; then
      stale="$stale
  \"$phrase\""
    fi
  done <<'PHRASES'
Two situations, and one central rule reads oppositely in them.
means opposite things in the two
Everything else here binds in both
PHRASES

  if [ -n "$stale" ]; then
    problems="$problems
  a two-way phrasing survives, stating of two situations what now holds of
  three:$stale"
  fi

  if [ -n "$problems" ]; then
    echo "FAIL: $file$problems" >&2
    return 1
  fi
  return 0
}

check "$TOOLKIT_ROOT" || exit 1

# The check is a static read: its target is present whatever the check does,
# so a pass over the committed file establishes nothing on its own. Run it
# over material this test supplies, built to carry the near-miss the delta
# rejects by name — a third situation drawn on the *kind* of target rather
# than on what the assertion executes, with the correct separator present
# further down the document where a whole-file scan would find it.
fixture="$TESTDIR/falsifying"
mkdir -p "$fixture/skills/testing"
cat >"$fixture/$SKILL_REL" <<'FIXTURE'
# testing

## Which situation you are in

Three situations. Establish which one applies before anything else.

- **The target does not exist yet.** Tests are written against a stated requirement.
- **The target already exists.** Tests are written for code that is already there.
- **The target is a committed file.** A configuration file, a workflow or a manifest is not a thing that can behave, so a pass reports only that the target could be read.

## What a failing test establishes

Where the assertion does not execute the behaviour it asserts, the pass establishes nothing; where it executes the behaviour it asserts, the pass is the result.
FIXTURE


# `assert_file` is the harness's own guard and is used here rather than left
# sourced-but-unused: it reports the write failing in the harness's voice,
# before the status check below reads an unusable fixture as a rejection.
assert_file "$fixture/$SKILL_REL" "the falsifying fixture was not written"
# The fixture trips several of the scans above at once, so a status alone
# establishes only that the check failed somehow — not that it failed on the
# property this case exists to assert. Capture the reason and require the
# named one, so deleting that scan is detectable rather than masked by its
# neighbours. The scan named here is the rejected criterion — the scan this case's header calls the one the
#   delta's own evidence turns on.
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
  echo "      The fixture draws the third situation on the kind of target and states" >&2
  echo "      the separator only outside the situations section. A check that passes" >&2
  echo "      there asserts nothing about the committed file either." >&2
  exit 1
fi

case "$fixture_reason" in
  *"draws the line on what the target can do"*) ;;
  *)
    echo "FAIL: the fixture was rejected, but not on the property this case" >&2
    echo "      exists to assert. A neighbouring scan fired instead, so deleting" >&2
    echo "      the scan for 'draws the line on what the target can do' would go unnoticed." >&2
    echo "      Rejection reason was:" >&2
    printf '%s\n' "$fixture_reason" >&2
    exit 1 ;;
esac
