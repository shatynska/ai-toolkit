#!/usr/bin/env bash
# Accounts for no scenario of its own. The removed requirement withholding a
# `version` from a session-scoped fragment states in its migration that the
# binding fragment declares `kind: standing-constraint` and a `version` —
# permitted rather than owed until the queued tooling change inlines it, and
# owed from then. This case fixes that frontmatter now, so the interval is
# the bounded one the migration names rather than an unmarked file.
#
# Also asserts the flat layout AGENTS.md requires. Nothing reports a
# misplaced fragment at load time, so a case is the only thing that would.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

base="development-workflow-database"
fragment="$TOOLKIT_ROOT/rules/$base.md"

# Checked before the existence assertion, not after: a fragment sitting only
# in a subdirectory would otherwise be reported as absent, which is the wrong
# diagnosis for the wrong defect.
nested="$(find "$TOOLKIT_ROOT/rules" -mindepth 2 -name "$base.md" 2>/dev/null)"
if [ -n "$nested" ]; then
  echo "FAIL: $base.md sits below rules/ rather than directly under it" >&2
  echo "$nested" >&2
  exit 1
fi

assert_file "$fragment" "the database binding fragment"

# Frontmatter is lines 2..closing-1, where closing is the second `^---$`.
# Bounded rather than open-ended so that a `version:` line in the body cannot
# be read as frontmatter, and an unterminated block fails loudly rather than
# silently widening the region every check below reads.
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

# A `---` deleted from the body would let the region widen silently; requiring
# it to be keys alone is what makes that fail loudly instead.
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

if ! printf '%s\n' "$frontmatter" | grep -q '^version:[[:space:]]*[0-9][0-9]*[[:space:]]*$'; then
  echo "FAIL: $fragment does not declare a numeric version" >&2
  printf '%s\n' "$frontmatter" >&2
  exit 1
fi
