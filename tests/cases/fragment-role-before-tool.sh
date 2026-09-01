#!/usr/bin/env bash
# Scenarios: Rules remain meaningful without the toolkit installed;
# A plausible wrong tool is excluded by name.
# The workflow rule fragment must state every obligation as a role and confine
# harness-specific names to a binding paragraph. A project that carries the
# managed block without this library installed reads the roles; a name that
# leaked into one is a dangling reference there.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

# Tokens naming one harness's agents, commands or verdict vocabulary. Matched
# case-sensitively: role text says "proceeding" freely, and only the verdict
# `PROCEED` is harness-specific. The slash-command pattern is deliberately
# generic — enumerating only the commands in use today would let the next one
# added to role prose through, which is the dangling reference the rule
# exists to prevent. It matches a backtick-quoted command so that an ordinary
# "and/or" in prose does not trip it.
offenders="$(awk '
  /^_Claude Code binding:_/ { binding = 1 }
  /^[[:space:]]*$/          { binding = 0 }
  binding                   { next }
  /ai-toolkit:/ || /PROCEED/ || /CHANGES REQUIRED/ || /REJECT/ ||
  /\[MINOR\]/ || /openspec-/ || /`\/[a-z][a-z-]*/ { printf "  line %d: %s\n", NR, $0 }
' "$fragment")"

if [ -n "$offenders" ]; then
  echo "FAIL: harness-specific name outside a binding paragraph in $fragment" >&2
  echo "$offenders" >&2
  exit 1
fi

# The constraint is only meaningful if binding paragraphs exist to hold them.
bindings="$(grep -c '^_Claude Code binding:_' "$fragment")"
if [ "$bindings" -lt 1 ]; then
  echo "FAIL: no binding paragraph found — the check above would pass vacuously" >&2
  exit 1
fi

# The negative binding must name the excluded agent, per the requirement that
# a plausible wrong candidate be excluded by name rather than left available.
assert_contains "$fragment" "Do not use" "a negative binding is stated"
