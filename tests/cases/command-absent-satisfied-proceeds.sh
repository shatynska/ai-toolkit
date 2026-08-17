#!/usr/bin/env bash
# Scenario: A command missing for an already-satisfied concern does not block.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
git init -q
git config user.email "t@t.com"
git config user.name "t"
echo x > f.txt
git add . && git commit -q -m initial
openspec init --tools claude --no-animation . >/dev/null 2>&1

# Now build a PATH with openspec genuinely absent — the specification
# tooling concern is already satisfied, so its command should never be
# consulted, and the run should proceed for the remaining concerns.
filtered_path="$(echo "$PATH" | tr ':' '\n' | grep -v npm-global | paste -sd: -)"

report="$TESTDIR/report.txt"
PATH="$filtered_path" bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status" "not BLOCKED — the missing command belongs to a concern that is already satisfied"
assert_contains "$report" "specification tooling: already present"
assert_file "$work/.gitignore" "the run proceeds to complete the remaining concerns"
assert_file "$work/AGENTS.md" "the run proceeds to complete the remaining concerns"
