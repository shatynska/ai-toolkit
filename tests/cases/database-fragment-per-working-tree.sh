#!/usr/bin/env bash
# Scenario (mechanical half only): Two sessions do not share one database.
#
# What is isolated is the database and not the server: sessions share the
# running server and each takes its own database within it, named after its
# working tree. The two named subjects — the working tree the name derives
# from, and the project's development database a session works in neither of
# — are fixed by the requirement, so a case can assert the fragment names
# both. A fragment that says only "use your own database" states the rule
# without either subject and passes nothing here.
#
# That two concurrent sessions actually end up in separate databases is
# session behavior with no program in this repository to run it against;
# verified by reading (task 2.3).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow-database.md"
assert_file "$fragment" "the database binding fragment"

assert_contains "$fragment" "working tree" \
  "the database's name derives from the working tree, so which session holds which is readable"
assert_contains "$fragment" "development database" \
  "a session works in neither the project's development database nor another session's"
