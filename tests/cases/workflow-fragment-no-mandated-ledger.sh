#!/usr/bin/env bash
# Scenario (mechanical half only): An imprecise stage is not treated as a
# defect worth an artifact.
#
# The stage vocabulary requirement states that no rule may require every
# stage to be derivable from the repository and that no ledger may be
# mandated to make one so: an artifact recording every gate would be paid for
# on every change to buy a precision nothing depends on. The waiver
# requirement states the same boundary from the other side — the
# production-confirmation waiver "is the only record these rules require
# beyond the artifacts a change already carries".
#
# The half a case can reach is that the fragment mandates no such ledger by
# name. The anchor is DERIVED, not specified: the current delta names no
# ledger artifact at all, so this scans for `gate-log`, the name an earlier
# draft of this change mandated and which this repository's own change
# directories still carry as a per-change record. It catches a resurrection
# of that apparatus and nothing wider — a ledger mandated under some other
# name would pass this case and is a reading check.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

# Vacuity guard: the prohibition belongs to the stage-vocabulary rule, so a
# fragment stating no vocabulary states nothing this case is about, and the
# negative scan below would pass for the wrong reason.
assert_contains "$fragment" "plan:tests-derived" \
  "the stage vocabulary whose derivability the requirement declines to mandate an artifact for"

hits="$(grep -n -i -F -- "gate-log" "$fragment")"
if [ -n "$hits" ]; then
  echo "FAIL: $fragment mandates a per-change ledger, which no rule may require" >&2
  echo "$hits" >&2
  exit 1
fi
