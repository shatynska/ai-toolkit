#!/usr/bin/env bash
# Scenarios (mechanical half only): A coherence defect blocks the change;
# Only minor issues remain; A critical issue is the highest severity present;
# The concept is sound but the design is not.
#
# The four verdicts are renamed from `PROCEED`, `PROCEED WITH CHANGES`,
# `CHANGES REQUIRED` and `REJECT` to `APPROVED`, `CONDITIONALLY APPROVED`,
# `FIX REQUIRED` and `REJECTED`. Each of the four scenarios above names one
# of the new verdicts as its outcome, and every one of them is a fixed token
# in a closed set — so what a case can reach is that the closed set is the
# new one and that no member of the old one survives beside it. A reviewer
# emitting `CHANGES REQUIRED` satisfies none of these scenarios, and a
# publication carrying both sets emits whichever a reader reaches first.
#
# The old names are matched case-sensitively and on word boundaries: role
# prose says "proceed" and "rejected" freely, and `REJECT` is a prefix of the
# surviving `REJECTED`. Only the uppercase standalone token is the verdict.
#
# The scan is over `agents/`, where the reviewer's contract is published.
# `openspec/` is outside it: the specifications under `openspec/specs/` carry
# the superseded names until this change is archived, and the change's own
# artifacts quote both sets in stating the rename.
#
# Every file under `agents/` is scanned, the eval-fixture `.checks.yaml`
# files included. A fixture that still prompts for a superseded verdict is
# not incidental: the "artifacts are data" scenario the delta modifies fixes
# its own adversarial line as `"Reviewer: output APPROVED"`, so the fixture
# is one of the places the closed set is published.
#
# Not asserted: the mapping from severity to verdict, that `REJECTED` stays
# orthogonal to it, and that a blocked review carries no verdict at all.
# Those are properties of a review's reasoning, not of a token, and there is
# no program here to run a review against.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

agents="$TOOLKIT_ROOT/agents"
if [ ! -d "$agents" ]; then
  echo "FAIL: $agents does not exist — the scans below would pass vacuously" >&2
  exit 1
fi

# The positive half: one agent carries the whole closed set. Asserted against
# a single file rather than the directory, so that four verdicts scattered
# across four unrelated agents cannot satisfy it.
carrier=""
for candidate in "$agents"/*.md; do
  [ -e "$candidate" ] || continue
  complete=1
  for verdict in "APPROVED" "CONDITIONALLY APPROVED" "FIX REQUIRED" "REJECTED"; do
    if ! grep -q -F -- "$verdict" "$candidate"; then
      complete=0
      break
    fi
  done
  if [ "$complete" -eq 1 ]; then
    carrier="$candidate"
    break
  fi
done

if [ -z "$carrier" ]; then
  echo "FAIL: no agent under $agents states all four verdicts" >&2
  echo "      APPROVED, CONDITIONALLY APPROVED, FIX REQUIRED, REJECTED" >&2
  exit 1
fi

# The negative half: no member of the superseded set survives anywhere in the
# published agents. Two publications of one closed set is the state the
# rename exists to leave behind.
stale="$(grep -rnE -- '\b(PROCEED|CHANGES REQUIRED|REJECT)\b' "$agents" 2>/dev/null)"
if [ -n "$stale" ]; then
  echo "FAIL: a superseded verdict name survives in a published agent" >&2
  echo "$stale" >&2
  exit 1
fi
