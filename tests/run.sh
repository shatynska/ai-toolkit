#!/usr/bin/env bash
# Discovers and runs every case in tests/cases/*.sh, each in its own
# isolated temporary directory. Exits non-zero if any case fails.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

export TOOLKIT_ROOT
export TESTLIB="$SCRIPT_DIR/lib.sh"
export PROJECT_INIT="$TOOLKIT_ROOT/scripts/project-init"

pass=0
fail=0

for case_file in "$SCRIPT_DIR"/cases/*.sh; do
  [ -e "$case_file" ] || continue
  name="$(basename "$case_file" .sh)"

  tmpdir="$(mktemp -d)"
  export TESTDIR="$tmpdir"

  output="$(bash "$case_file" 2>&1)"
  status=$?

  if [ "$status" -eq 0 ]; then
    echo "ok    $name"
    pass=$((pass + 1))
  else
    echo "FAIL  $name"
    # shellcheck disable=SC2001 # per-line ^-anchored prefixing across a
    # multi-line string; ${var//search/replace} does not replace this cleanly.
    echo "$output" | sed 's/^/        /'
    fail=$((fail + 1))
  fi

  rm -rf "$tmpdir"
done

echo ""
echo "$pass passed, $fail failed"

if [ "$fail" -gt 0 ]; then
  exit 1
fi
exit 0
