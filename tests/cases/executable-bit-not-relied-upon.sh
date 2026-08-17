#!/usr/bin/env bash
# Scenario: The executable bit is not relied upon.
# Every other case invokes the script via `bash <path>` already; this case
# makes the property explicit by stripping the executable bit first.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

copy_toolkit="$TESTDIR/copy-toolkit"
mkdir -p "$copy_toolkit/scripts" "$copy_toolkit/rules"
cp "$TOOLKIT_ROOT/scripts/project-init" "$copy_toolkit/scripts/project-init" || exit 1
cp "$TOOLKIT_ROOT/rules/development-workflow.md" "$copy_toolkit/rules/development-workflow.md" || exit 1
chmod -x "$copy_toolkit/scripts/project-init"
script_copy="$copy_toolkit/scripts/project-init"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

bash "$script_copy" >/dev/null 2>&1
status=$?

assert_exit 0 "$status" "runs fine without the executable bit, since it is invoked via bash"
assert_file "$work/AGENTS.md" "initialization completed normally"
