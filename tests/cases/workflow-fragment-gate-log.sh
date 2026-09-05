#!/usr/bin/env bash
# Scenarios (mechanical half only): A dispatched review survives the session
# that dispatched it; A review still in flight survives the session that
# dispatched it; An operator's confirmation is not lost with the
# conversation; A change with no observable effect reaches its record; The
# wrong change reaches its record rather than stalling; A later session can
# enumerate a change's branches; An abandoned change's working tree can be
# removed; A later session can read the abandonment rather than infer it.
#
# Each of those scenarios states its outcome as something readable in the
# change's `gate-log.md`. The artifact is named at a fixed location for the
# reason `.claude/worktrees/` and `docs/change-queue.md` are: a location
# stated only in a change's own artifacts is archived with them, and two
# sessions then file the same kind of record in two places. Asserting the
# name verbatim is what gives every one of those obligations a checkable
# subject.
#
# `test-manifest.md` is asserted alongside it because the vocabulary splits
# the persistent stages' traces three ways and names that file as the trace
# for `plan:tests`; a fragment naming the new artifact and not the existing
# one leaves that stage without the trace the requirement assigns it.
#
# What is not asserted: which records are owed, when each is written, and
# which four cases commit on their own rather than with the next commit. All
# prose, verified by reading (tasks 1.9, 6.7).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

assert_contains "$fragment" "gate-log.md" \
  "the recorded gates have a named artifact, so a resuming session reads rather than searches"
assert_contains "$fragment" "test-manifest.md" \
  "the stage traced to the test manifest names the file it is traced from"
