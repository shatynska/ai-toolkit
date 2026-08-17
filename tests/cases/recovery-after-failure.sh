#!/usr/bin/env bash
# Scenario: A partial run is recoverable by re-running (verifies the
# documented recovery path actually works, not merely that idempotency is
# implemented elsewhere).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

stubbin="$TESTDIR/stubbin"
mkdir -p "$stubbin"
cat > "$stubbin/openspec" <<'STUB'
#!/usr/bin/env bash
exit 1
STUB
chmod +x "$stubbin/openspec"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

PATH="$stubbin:$PATH" bash "$PROJECT_INIT" >/dev/null 2>&1
first_status=$?
assert_exit 1 "$first_status" "first run fails as expected"
assert_file "$work/.git/HEAD" "repository was created before the failure"

report2="$TESTDIR/report2.txt"
bash "$PROJECT_INIT" >"$report2" 2>&1
second_status=$?

assert_exit 0 "$second_status" "re-run completes the unfinished concern"
assert_contains "$report2" "repository: already present" "the already-completed concern is skipped, not redone"
assert_contains "$report2" "specification tooling: created" "the previously-failed concern is now completed"
assert_file "$work/openspec/config.yaml" "specification tooling now initialized"
assert_contains "$report2" "Outcome: SUCCESS"
