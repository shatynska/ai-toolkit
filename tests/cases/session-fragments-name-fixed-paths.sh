#!/usr/bin/env bash
# Scenarios (mechanical half only): A recursive tool does not descend into
# sibling working trees; The deferred-work file does not yet exist.
#
# The delta fixes two paths rather than leaving them to the fragment's
# author, and gives one reason for both: a path stated only in a change's own
# artifacts is archived with them, and every obligation that references it
# becomes uncheckable against the fragment afterwards. Asserting the paths
# verbatim is what that reason buys — the containment obligations attached to
# `.claude/worktrees/`, and the create-it-if-absent direction attached to
# `docs/deferred-work.md`, are prose and are verified by reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

isolation="$TOOLKIT_ROOT/rules/worktree-isolation.md"
assert_file "$isolation" "session-scoped fragment: worktree-isolation"
assert_contains "$isolation" ".claude/worktrees/" \
  "the fragment names the working-tree location as a fixed path, so the containment obligations have a checkable subject"

deferred="$TOOLKIT_ROOT/rules/deferred-work.md"
assert_file "$deferred" "session-scoped fragment: deferred-work"
assert_contains "$deferred" "docs/deferred-work.md" \
  "the fragment names the deferred-work file at the path the delta fixes"
