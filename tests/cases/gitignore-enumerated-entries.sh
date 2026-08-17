#!/usr/bin/env bash
# Scenario: Created ignore file carries no stack assumption.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

bash "$PROJECT_INIT" >/dev/null 2>&1

for entry in '.env' '.env.*' '!.env.example' '.DS_Store' 'Thumbs.db' '.idea/' '.vscode/'; do
  assert_contains "$work/.gitignore" "$entry" "enumerated entry present: $entry"
done

# No stack-specific entry: none of these language-specific markers appear.
for forbidden in 'node_modules' '__pycache__' 'target/' 'venv' '.venv' 'dist/' 'build/'; do
  if grep -qF -- "$forbidden" "$work/.gitignore"; then
    echo "FAIL: stack-specific entry present in generated .gitignore: $forbidden" >&2
    exit 1
  fi
done
