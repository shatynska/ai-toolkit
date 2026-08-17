#!/usr/bin/env bash
# Scenario: A subdirectory of an existing repository is not treated as
# already initialized.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

outer="$TESTDIR/outer"
mkdir -p "$outer"
cd "$outer" || exit 1
git init -q
git config user.email "t@t.com"
git config user.name "t"
echo x > outer-file.txt
git add . && git commit -q -m "outer history"

inner="$outer/inner"
mkdir -p "$inner"
cd "$inner" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_contains "$report" "repository: created" "the repository concern is reported unsatisfied for the inner target, not inherited from the outer repository"
assert_file "$inner/.git/HEAD" "a repository was initialized rooted at the target"

# Mode derives from the NEW repository's own (empty) commit history, not
# the outer repository's — so this is new-project mode, not adoption.
assert_contains "$report" "foundation discovery" "names foundation discovery as the next step (new-project ending)"
if git -C "$inner" log >/dev/null 2>&1; then
  echo "FAIL: the new inner repository has commits — mode should derive from its own empty history" >&2
  exit 1
fi

# The outer repository's history is untouched.
if ! git -C "$outer" log --oneline | grep -q "outer history"; then
  echo "FAIL: the outer repository's history was altered" >&2
  exit 1
fi
