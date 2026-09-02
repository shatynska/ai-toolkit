#!/usr/bin/env bash
# Scenario (mechanical half only): A project carrying both fragments has one
# rule to follow, not two.
#
# `rules/development-workflow.md` obliges out-of-scope work noticed during a
# change to become a separate proposed change, and every bootstrapped project
# carries that inlined. The deferred-work fragment's file-entry route would
# otherwise leave such a project holding two standing constraints on one act,
# one permitting what the other requires. Stating the seam requires naming
# the fragment it reconciles against — the one reference a session-scoped
# fragment makes outside its own set, permitted because the workflow fragment
# is not session-scoped.
#
# That the seam is stated against the obligation rather than against a quoted
# sentence is not asserted here: pinning a case to the workflow fragment's
# present wording is the failure the delta names, and no check that avoids
# pinning distinguishes a paraphrase from a restated obligation. Verified by
# reading, per task 3.5.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/deferred-work.md"
assert_file "$fragment" "session-scoped fragment: deferred-work"

# The fragment this one is reconciled against must itself exist, or the
# assertion below is a reference to nothing.
assert_file "$TOOLKIT_ROOT/rules/development-workflow.md" "the fragment the seam reconciles against"

assert_contains "$fragment" "development-workflow" \
  "the seam names the workflow fragment whose obligation it reconciles against"
