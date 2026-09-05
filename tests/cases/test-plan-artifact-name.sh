#!/usr/bin/env bash
# Scenarios (mechanical half only): The manifest carries runnable test
# identifiers; The manifest is pointed to twice.
#
# The artifact the test-authoring pass writes is renamed from
# `test-manifest.md` to `test-plan.md` — "that exact name, so the `rules/`
# fragment and any later reader can name it". A rename that lands in one
# publication and not the other leaves the second pointer aimed at a file no
# pass writes, which is exactly the reachability the two-pointer requirement
# exists to buy. Both halves are names, so both are mechanical.
#
# The scan is over the shipped library assets that carry the two pointers —
# `rules/` for the fragment, `agents/` for the agent's own contract — and no
# filename is hardcoded: neither requirement fixes which file in either
# directory carries the name, so pinning one would test this repository's
# current layout rather than the requirement.
#
# `openspec/` is deliberately outside the scan. The specifications under
# `openspec/specs/` still carry the superseded name until this change is
# archived, and the change's own artifacts quote both names in stating the
# rename; a scan including either would fail on text the change requires.
#
# Every file under the two directories is scanned, the eval-fixture
# `.checks.yaml` files included: a fixture that still names the superseded
# artifact would have a pass judged against a filename no pass writes.
#
# Not asserted: that the manifest's contents match the enumerated minimum,
# that its test identifiers are runner-selectable, or that a pass actually
# reports the path. Those are properties of a pass's output rather than of
# the library, and there is no program here to run a pass against.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

found_rules=""
found_agents=""
stale=""

for dir in rules agents; do
  if [ ! -d "$TOOLKIT_ROOT/$dir" ]; then
    echo "FAIL: $TOOLKIT_ROOT/$dir does not exist — the scans below would pass vacuously" >&2
    exit 1
  fi

  hits="$(grep -rl -F -- "test-plan.md" "$TOOLKIT_ROOT/$dir" 2>/dev/null)"
  case "$dir" in
    rules)  found_rules="$hits" ;;
    agents) found_agents="$hits" ;;
  esac

  hits="$(grep -rn -F -- "test-manifest.md" "$TOOLKIT_ROOT/$dir" 2>/dev/null)"
  if [ -n "$hits" ]; then
    stale="$stale
$hits"
  fi
done

if [ -z "$found_rules" ]; then
  echo "FAIL: no fragment under $TOOLKIT_ROOT/rules names test-plan.md" >&2
  echo "      The manifest is not an artifact the OpenSpec schema defines, so the fragment" >&2
  echo "      directing that it be read before implementing is one of its two pointers." >&2
  exit 1
fi

if [ -z "$found_agents" ]; then
  echo "FAIL: no agent under $TOOLKIT_ROOT/agents names test-plan.md" >&2
  echo "      The agent's own contract is the second pointer, deliberately redundant with the" >&2
  echo "      fragment because the fragment's import path is machine-local." >&2
  exit 1
fi

if [ -n "$stale" ]; then
  echo "FAIL: the superseded artifact name test-manifest.md survives in a shipped asset" >&2
  echo "$stale" >&2
  exit 1
fi
