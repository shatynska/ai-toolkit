#!/usr/bin/env bash
# Scenario (mechanical half only): A session obligation is stated once.
#
# The obligations this capability governs are published in two places and no
# more: the workflow fragment and the database binding fragment. The half a
# shell case can reach is the set itself — that both publications exist, that
# each sits directly under rules/ per the flat layout AGENTS.md requires, and
# that the three fragments the consolidation replaces are gone. Whether an
# amendment lands in one text rather than two is a property of a future edit
# and is not observable here; it is what the set being this size buys.
#
# The absence assertions are the point of the case rather than incidental:
# while the three files remain, the same obligation is stated twice, which is
# the state the requirement forbids.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

for base in development-workflow development-workflow-database; do
  fragment="$TOOLKIT_ROOT/rules/$base.md"

  # Checked before the existence assertion, not after: a fragment that sits
  # only in a subdirectory would otherwise be reported as absent, which is the
  # wrong diagnosis for the wrong defect.
  nested="$(find "$TOOLKIT_ROOT/rules" -mindepth 2 -name "$base.md" 2>/dev/null)"
  if [ -n "$nested" ]; then
    echo "FAIL: $base.md sits below rules/ rather than directly under it" >&2
    echo "$nested" >&2
    exit 1
  fi

  assert_file "$fragment" "publication of the session obligations"

  if [ ! -s "$fragment" ]; then
    echo "FAIL: $fragment is empty" >&2
    exit 1
  fi
done

for name in worktree-isolation change-delivery deferred-work; do
  assert_file_absent "$TOOLKIT_ROOT/rules/$name.md" \
    "consolidated into the workflow fragment; a second text of one obligation is what the publication set excludes"
done
