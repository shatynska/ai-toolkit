## Why

Bash is the language where a plausible-looking script is most likely to be quietly wrong. Its defaults contradict what the syntax suggests, and the failures are silent rather than loud: a pipeline reports success because only the last command's status counts, a variable word-splits into three arguments because it was left unquoted, a cleanup runs against an empty path because the variable holding it was never set. None of that announces itself — the script exits 0 and the damage is found later.

A competent model writes fluent bash and still writes past these behaviours unprompted, because each one looks correct at the point it is written. That is the gap the skill closes: not syntax, which needs no help, but the specific places where reading the code carefully still gives the wrong answer.

## What Changes

- Add `skills/bash/SKILL.md` — a domain asset covering shell authoring practice, held to `create-skill`'s standard.
- Scope it **general-purpose**, not infrastructure-flavoured. Quoting, exit status, and subshell semantics hold identically in a build helper, a git hook, or a deployment wrapper, so nothing in the subject matter is specific to one kind of repository.
- Carry **no human-in-the-loop confirmation gate of its own.** A generic "confirm before anything destructive" rule in a general-purpose skill would fire on every `rm` in a build script until it was routed around, and bash produces no reviewable artifact — no equivalent of a plan — for such a gate to key on. The destructive-action material instead enters as *authoring* traps: an empty variable expanding into a path, an unguarded `cd` leaving the script running somewhere it did not intend, a cleanup `trap` firing on a partially-initialised script. That is where the failure can be structurally prevented rather than confirmed after the fact.
- **Bound that decline explicitly.** Declining to add a gate says what this skill requires, not what an agent owes when a script runs. Where a script drives a tool whose own asset requires confirmation — a Terraform apply whose plan replaces or destroys — that obligation still applies, and the skill states so rather than letting its silence read as permission.
- Weight the content against what a model already supplies unprompted. Bash syntax, "use functions", "add a shebang" change no behaviour. What earns its place is the set of behaviours that contradict a reasonable reading of the code: `set -e` not firing in the contexts where errors are most likely, `set -u` catching unset but not *empty*, `local x=$(cmd)` discarding the command's exit status, and a `while read` loop on the right of a pipe losing every assignment it makes.
- Require **ShellCheck, as a necessary but not sufficient check.** A clean run gates completion, with an honesty rule on suppression: a `# shellcheck disable=` directive is legitimate when it is narrow and carries a reason, and is concealment otherwise. But a default run does not report several obligations this skill imposes — the empty-versus-unset guard chief among them — so completion also requires a stated read-through against what the linter misses, and a named fallback criterion when the tool is absent.
- Require the skill to state **bash's ceiling** — the point at which a script should stop being bash — rather than helping extend a script past it.
- Require the **declared interpreter to govern the feature set**: a shebang names the interpreter the body actually needs, and a bashism under `#!/bin/sh` is a defect to fix rather than a portability preference.
- Introduce one new tag, `bash`. `shell` was considered as a companion and rejected as a near-synonym, which is exactly the vocabulary drift `AGENTS.md` warns about.
- Re-run the recorded trigger-check fixtures of any existing asset the new skill competes with, per the invalidation requirement in `skill-authoring`.

## Capabilities

### New Capabilities
- `bash-practice`: What the library's shell guidance asserts and where it stops — general-purpose scope, the safety preamble stated with its limits, the enumerated traps that contradict a reasonable reading, the declared interpreter governing the feature set, structural guards on destructive operations in place of a confirmation gate this skill declines to add but does not relax elsewhere, ShellCheck as a necessary-but-not-sufficient completion check with a disable-directive honesty rule, deference to a consuming project's own conventions, and the requirement to name the point at which a task should stop being bash.

### Modified Capabilities
(none)

`skill-authoring` governs *how* a skill is authored and places no constraint on subject matter. `toolkit-structure` already makes tags the only classification and requires only that existing vocabulary be checked before a tag is coined — which this change does rather than changes, and its "adding an asset requires no catalogue update" requirement means no README or index edit is owed.

## Impact

- **Affected**: new directory `skills/bash/`. No existing asset changes except any recorded trigger-check fixture the sweep below finds invalidated, which is then updated in this change rather than a later one. The sweep is a determination still to be run; the closest precedent found no fixture required updating.
- **Recorded checks elsewhere**: adding an asset invalidates the recorded trigger checks of every asset it competes with. `terraform` is the primary risk — a prompt like "write me a script to tear down the staging environment" sits between the two — `create-skill` and `create-agent` are checked because their fixtures concern authoring prompts that a shell-flavoured phrasing could now reach, and `openspec-change-reviewer` is checked because it is the library's fourth fixture-carrying asset, its fixtures living in `agents/openspec-change-reviewer.checks.yaml` rather than in a `SKILL.md` section and therefore being the set most easily overlooked.
- **Boundary with a future `github-actions` skill**: CI workflows are largely bash embedded in YAML, so the two will overlap. This skill owns the shell semantics; how a workflow is structured belongs to the CI asset. The line is the same one `terraform-practice` already fixed, so it is inherited rather than re-decided here.
- **Library positioning**: a domain asset not tied to a single tool's lifecycle. `/plugin install` is all-or-nothing, so it loads everywhere the plugin does — accepted, since an untriggered skill costs only its description line.
- **No new dependencies**, no tooling, no build step. ShellCheck is referenced as a tool the skill invokes where it is available, not added as a repository dependency.
