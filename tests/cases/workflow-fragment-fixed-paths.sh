#!/usr/bin/env bash
# Scenarios (mechanical half only): A recursive tool does not descend into
# sibling working trees; An identified change is not filed as deferred work;
# The change queue does not yet exist.
#
# The specification fixes these paths rather than leaving them to the
# fragment's author, and gives one reason for all of them: a path stated only
# in a change's own artifacts is archived with them, and every obligation
# that references it becomes uncheckable against the fragment afterwards.
# Asserting the paths verbatim is what that reason buys.
#
# Both artifacts are asserted because the requirement obliges the fragment to
# state the distinction between them — an entry swept on being shipped and an
# entry swept on being fixed — which it cannot do while naming only one.
#
# The obligations attached to each path are prose and are verified by
# reading: the containment obligations on `.claude/worktrees/`, the
# create-it-if-absent direction on `docs/change-queue.md`, and that
# `docs/deferred-work.md` is named for the distinction and not as a
# destination for identified work (tasks 1.4, 1.14).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

assert_contains "$fragment" ".claude/worktrees/" \
  "the working-tree location is a fixed path, so the containment obligations have a checkable subject"
assert_contains "$fragment" "docs/change-queue.md" \
  "identified work is routed to the queue at the path the specification fixes"
assert_contains "$fragment" "docs/deferred-work.md" \
  "the deferred-work file is named, so the distinction between the two artifacts can be stated"
