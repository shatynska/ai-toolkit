#!/usr/bin/env bash
# Scenario: An existing block at a different version is reported, not rewritten.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
cat > AGENTS.md <<'BLOCK'
<!-- ai-toolkit:development-workflow v0 -->
<!-- Generated. Do not edit inside this block — it is replaced on update.
     Project-specific conventions belong below the closing marker. -->
this is the stale v0 text, distinguishable from the real fragment
<!-- /ai-toolkit:development-workflow -->
BLOCK
sum_before="$(md5sum AGENTS.md | awk '{print $1}')"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_unchanged "$work/AGENTS.md" "$sum_before" "older-version block is left unchanged, not upgraded"
assert_contains "$work/AGENTS.md" "this is the stale v0 text" "stale content survives"
assert_contains "$report" "existing version 0" "report states the existing version"
assert_contains "$report" "tool carries version $(fragment_version)" "report states the tool's own version"
assert_contains "$report" "out of scope" "reconciliation stated as out of scope"

count="$(grep -c '<!-- ai-toolkit:development-workflow' "$work/AGENTS.md")"
if [ "$count" != "1" ]; then
  echo "FAIL: expected exactly one marker, found $count — no second block appended" >&2
  exit 1
fi
