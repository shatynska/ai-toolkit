#!/usr/bin/env bash
# Scenarios (mechanical half only): A project adopts isolation without
# delivery; A project adopts delivery without isolation; The gate is
# checkable without a delivery fragment.
#
# No session-scoped fragment may name another. Each has to be adoptable on
# its own, so a sentence naming a sibling is a dangling reference in a
# project that adopted only one of them — and a gate expressed as "after the
# other fragment's step" is unsatisfiable there, which is the specific way
# the separation is lost.
#
# Only the naming half is asserted here. Whether each gate is stated as an
# observable the fragment can check by itself is a property of the prose and
# is verified by reading (tasks 1.8, 1.9, 4.2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

names="worktree-isolation change-delivery deferred-work"

for name in $names; do
  fragment="$TOOLKIT_ROOT/rules/$name.md"
  assert_file "$fragment" "session-scoped fragment: $name"

  # `docs/deferred-work.md` is a project file the deferred-work fragment is
  # required to name at that exact path. It is not a reference to a sibling
  # fragment, so it is removed before the scan — otherwise the one path the
  # delta fixes would read as the reference the delta forbids.
  scrubbed="$TESTDIR/$name.scrubbed"
  sed 's|docs/deferred-work\.md||g' "$fragment" > "$scrubbed"

  if [ ! -s "$scrubbed" ]; then
    echo "FAIL: $fragment is empty after scrubbing — the scan below would pass vacuously" >&2
    exit 1
  fi

  for sibling in $names; do
    if [ "$sibling" = "$name" ]; then
      continue
    fi
    hits="$(grep -n -F -- "$sibling" "$scrubbed")"
    if [ -n "$hits" ]; then
      echo "FAIL: $fragment names the sibling session-scoped fragment $sibling" >&2
      echo "$hits" >&2
      exit 1
    fi
  done
done
