#!/usr/bin/env bash
# Scenarios: Empty directory takes the new-project path;
# Completion is verifiable rather than asserted;
# Discovery is named, not started; Nothing is committed without confirmation
# (script-side: it never runs `git commit` at all).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
report="$TESTDIR/report.txt"

bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status" "empty directory should succeed"
assert_file "$work/.git/HEAD" "git repository initialized"
assert_file "$work/openspec/config.yaml" "specification tooling initialized"
assert_file "$work/.gitignore" "ignore file created"
assert_file "$work/AGENTS.md" "conventions file created"
assert_contains "$work/AGENTS.md" "ai-toolkit:development-workflow" "managed block present"
assert_contains "$report" "Outcome: SUCCESS" "reports success"
assert_contains "$report" "Target:" "states the target directory"
assert_contains "$report" "foundation discovery" "names foundation discovery as next step"
assert_contains "$report" "Import needed:" "neither file existed — CLAUDE.md does not import AGENTS.md, so the import line must be reported"

# Discovery is named, not started: no foundation change was created.
if [ -d "$work/openspec/changes" ] && find "$work/openspec/changes" -mindepth 1 -maxdepth 1 -not -name archive | grep -q .; then
  echo "FAIL: a change directory exists — foundation discovery was started, not merely named" >&2
  exit 1
fi

# Nothing is committed without confirmation: the script never commits.
if git -C "$work" log >/dev/null 2>&1; then
  echo "FAIL: a commit exists after a bare run — the script must never commit" >&2
  exit 1
fi
