#!/usr/bin/env bash
# Scenario: The fragment is read even when nothing will be written.
# Distinguishes the fragment's unconditional read from the scoped-to-
# outstanding treatment given to external commands: even though the
# conventions-file concern is already satisfied, the report still needs the
# fragment's version, so its absence still blocks.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

decoy="$TESTDIR/decoy-toolkit"
mkdir -p "$decoy/scripts" "$decoy/rules"
cp "$TOOLKIT_ROOT/scripts/project-init" "$decoy/scripts/project-init" || exit 1
# Deliberately do not copy rules/development-workflow.md.

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
cat > AGENTS.md <<'BLOCK'
<!-- ai-toolkit:development-workflow v1 -->
<!-- Generated. Do not edit inside this block — it is replaced on update.
     Project-specific conventions belong below the closing marker. -->
placeholder
<!-- /ai-toolkit:development-workflow -->
BLOCK
sum_before="$(md5sum AGENTS.md | awk '{print $1}')"

report="$TESTDIR/report.txt"
bash "$decoy/scripts/project-init" >"$report" 2>&1
status=$?

assert_exit 2 "$status" "BLOCKED even though the conventions-file concern is satisfied"
assert_contains "$report" "Outcome: BLOCKED"
assert_unchanged "$work/AGENTS.md" "$sum_before" "no write attempted"
