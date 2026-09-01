#!/usr/bin/env bash
# Scenario: A project's adopted version is readable (body half).
# What reaches a project must be the fragment the tool carries, not a
# paraphrase of it. Asserted structurally — version marker plus a byte-for-byte
# body comparison — so that renaming a section does not break this case for a
# reason unrelated to what it tests.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_file "$work/AGENTS.md"

version="$(fragment_version)" || exit 1
assert_contains "$work/AGENTS.md" "<!-- ai-toolkit:development-workflow v$version -->" "opening marker carries the fragment's own version"
assert_contains "$work/AGENTS.md" "<!-- /ai-toolkit:development-workflow -->" "closing marker present"

# The fragment's body is everything after the frontmatter's closing ---.
fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
closing="$(grep -n '^---$' "$fragment" | sed -n '2p' | cut -d: -f1)"
tail -n "+$((closing + 1))" "$fragment" > "$TESTDIR/expected-body.txt"

# The inlined body sits between the generated notice and the closing marker.
awk '
  /^<!-- \/ai-toolkit:development-workflow -->$/ { exit }
  started { print }
  /Project-specific conventions belong below the closing marker\. -->$/ { started = 1 }
' "$work/AGENTS.md" > "$TESTDIR/actual-body.txt"

if ! diff -u "$TESTDIR/expected-body.txt" "$TESTDIR/actual-body.txt" > "$TESTDIR/body.diff"; then
  echo "FAIL: inlined body differs from the fragment the tool carries" >&2
  sed 's/^/        /' "$TESTDIR/body.diff" >&2
  exit 1
fi

if [ ! -s "$TESTDIR/actual-body.txt" ]; then
  echo "FAIL: extracted an empty body — the comparison above would pass vacuously" >&2
  exit 1
fi
