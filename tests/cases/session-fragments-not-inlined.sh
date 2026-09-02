#!/usr/bin/env bash
# Scenario: A fragment is adopted without tooling (premise half).
# The absent-`version:` rule holds only "while nothing inlines them". This
# case asserts that premise against the library's one inlining tool: it names
# the fragment it does inline and none of the three session-scoped ones.
#
# Unlike the other session-workflow cases, this one reads only files that
# already exist, so it passes before the fragments are written. It is a
# regression guard on a premise, not coverage of new behaviour: teaching
# project-init to inline one of these would make session-fragment-frontmatter.sh's
# version check assert the wrong thing, and nothing else would report it.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

assert_file "$PROJECT_INIT" "the library's one inlining tool"

# Without this the scan below passes vacuously against a tool that names no
# fragment at all — it proves the scan can find a fragment name when one is
# there.
assert_contains "$PROJECT_INIT" "development-workflow" "the tool names the one fragment it does inline"

for name in worktree-isolation change-delivery deferred-work; do
  hits="$(grep -n -F -- "$name" "$PROJECT_INIT")"
  if [ -n "$hits" ]; then
    echo "FAIL: $PROJECT_INIT names the session-scoped fragment $name" >&2
    echo "      A fragment a tool inlines owes a version:, which" >&2
    echo "      session-fragment-frontmatter.sh asserts is absent." >&2
    echo "$hits" >&2
    exit 1
  fi
done
