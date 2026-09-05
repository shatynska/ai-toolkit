#!/usr/bin/env bash
# Scenario (mechanical half only): A setup obligation found while writing the
# fragment is recorded, not added.
#
# The fragment is read by every session in an adopting project, so it carries
# only obligations a session acts on. Four rules drawn from consuming
# projects were named and excluded: continuous integration failing rather
# than skipping on a dependency it cannot reach, a commit or push hook not
# being an authority a completion claim may rest on, secrets excluded by the
# ignore file rather than by vigilance, and the project stating its test
# command and test-path glob.
#
# Only one of the four is scannable, and this case asserts that one and
# records why the other three are not:
#
#   - The secrets rule — DERIVED anchor. The excluded rule is "secrets
#     excluded by the ignore file rather than by vigilance", so the scan
#     requires *both* halves on one line. The word "secret" alone is not
#     enough: the commit rule the fragment legitimately carries tells a
#     session to check that no secret is included before committing, which
#     is a per-commit obligation rather than a setup one, and a bare scan
#     fails the fragment it was written to accept. Requiring the ignore file
#     beside it is what separates the excluded rule from the kept one.
#   - The hook rule is NOT scanned: the stage vocabulary requires the
#     fragment to name `--no-verify` and the hooks it bypasses, so a scan for
#     "hook" would fail the fragment it was written to accept.
#   - The continuous-integration rule is NOT scanned: the publication
#     requirement obliges the fragment to name continuous integration among
#     its assumptions, so the same collision applies.
#   - The test-command/test-path-glob rule is NOT scanned. What the
#     requirement excludes is the *obligation* on a project to state them —
#     `project-foundation` already owns it — and not a mention. The fragment
#     names both at the test-derivation gate, pointing the test author at
#     where the project keeps them, which is a pointer rather than a second
#     owner. No lexical rule separates the two, so a scan for the phrase
#     fails a compliant fragment. Whether that pointer is inside the
#     exclusion or outside it is a judgment; it is recorded as an open
#     question in the change's `test-plan.md` rather than settled here.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

# Vacuity guard: a fragment that is empty, or that states no session rules at
# all, would satisfy the negative below for the wrong reason.
assert_contains "$fragment" "pull request" \
  "the fragment states the session obligations these setup rules were excluded from"

hits="$(grep -n -i -E -- 'secret.*ignore|ignore.*secret' "$fragment")"
if [ -n "$hits" ]; then
  echo "FAIL: $fragment carries a one-time setup obligation (secrets) that a session never discharges" >&2
  echo "      It belongs to the capability that owns project setup, and is recorded there rather" >&2
  echo "      than paid for on every read by every session in every adopting project." >&2
  echo "$hits" >&2
  exit 1
fi
