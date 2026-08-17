#!/usr/bin/env bash
# Scenarios: Existing repository takes the adoption path;
# Adoption does not create a foundation change but names it as available.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
git init -q
git config user.email "t@t.com"
git config user.name "t"
echo "print('hi')" > main.py
git add . && git commit -q -m "initial history"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_contains "$report" "Outcome: SUCCESS"

if [ -d "$work/openspec/changes" ] && find "$work/openspec/changes" -mindepth 1 -maxdepth 1 -name '*foundation*' | grep -q .; then
  echo "FAIL: a foundation change was created — adoption must not create one" >&2
  exit 1
fi

assert_contains "$report" "foundation discovery" "names foundation discovery as available"
if grep -q "Next step: foundation discovery —" "$report"; then
  echo "FAIL: adoption report should offer foundation as available, not as the mandatory next step" >&2
  exit 1
fi
