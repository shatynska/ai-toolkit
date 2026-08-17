#!/usr/bin/env bash
# Scenarios: A delegated command's writes are attributed, not concealed;
# never-overwrite bounded to the tool's own writes (adoption path).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
git init -q
git config user.email "t@t.com"
git config user.name "t"
cat > AGENTS.md <<'PROJECT'
# Existing project
Some conventions already recorded here.
PROJECT
echo "print('hi')" > main.py
git add . && git commit -q -m "initial history"

before="$(cat AGENTS.md)"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"

after="$(cat AGENTS.md)"
case "$after" in
  "$before"*)
    : # new content starts with the old content, i.e. block was appended
    ;;
  *)
    echo "FAIL: AGENTS.md content was not a simple append of the original" >&2
    exit 1
    ;;
esac
assert_contains "$work/AGENTS.md" "ai-toolkit:development-workflow" "block appended"

assert_contains "$report" "specification tooling: created via" "delegated command's writes attributed by name, not concealed"
assert_file "$work/openspec/config.yaml" "specification tooling initialized"
