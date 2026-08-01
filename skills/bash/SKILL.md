---
name: bash
description: >
  This skill should be used when the user is writing, reviewing, or debugging
  a bash script — "write a bash script", "review my shell script", "why does
  this fail with unbound variable", "lint this with shellcheck", "is this
  quoting right" — or on any task touching a .sh file or a script's shebang,
  exit status, or set options. It covers general-purpose shell-authoring
  practice: the safety preamble and its limits, behaviors that read as
  correct but aren't (unset-vs-empty, discarded command-substitution status,
  subshell-scoped loop variables, unquoted expansion, pipeline status),
  interpreter discipline, ShellCheck as a necessary-but-not-sufficient
  completion check, and structural guards on destructive operations instead
  of a confirmation gate. It covers shell scripts, not a tool a script
  invokes — Terraform belongs to the terraform skill — and not authoring
  library assets (create-skill, create-agent) or OpenSpec proposals or
  reviews. A project's own script conventions, in AGENTS.md, take precedence
  on conflict.
metadata:
  tags: [bash]
---

# bash

General-purpose practice for writing and reviewing bash scripts. Like
`terraform`, this skill is a floor, not an authority: it states what holds
regardless of what the script is for, and stops short of anything a specific
project would need to decide for itself.

## Read the project's conventions first

A consuming project's `AGENTS.md`, `CLAUDE.md`, and existing scripts override
everything below wherever they conflict with it. Read those before writing or
touching shell scripts in an unfamiliar repository.

When this skill's guidance conflicts with a project's recorded convention or
established script style, follow the project's convention — and say so;
report the conflict rather than resolving it silently.

When a question is project-specific — which interpreter its scripts target,
where they live, which external tools they may assume — and the project has
recorded no convention at all, say that the answer is project-specific and
ask, rather than supplying one from assumption. A repository with nothing
recorded yet is the normal case here, not an edge case.

## Scope: any script, not one kind of repository

This applies identically to a build helper, a git hook, a deployment
wrapper, or any other script — nothing here is specific to infrastructure or
any particular kind of repository, so there's no branch on what the script
is for.

Where a script drives a tool this library has its own asset for, defer to
that asset's own behavior rather than answering for it — this skill covers
the shell-side semantics only: how the invocation's status, output, and
arguments are handled. Load the tool's own asset and follow its guidance. A
script wrapping `terraform apply`, for instance, still needs the `terraform`
skill's plan discipline; this skill does not restate it.

Naming which asset owns an obligation for an operation a script performs —
as in the example above — is not infrastructure content taken as this
skill's subject matter. It's a statement about how this skill composes with
another, not about provisioning.

## The safety preamble, and where it doesn't reach

Start every script with `set -euo pipefail` (or an explicitly justified
subset), and know what each option actually does:

- `-e` exits the script the moment a command fails.
- `-u` exits on an unset variable reference — not an empty one; see below.
- `-o pipefail` makes a pipeline's exit status the *last non-zero* status
  among its commands, rather than only the final command's.

None of that makes a script safe on its own. `-e` does not abort in these
contexts — a script relying on it there will observe the failure and keep
going regardless:

- a command used as an `if` or `while` condition
- any command in a `&&` or `||` chain, except the last
- a command negated with `!`
- a function invoked in any of the positions above — the function's own
  failing command is swallowed the same way

Where a script's control flow tests a command that can fail for a reason
other than the condition being false, handle its status explicitly — check
`$?` or branch on it — rather than trusting `set -e` to catch it.

## Behaviors that read correctly and aren't

These contradict a reasonable reading of the code, which is exactly why
they're worth stating rather than trusting to be caught on inspection:

- **`set -u` catches unset, not empty.** `rm -rf "${dir}/build"` with
  `dir=""` passes `-u` cleanly — the variable is set, just empty — and
  expands to `rm -rf /build`. A guard against unset does not protect a path
  or argument built from a variable that could be empty; check for that
  explicitly.
- **`local x=$(cmd)` discards the command's exit status.** The status of
  `local x=$(cmd)` is the status of the `local` builtin, which succeeds even
  when `cmd` fails — under `set -e` this turns a failing command into a
  silently empty variable. The same applies to `export` and `declare`.
  Separate the declaration from the assignment: `local x; x=$(cmd)`.
- **A `while read` loop on the right of a pipe runs in a subshell.** Any
  variable it assigns is lost the moment the loop ends, because the pipe
  forks a subshell to run it in. `count=0; find . -type f | while read -r f;
  do count=$((count+1)); done; echo "$count"` prints `0`. Feed the loop with
  process substitution or redirection instead — `while read -r f; do …; done
  < <(find . -type f)` — so it runs in the current shell.
- **Unquoted expansion word-splits and glob-expands.** `echo $1` doesn't
  print the first argument; it splits it on `IFS`, expands each piece as a
  glob, and joins what's left with spaces. Quote every expansion by
  default — `"$1"`, `"$var"` — and treat an unquoted one as something that
  needs a specific reason.
- **Without `pipefail`, only the last command's status survives a
  pipeline.** `false | true` exits 0. A failure anywhere earlier in the
  pipeline is invisible unless `pipefail` is set, which is one more reason
  it belongs in the standard preamble above rather than as an afterthought.

None of this is worth restating for cases the model already gets right
unprompted — ordinary `if` syntax, loop forms, function definitions. It's the
specific places where careful reading still gives the wrong answer.

## Quoting and arrays

Quoting is correctness, not style — the previous section covers why. Arrays
are where the distinction is most load-bearing: `"${arr[@]}"` expands each
element as a separate word, preserving whatever whitespace is inside any one
of them; `"${arr[*]}"` joins every element into a single word on the first
character of `$IFS`; and an unquoted `${arr[@]}` or `${arr[*]}` word-splits
and glob-expands the same way an unquoted scalar does. For "pass each
element through as its own argument" — the common case, e.g. `some_cmd
"${arr[@]}"` — only the first form is correct.

## The shebang decides what's guaranteed

Name the interpreter the script's body actually needs, and don't treat
`#!/bin/sh` as a synonym for bash: `[[ ]]`, arrays, `local`, and `pipefail`
aren't guaranteed under a POSIX `sh`.

This fails in three different ways, and the difference determines whether
testing would ever catch it:

- **Rejected at parse time.** An array literal under dash is a syntax error
  the moment dash parses it — even inside a function that's never called.
- **Parses cleanly, fails only at execution.** `[[ ]]` and `pipefail` under
  dash parse fine and fail only when the shell actually reaches them, so a
  branch that isn't exercised during testing carries the failure straight
  into production.
- **Accepted as an extension, inconsistently.** `local` is implemented by
  dash, the default `/bin/sh` on Debian and Ubuntu — so a script using it
  under `#!/bin/sh` works there and fails on a system whose `/bin/sh`
  doesn't implement it.

The last two are the dangerous ones: a passing test proves less than it
looks like it proves. Treat reliance on any of these as a defect regardless
of whether the `/bin/sh` at hand happens to accept it — fix the shebang to
`#!/usr/bin/env bash`, or fix the body, but don't leave the two mismatched.
This doesn't mean defaulting to POSIX `sh`; the choice between bash and `sh`
should be deliberate, not a default in either direction.

## Destructive operations are guarded, not gated

This skill doesn't add a requirement that the user confirm before a script
it wrote is run — bash produces no equivalent of a Terraform plan for such a
gate to key on, and a rule that fires on every `rm` in a build script trains
approval without reading, which is worse than no rule. Safety here is
structural instead:

- Guard a variable-built path against empty or unset before it reaches a
  destructive command — the `set -u` trap above is exactly why this can't be
  left to `set -u` alone.
- Guard a `cd` whose failure would leave the rest of the script running in
  the wrong directory: `cd "$dir" || exit 1`, not a bare `cd "$dir"`.
- Create temporary files and directories with `mktemp`, not a fixed path
  another process or run could collide with.
- Write cleanup `trap`s so that firing before the resources they remove
  exist is harmless — check existence before removing, don't assume the trap
  only ever fires late.

Declining to add a gate here is a statement about what *this skill*
requires, not about what an agent owes when a script runs. It does not
relax a confirmation obligation another asset attaches to the operation a
script performs. A script wrapping `terraform destroy`, or any Terraform
apply whose plan replaces or destroys, still needs the `terraform` skill's
confirmation before that apply runs — wrapping the operation in a script
doesn't clear its gate, and this skill's own silence on gates is not
grounds for skipping it.

## ShellCheck decides completion — necessary, not sufficient

Run ShellCheck against any script written or modified, and treat a clean run
as required before reporting it finished. It isn't enough on its own:
verified against ShellCheck 0.9.0 on 2026-07-31, a default run reliably
catches three of the traps above — unquoted expansion (SC2086), a
`local`/`export`/`declare` assignment masking a command substitution's status
(SC2155), and a `while read` loop losing its assignments to a subshell
(SC2030/SC2031) — but it does not report, even with every optional check
enabled, the guard against an empty-vs-unset variable, a missing `pipefail`,
or `set -e` being suppressed in an ordinary `if`/`while`/`&&`/`||`/`!`. (An
optional check, `check-set-e-suppressed`, exists and is real, but is scoped
strictly to a function invoked in a suppressing position — it doesn't extend
to an ordinary command, which is the gap that matters here.)

So: a clean ShellCheck run, plus an explicit statement that the obligations
above were checked by reading — the empty-variable guard, `pipefail`, the
`set -e` exceptions — is what completion actually requires. Where ShellCheck
is unavailable, say so rather than silently reporting the script as checked,
and fall back to that same read-through against the enumerated traps, the
safety preamble, and the structural guards above.

A `# shellcheck disable=` directive is legitimate only when it names
specific codes, is scoped as narrowly as the finding allows, and carries a
stated reason. A file-wide or unexplained suppression conceals a finding
rather than resolving it.

## When a task has outgrown bash

Some tasks have outgrown the shell before a line of it is written: parsing
structured data the shell can't represent without ad hoc text processing,
error handling that has to distinguish and recover from several distinct
failure modes, or a script whose length or branching has grown past what's
reviewable. Say so and name the alternative before continuing — don't work
around it silently just because the request was phrased as a script. If the
user still wants it in bash after that, that's their call to make, not a
veto.

## What this skill doesn't decide

A project's own script layout and tool inventory, CI workflow structure, and
the choice of language once a task has outgrown bash are all decisions for
the project or for a future asset — this skill states what holds regardless
of them.

## Trigger check fixtures

- **Positive** — "My deploy script exits successfully even when one of the
  commands in the middle of a pipeline fails — how do I fix that?" →
  expected routing: `bash`.
- **Negative** — "Why is Terraform trying to destroy and recreate my
  database resource when all I did was change count from 3 to 2 in the list
  above it?" → expected routing: `terraform`.
