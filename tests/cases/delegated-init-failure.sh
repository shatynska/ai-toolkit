#!/usr/bin/env bash
# Scenario: Failure midway leaves a reported, recoverable state.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

stubbin="$TESTDIR/stubbin"
mkdir -p "$stubbin"
cat > "$stubbin/openspec" <<'STUB'
#!/usr/bin/env bash
echo "stubbed openspec: deliberate failure" >&2
exit 1
STUB
chmod +x "$stubbin/openspec"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
PATH="$stubbin:$PATH" bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 1 "$status" "ERROR when the delegated initializer fails"
assert_contains "$report" "Outcome: ERROR"
assert_file "$work/.git/HEAD" "repository initialization, which came first, is left in place"
assert_file_absent "$work/openspec/config.yaml" "specification tooling was not completed"
assert_contains "$report" "repository: created" "completed concern named"
