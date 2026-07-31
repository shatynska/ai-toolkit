## ADDED Requirements

### Requirement: Guidance Is General-Purpose

The skill SHALL state shell practice in terms that hold for any script, regardless of what the script is for. It SHALL NOT take infrastructure provisioning, deployment, or CI as its subject matter, and SHALL NOT encode any single project's directory layout, tool inventory, or naming conventions.

Where a question turns on what a specific tool invoked by a script does, the skill SHALL address the shell-side semantics — how the invocation's status, output, and arguments are handled — and defer the tool's own behaviour elsewhere. Where a script drives a tool this library covers with its own asset, the skill SHALL instruct that the tool's asset be loaded and its guidance followed, rather than answering for it.

Naming another asset's obligation for an operation a script performs is not that asset's subject matter taken as this skill's, and SHALL NOT be removed under the exclusion below. A concrete example identifying which asset owns an obligation — such as a Terraform apply requiring confirmation — is a statement about how this skill composes, and is permitted.

#### Scenario: A script's purpose does not change the guidance

- **WHEN** the same quoting, exit-status, or subshell question arises in a build helper, a git hook, and a deployment wrapper
- **THEN** the skill SHALL give the same answer in all three, without a branch conditioned on what the script is for

#### Scenario: Excluded content classes are absent from the body

- **WHEN** the body is checked for the content classes this requirement excludes — provisioning, deployment, or CI as subject matter, or a single project's layout, tool inventory, or naming choices
- **THEN** none of them SHALL be present

### Requirement: The Safety Preamble Is Required and Its Limits Stated

The skill SHALL require `set -euo pipefail` (or an explicitly justified subset) at the top of a script, and SHALL state what each option does.

It SHALL NOT present that preamble as making a script safe. The skill SHALL state that `set -e` is suppressed in the contexts where a failing command is most likely to be overlooked — a command in an `if` or `while` condition, any command in a `&&` or `||` chain except the last, a command whose status is negated with `!`, and a function invoked in any of those positions — and that a script relying on `set -e` alone in those positions will continue past an error.

#### Scenario: The preamble is accompanied by its exceptions

- **WHEN** the skill instructs that `set -euo pipefail` be added
- **THEN** it SHALL also state the positions in which `set -e` does not abort, rather than presenting the preamble as sufficient on its own

#### Scenario: An error inside a condition is handled explicitly

- **WHEN** a script's control flow tests a command that can fail for reasons other than the condition being false
- **THEN** the skill SHALL require the status be handled explicitly rather than relying on `set -e` to abort

### Requirement: Counterintuitive Behaviours Are Recorded in Preference to Tutorial Content

The skill SHALL record at minimum these behaviours, each of which contradicts a reasonable reading of the code:

- `set -u` aborts on an *unset* variable but not on one set to the empty string, so a guard against unset does not protect an expansion used as a path or an argument.
- `local x=$(cmd)`, and likewise `export` and `declare`, discard the command's exit status because the assignment's status is that of the enclosing builtin, which succeeds. Under `set -e` this converts a failing command into a silent empty value.
- A `while read` loop on the right-hand side of a pipe runs in a subshell, so every variable it assigns is lost when the loop ends.
- Unquoted parameter expansion is subject to word splitting and pathname expansion, so an unquoted variable holding a value with whitespace or a glob character becomes a different number of arguments than intended.
- Without `pipefail`, a pipeline's exit status is that of its last command only, so a failure anywhere earlier in the pipeline is reported as success.

General shell material that a competent model already supplies unprompted SHALL NOT displace this content.

#### Scenario: A recorded trap is available before it is hit

- **WHEN** an agent is about to assign command substitution to a `local` variable, or read into variables from the right side of a pipe
- **THEN** the skill SHALL already carry the reason not to, without the user having to know to ask

#### Scenario: Base knowledge is deferred to rather than restated

- **WHEN** an agent meets a question the base model already answers reliably, such as `if` syntax, loop forms, or how to define a function
- **THEN** the skill SHALL leave that to the model rather than carrying a restatement of it

### Requirement: The Declared Interpreter Governs the Feature Set

The skill SHALL require that a script's shebang name the interpreter its body actually requires, and SHALL state that `#!/bin/sh` is not a synonym for bash: `[[ ]]`, arrays, `local`, and `pipefail` are not guaranteed under a POSIX `sh`.

The skill SHALL distinguish the ways this surfaces, because they fail differently and the differences determine whether testing catches them.

Some constructs a non-bash `/bin/sh` rejects when it parses them, before any of the surrounding code runs — an array literal under dash fails even inside a function that is never called. Others parse cleanly and fail only when execution reaches them: `[[ ]]` and `pipefail` under dash, for instance, so a branch that never runs during testing carries the failure into production untouched. Others again are accepted as an extension by some implementations and not others: `local` is implemented by dash, the usual `/bin/sh` on Debian and Ubuntu, so a script using it under `#!/bin/sh` works there and fails on a system whose `/bin/sh` lacks it.

The last two cases are the dangerous ones, because a passing test proves less than it appears to — in the second it proves only that the failing branch was not exercised, and in the third only that the machine tested on accepts the extension. The skill SHALL state that reliance on an unguaranteed construct is a defect regardless of whether the local `/bin/sh` happens to accept it.

The skill SHALL require the choice between bash and POSIX `sh` be deliberate, and SHALL NOT instruct that scripts be written to POSIX `sh` by default.

#### Scenario: A bashism under a POSIX shebang is a defect

- **WHEN** a script declares `#!/bin/sh` and its body uses `[[ ]]`, an array, `local`, or `pipefail`
- **THEN** the skill SHALL treat this as a defect to fix — by correcting the shebang or the body — rather than as a portability preference

### Requirement: ShellCheck Is Necessary But Not Sufficient For Completion

The skill SHALL require ShellCheck be run against a script the agent has written or modified where the tool is available, and SHALL treat a clean run as necessary before a script is reported finished.

A clean run SHALL NOT be treated as sufficient. The skill SHALL state that a default ShellCheck run does not report every obligation this skill imposes — among them the guard against a variable being empty rather than merely unset, the absence of `pipefail`, and the positions in which `set -e` is suppressed — and SHALL require that completion be reported only alongside an explicit statement that those unreported obligations were checked by reading.

Where ShellCheck is unavailable, the skill SHALL require this be stated rather than the script silently reported as checked, and SHALL name what carries the completion decision in its absence: an explicit read-through against the enumerated traps, the safety preamble, and the structural guards, reported as such.

A `# shellcheck disable=` directive SHALL be permitted only when it names specific codes, is scoped as narrowly as the finding allows, and carries a stated reason. A file-wide or reason-less suppression SHALL be treated as concealing a finding rather than resolving it.

#### Scenario: A clean lint alone does not finish a script

- **WHEN** a script passes ShellCheck but assembles a destructive path from a variable with no empty-guard, or runs a pipeline with no `pipefail`
- **THEN** the skill SHALL NOT permit it be reported finished on the strength of the clean run

#### Scenario: Completion names both halves of the check

- **WHEN** an agent working under this skill is about to report a script complete
- **THEN** it SHALL report the ShellCheck result, or the tool's unavailability, *and* state that the obligations ShellCheck does not report were checked by reading

#### Scenario: A suppression is justified or removed

- **WHEN** a ShellCheck finding is suppressed
- **THEN** the directive SHALL name the specific code and carry a reason, and a blanket or unexplained suppression SHALL be rejected

### Requirement: Destructive Operations Are Guarded Structurally

The skill's own guidance on destructive operations SHALL supply structural guards rather than a runtime confirmation gate: it SHALL NOT introduce a requirement that the user confirm before a script the agent has written is run.

This prohibition is a bound on what *this skill* requires. It SHALL NOT be read as relaxing, overriding, or satisfying a confirmation obligation that another asset attaches to an operation a script performs. Where a script invokes a tool whose own guidance requires confirmation before a destructive action, that obligation SHALL continue to apply to the operation, unchanged by the fact that it is reached through a script. The skill SHALL state this deference explicitly rather than leaving its silence to be read as permission.

It SHALL require that a path assembled from a variable be guarded against that variable being empty or unset before it is used in a destructive command, that a `cd` whose failure would leave subsequent commands running in the wrong directory be guarded, that temporary files and directories be created with `mktemp` rather than a fixed path, and that a cleanup `trap` be written so that firing before the resources it removes were created is harmless.

#### Scenario: An empty expansion cannot reach a destructive command

- **WHEN** a script removes or overwrites a path built from a variable
- **THEN** the skill SHALL require a guard that fails the script when that variable is empty or unset, rather than relying on `set -u` alone

#### Scenario: No confirmation gate is introduced by this skill

- **WHEN** the skill's own content on destructive operations is checked
- **THEN** it SHALL contain no requirement that the user confirm before running a script, the safety it supplies being located in how the script is written instead

#### Scenario: Wrapping a gated operation in a script does not clear its gate

- **WHEN** a script invokes an operation that another loaded asset requires be confirmed before it runs — such as a Terraform apply whose plan contains a replace or destroy
- **THEN** that asset's confirmation obligation SHALL still be met, and this skill's prohibition SHALL NOT be cited as grounds for skipping it

### Requirement: The Point at Which a Task Should Stop Being Bash Is Named

The skill SHALL state the conditions under which a task has outgrown the shell — among them a need for structured data the shell cannot represent without parsing text, error handling that must distinguish and recover from several failure modes, and length or branching beyond what remains reviewable — and SHALL require that this be raised rather than worked around.

The skill SHALL NOT help extend a script past that point without naming it first.

#### Scenario: Outgrowing the shell is surfaced, not absorbed

- **WHEN** a request would require parsing structured data, recovering from several distinct failure modes, or growing a script well past the point of reviewability
- **THEN** the skill SHALL state that the task has outgrown bash and name the alternative, before continuing if the user still wants it in bash

### Requirement: Consuming Project Conventions Take Precedence

The skill SHALL declare itself a floor rather than an authority: a consuming project's `AGENTS.md`, `CLAUDE.md`, and existing scripts override it wherever they conflict.

It SHALL instruct that those be read before shell work begins in an unfamiliar repository, and SHALL require that a conflict between its own guidance and a project convention be reported rather than silently resolved.

Where a question turns on a project decision — which interpreter its scripts target, where they live, which external tools they may assume — and the project records no convention at all, the skill SHALL state that the answer is project-specific and ask, rather than supplying one from assumption. A repository that has not yet recorded its conventions is the expected case, not an edge case.

#### Scenario: Project convention wins a conflict

- **WHEN** a consuming project's recorded convention or established script style contradicts a preference stated in the skill
- **THEN** the project's convention SHALL be followed and the conflict reported rather than silently resolved

#### Scenario: Absent conventions produce a question, not an invention

- **WHEN** a project-specific question arises — the target interpreter, script location, or which external tools may be assumed — in a repository that records no conventions
- **THEN** the skill SHALL state that the answer is project-specific and ask, rather than supplying one from assumption
