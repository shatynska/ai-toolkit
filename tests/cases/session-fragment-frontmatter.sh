#!/usr/bin/env bash
# Scenario: A fragment carries no version claim.
# Each session-scoped fragment declares `kind: standing-constraint` and, for
# as long as no tool inlines it, no `version:`. A version nothing obliges
# anyone to increment reads as a currency claim that nothing maintains — see
# session-fragments-not-inlined.sh, which asserts the premise this rests on.
#
# Also asserts the flat layout AGENTS.md requires: each fragment sits directly
# under rules/, with no grouping subdirectory. Nothing reports a misplaced
# fragment at load time, so a case is the only thing that would.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

for name in worktree-isolation change-delivery deferred-work; do
  fragment="$TOOLKIT_ROOT/rules/$name.md"

  # Checked before the existence assertion below, not after: a fragment that
  # sits ONLY in a subdirectory would otherwise trip assert_file first and be
  # reported as absent, which is the wrong diagnosis for the wrong defect.
  nested="$(find "$TOOLKIT_ROOT/rules" -mindepth 2 -name "$name.md" 2>/dev/null)"
  if [ -n "$nested" ]; then
    echo "FAIL: $name.md sits below rules/ rather than directly under it" >&2
    echo "$nested" >&2
    exit 1
  fi

  assert_file "$fragment" "session-scoped fragment: $name"

  # Frontmatter is lines 2..closing-1, where closing is the second `^---$`.
  # Bounded rather than open-ended so that a `version:` line in the body
  # cannot be read as frontmatter, and an unterminated block fails loudly
  # rather than silently widening the region every check below reads.
  if [ "$(head -n 1 "$fragment")" != "---" ]; then
    echo "FAIL: $fragment does not open with a frontmatter delimiter" >&2
    exit 1
  fi

  closing="$(grep -n '^---$' "$fragment" | sed -n '2p' | cut -d: -f1)"
  if [ -z "$closing" ]; then
    echo "FAIL: $fragment has no closing frontmatter delimiter" >&2
    exit 1
  fi

  frontmatter="$(sed -n "2,$((closing - 1))p" "$fragment")"
  if [ -z "$frontmatter" ]; then
    echo "FAIL: $fragment has an empty frontmatter block — the checks below would pass vacuously" >&2
    exit 1
  fi

  # `closing` is the second `^---$` in the file, which is the real delimiter
  # only while one exists. Delete it and the next `---` in the body takes its
  # place, silently widening the region every check below reads: `kind:` is
  # still on line 2 so they pass, against a file whose YAML does not parse.
  # Requiring the region to be keys alone is what makes that fail loudly.
  while IFS= read -r fm_line; do
    [ -z "$fm_line" ] && continue
    case "$fm_line" in
      '#'*) continue ;;
    esac
    if ! printf '%s\n' "$fm_line" | grep -q '^[A-Za-z_][A-Za-z0-9_-]*:'; then
      echo "FAIL: $fragment has a non-key line inside its frontmatter region:" >&2
      printf '  %s\n' "$fm_line" >&2
      echo "  the closing '---' is probably missing, and the region has widened into the body" >&2
      exit 1
    fi
  done <<EOF
$frontmatter
EOF

  if ! printf '%s\n' "$frontmatter" | grep -q '^kind:[[:space:]]*standing-constraint[[:space:]]*$'; then
    echo "FAIL: $fragment does not declare kind: standing-constraint" >&2
    printf '%s\n' "$frontmatter" >&2
    exit 1
  fi

  if printf '%s\n' "$frontmatter" | grep -q '^version:'; then
    echo "FAIL: $fragment declares a version while nothing inlines it" >&2
    printf '%s\n' "$frontmatter" >&2
    exit 1
  fi

done
