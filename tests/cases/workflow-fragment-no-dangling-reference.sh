#!/usr/bin/env bash
# Scenario (mechanical half only): A reader of a project's conventions finds
# no dangling reference.
#
# In a consuming project the conventions file holds a copy of the fragment's
# body and no rules/ directory is read, so a sentence naming a `rules/` path,
# a fragment file, or an `@` import names something the reader cannot open.
# The rule binds the binding fragment as well as the workflow one.
#
# Only the naming half is asserted. That every *other* reference resolves
# within the document — a section cross-reference, a named artifact the
# project holds — is a property of the prose and is verified by reading
# (tasks 1.16, 2.4). So is the positive half of the same requirement: that
# the workflow fragment refers to the binding as an adjacent section of the
# same conventions file, conditioned on the project carrying it. No lexical
# rule separates that sentence from any other.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment_names="worktree-isolation.md change-delivery.md deferred-work.md development-workflow.md development-workflow-database.md"

for base in development-workflow development-workflow-database; do
  fragment="$TOOLKIT_ROOT/rules/$base.md"
  assert_file "$fragment" "publication of the session obligations"

  # The body is what reaches a project; the frontmatter is stripped by the
  # inlining tool. Scanning the body is what the requirement is stated over.
  closing="$(grep -n '^---$' "$fragment" | sed -n '2p' | cut -d: -f1)"
  if [ -z "$closing" ]; then
    echo "FAIL: $fragment has no closing frontmatter delimiter — the body cannot be located" >&2
    exit 1
  fi

  body="$TESTDIR/$base.body"
  # `docs/deferred-work.md` is a project file the workflow fragment is
  # required to name, in order to state how it differs from the change
  # queue. It is not a reference to a fragment, so it is removed before the
  # scan — otherwise a path the requirement obliges would read as the
  # reference the requirement forbids.
  tail -n "+$((closing + 1))" "$fragment" | sed 's|docs/deferred-work\.md||g' > "$body"

  if [ ! -s "$body" ]; then
    echo "FAIL: $fragment has an empty body — the scans below would pass vacuously" >&2
    exit 1
  fi

  hits="$(grep -n -F -- "rules/" "$body")"
  if [ -n "$hits" ]; then
    echo "FAIL: $fragment names a rules/ path, which no consuming project holds" >&2
    echo "$hits" >&2
    exit 1
  fi

  for name in $fragment_names; do
    hits="$(grep -n -F -- "$name" "$body")"
    if [ -n "$hits" ]; then
      echo "FAIL: $fragment names the fragment file $name" >&2
      echo "$hits" >&2
      exit 1
    fi
  done

  for import in "@~/" "@rules/" "@AGENTS.md" "@CLAUDE.md"; do
    hits="$(grep -n -F -- "$import" "$body")"
    if [ -n "$hits" ]; then
      echo "FAIL: $fragment carries an import ($import), which resolves only where this library is checked out" >&2
      echo "$hits" >&2
      exit 1
    fi
  done
done
