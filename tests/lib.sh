#!/usr/bin/env bash
# Assertion helpers sourced by each file in tests/cases/*.sh.
# A failed assertion prints a message to stderr and exits the case
# non-zero immediately; tests/run.sh treats that as the case failing.

assert_exit() {
  local expected="$1" actual="$2" msg="${3:-}"
  if [ "$actual" != "$expected" ]; then
    echo "FAIL: expected exit code $expected, got $actual${msg:+ ($msg)}" >&2
    exit 1
  fi
}

assert_file() {
  local path="$1" msg="${2:-}"
  if [ ! -f "$path" ]; then
    echo "FAIL: expected file to exist: $path${msg:+ ($msg)}" >&2
    exit 1
  fi
}

assert_file_absent() {
  local path="$1" msg="${2:-}"
  if [ -e "$path" ]; then
    echo "FAIL: expected path to be absent: $path${msg:+ ($msg)}" >&2
    exit 1
  fi
}

assert_unchanged() {
  local path="$1" expected_sum="$2" msg="${3:-}"
  local actual_sum
  actual_sum="$(md5sum "$path" 2>/dev/null | awk '{print $1}')"
  if [ "$actual_sum" != "$expected_sum" ]; then
    echo "FAIL: expected $path unchanged, checksum differs${msg:+ ($msg)}" >&2
    exit 1
  fi
}

assert_contains() {
  local path="$1" pattern="$2" msg="${3:-}"
  if ! grep -qF -- "$pattern" "$path" 2>/dev/null; then
    echo "FAIL: expected $path to contain: $pattern${msg:+ ($msg)}" >&2
    exit 1
  fi
}

# Reads the `version:` from a toolkit's workflow rule fragment, mirroring the
# parse in scripts/project-init. Cases assert against this rather than a
# literal, so that editing the fragment does not break a case for a reason
# unrelated to what it tests. Defaults to the toolkit under test; pass a root
# to read a decoy's fragment instead.
#
# Returns non-zero rather than exiting. Every call site is a command
# substitution, and an `exit` inside `$( )` ends only the subshell — the
# caller would carry on with an empty version, degrading its assertions to
# ones that pass against anything. Callers MUST therefore write:
#
#   version="$(fragment_version)" || exit 1
#
# so the failure reaches the case itself. `|| exit 1` is not optional
# defensiveness here; without it the guard below is unreachable.
fragment_version() {
  local root="${1:-$TOOLKIT_ROOT}"
  local fragment="$root/rules/development-workflow.md"
  local version
  version="$(sed -n '2,/^---$/p' "$fragment" 2>/dev/null | sed -n 's/^version:[[:space:]]*//p' | head -n1)"
  if [ -z "$version" ]; then
    echo "FAIL: could not read version from $fragment" >&2
    return 1
  fi
  printf '%s\n' "$version"
}
