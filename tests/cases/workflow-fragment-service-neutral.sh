#!/usr/bin/env bash
# Scenario (mechanical half only): The project imposes its own naming form.
#
# The workflow fragment states the namespace obligation service-neutrally:
# it prescribes no concrete service and no naming form, both of which belong
# to the binding fragment or to the project's own conventions. That is what
# lets a project on another stack replace one file rather than edit the
# workflow fragment, and it is checkable — a concrete engine or container
# runtime named here is the violation itself.
#
# The positive half — that a name derived from the working tree can be
# expressed in whatever form the project imposes, and that the fragment says
# it allocates and does not release — is prose, verified by reading (tasks
# 1.6, 1.16). The release clause specifically cannot be scanned for: a
# compliant fragment necessarily contains a sentence carrying both a release
# verb and the word "namespace", so any lexical test for that pair fails on
# the fragment it was written to accept.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

# Without this the scan below passes vacuously against a fragment that states
# no namespace obligation at all — service neutrality is only meaningful
# where the service-neutral obligation exists.
assert_contains "$fragment" "namespace" "the fragment states the namespace obligation the binding binds"

# Concrete engines and container runtimes. `container` itself is deliberately
# absent from this list: it is not a service the fragment prescribes, and the
# side that matters — that the binding fragment names a container where this
# one must not — is asserted by
# `database-fragment-affordance-before-obligation.sh` rather than here.
offenders="$(grep -n -i -E 'postgres|postgresql|mysql|mariadb|sqlite|mongo|redis|psql|docker|podman|DATABASE_URL' "$fragment")"
if [ -n "$offenders" ]; then
  echo "FAIL: $fragment names a concrete service — the binding fragment owns the service and the naming form" >&2
  echo "$offenders" >&2
  exit 1
fi
