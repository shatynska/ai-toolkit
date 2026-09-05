#!/usr/bin/env bash
# Scenario (mechanical half only): The test-authoring dispatch has the inputs
# it requires.
#
# The fragment's own test-design gate dispatches an independent test author,
# and that author's dispatch contract requires a test command and a test-path
# glob as essential inputs. A fragment mandating the dispatch without asking
# the project to supply them states a gate no project can pass without
# inventing the inputs itself. Both are named terms, so a case can assert the
# fragment asks for them by name.
#
# That the project's conventions actually carry the two values, and that an
# existing foundation section satisfies the demand rather than owing a second
# statement, are properties of a consuming project and of prose — verified by
# reading (task 1.15).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

# Without this the two assertions below could sit anywhere in the fragment;
# they are owed because the fragment mandates the dispatch that needs them.
assert_contains "$fragment" "Test design before implementation" \
  "the gate whose dispatch requires these inputs is stated"

assert_contains "$fragment" "test command" \
  "the project is asked to state its test command"
assert_contains "$fragment" "test-path glob" \
  "the project is asked to state its test-path glob"
