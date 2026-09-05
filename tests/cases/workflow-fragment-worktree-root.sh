#!/usr/bin/env bash
# Scenario (mechanical half only): A recursive tool does not descend into
# sibling working trees.
#
# The requirement fixes the working-tree root rather than leaving it to the
# fragment's author — "a fixed path within the repository — `.worktrees/`,
# one directory per working tree" — for the stated reason that an obligation
# checked against a path is uncheckable where the path is left to choice.
# Asserting the root verbatim is what that reason buys, and it is the half a
# shell case can reach.
#
# The path must also be harness-neutral: where a harness creates working
# trees at a path of its own, that path is named *beneath* the rule, as that
# harness's binding. Order is one of the few properties of prose a case can
# observe, so it is asserted here rather than left to reading.
#
# Not asserted: that the containment obligations — the ignore entry, and
# scoping every recursive tool that does not read it — are absent from the
# fragment. The same requirement moves them to the capability that owns
# project setup, but no lexical rule separates a stated obligation from a
# mention of one. Verified by reading.
#
# This case follows the normative sentence — the one that says what the
# fragment SHALL name. Two back-references in the change-queue requirement
# once cited the harness path instead; both now cite `.worktrees/`, so the
# conflict this comment recorded no longer exists.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

# Vacuity guard: service neutrality of a path is only meaningful where the
# fragment states a working-tree rule at all.
assert_contains "$fragment" "working tree" \
  "the fragment states the rule whose subject the path below is"

assert_contains "$fragment" ".worktrees/" \
  "the working-tree root is fixed by the specification, so obligations checked against it have a subject"

# `.claude/worktrees/` does not contain the literal `.worktrees/` — the
# character before `worktrees/` there is a slash, not a dot — so the two
# scans below do not alias one another.
neutral="$(grep -n -F -- ".worktrees/" "$fragment" | head -n1 | cut -d: -f1)"
harness="$(grep -n -F -- ".claude/worktrees/" "$fragment" | head -n1 | cut -d: -f1)"

if [ -z "$neutral" ]; then
  echo "FAIL: $fragment names no harness-neutral working-tree root" >&2
  exit 1
fi

if [ -n "$harness" ]; then
  if [ "$harness" -le "$neutral" ]; then
    echo "FAIL: $fragment names a harness's working-tree path (line $harness) at or before the" >&2
    echo "      harness-neutral root (line $neutral). The neutral path is the rule; a harness's" >&2
    echo "      path is named beneath it as that harness's binding, not in place of it." >&2
    exit 1
  fi
fi
