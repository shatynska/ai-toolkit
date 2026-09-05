#!/usr/bin/env bash
# Scenario (mechanical half only): An identified change is opened without a
# proposal.
#
# A change identified while another is in progress is opened with a
# `handoff.md` and no proposal — a proposal written in passing draws the
# review before it has earned it. The specification fixes both the artifact's
# name and its location ("`handoff.md` SHALL sit at the identified change's
# root"), and fixes them for the same stated reason the change queue's path
# is fixed: a location stated only in a change's own artifacts is archived
# with them. Asserting the name verbatim is the half a case can reach.
#
# Not asserted: what the handoff must carry (why the change was identified,
# what the originating work established, what it must not undo), that a
# commit on that branch is proposed as soon as it is opened, and that a
# declined commit is reported rather than continued past. All three are
# prose or session behavior, verified by reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

# Vacuity guard: the handoff belongs to the change-queue rule, so a fragment
# stating no such rule states nothing this case is about.
assert_contains "$fragment" "docs/change-queue.md" \
  "the change-queue rule the handoff obligation sits inside"

assert_contains "$fragment" "handoff.md" \
  "an identified change is opened with a handoff and no proposal, at a path the specification fixes"
