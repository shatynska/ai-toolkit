## Context

The library ships three skills and one agent. Three are meta — they author assets or review change proposals — and one, `terraform`, is a domain asset. Its capabilities correspondingly split into authoring machinery (`skill-authoring`, `agent-authoring`, `change-review`, `toolkit-structure`) and one subject domain (`terraform-practice`).

Shell scripting sits underneath every one of those domains without belonging to any of them. It is also the language whose failure mode is least visible: a bad Terraform plan is displayed before it is applied, and a bad skill description fails a trigger check, but a bad shell script exits 0 and is discovered later by its effects.

`terraform` is the closest structural precedent and much of its shape transfers — provider-neutral scope becomes purpose-neutral scope, its traps section becomes a traps section, its deference clause is reused nearly verbatim. Where this change diverges from that precedent, the divergence is deliberate and recorded below, because the precedent is strong enough that a later change would otherwise read a difference as an oversight.

## Goals / Non-Goals

**Goals:**
- Ship a shell standard that changes agent behaviour rather than restating what a competent model already supplies.
- Concentrate the content on behaviours where careful reading of the code still yields the wrong answer, since those survive model improvement better than obscure facts do.
- Make the finished state of a script checkable, rather than a matter of the agent's judgment.
- Compose with a consuming project's own conventions rather than competing with them.

**Non-Goals:**
- Teaching bash to a human. A skill loads into an agent's context; it is not documentation the user reads. This is the same non-goal `terraform` carries, and it is what keeps the traps from being diluted by tutorial content.
- POSIX `sh` as a target. The skill covers bash and requires the interpreter choice be deliberate; writing portable `sh` is a different discipline and is not what a `bash`-named skill should quietly become.
- CI workflow structure — deferred to a future `github-actions` skill.
- Any project's own script layout, tool inventory, or naming conventions, which belong in that project's `AGENTS.md`.
- A runtime confirmation protocol for destructive scripts (see Decision 3).

## Decisions

**1. A skill, not a rule fragment, a command, or an agent.**
`create-skill`'s routing gate asks this first. A rule fragment is for short standing instructions and is always resident — "always quote your expansions" would fit, but the enumerated traps and their reasoning would not, and paying that context cost on every unrelated turn is exactly what the skill mechanism exists to avoid. A command suits a deterministic named sequence, which this is not. An agent is for work needing its own execution context; shell work happens in the caller's working tree against the caller's files. On-demand, description-triggered procedural knowledge is the skill shape.

**2. General-purpose, not infrastructure-scoped.**
The motivating consumer is an infrastructure repository, and an `infra-bash` or `ops-scripting` skill was considered on that basis and rejected. Nothing in the subject matter varies with the script's purpose: `local x=$(cmd)` discards an exit status identically in a deployment wrapper and a test helper. Scoping to infrastructure would therefore buy no content precision while costing triggering — a user typing "why does my script fail" would not route to an infrastructure-named skill — and would duplicate territory `terraform` already holds.

The corollary is that `infrastructure` is *not* among this skill's tags, despite the motivation. Tagging it so would classify the asset by where it happened to be needed rather than by what it covers, and the tag is the library's only classification.

**3. No human-in-the-loop gate — destructive safety is structural instead.**
This is the deliberate divergence from `terraform`, whose plan checkpoint is the most distinctive thing about it. Three reasons it does not transfer:

*There is no artifact to gate on.* Terraform's checkpoint works because `plan` produces a machine-generated classification of what is about to change, which a human can read without understanding Terraform deeply. Bash produces no equivalent. A gate would have to key on the agent's own reading of the script, which is the thing being checked — the check and the subject would be the same judgment.

*The trigger would be miscalibrated.* Destructive commands in shell scripts are routine, not exceptional: `rm -rf` on a build directory, a `trap` cleanup, an overwrite of a generated file. A rule firing on all of them trains the user to approve without reading, which is worse than no rule, and a rule that tries to fire on only the dangerous ones needs the judgment it was meant to supply.

*The failures are better prevented than confirmed.* The characteristic destructive shell bug is not "the user did not want this deleted" but "the script deleted something other than what it named" — an empty variable expanding into `rm -rf /`, a `cd` that failed leaving the next command in the wrong directory. Confirmation does not catch those, because the command reads correctly at the moment it is approved. A structural guard does.

The requirement is therefore written as a prohibition as well as a positive obligation, so that a later change adding a confirmation gate has to argue against a recorded decision rather than fill a perceived gap. The `hitl` tag is correspondingly not carried.

*The prohibition is bounded, and the bound is the point.* Declining to add a gate is a statement about what this skill requires, not about what the agent owes when a script runs. The two are easy to conflate and the consequence of conflating them is severe: a script wrapping `terraform destroy` would otherwise sit under one asset requiring confirmation and another that sounds like it forbids one, with the newer and more general asset being the permissive-sounding one. So the requirement says explicitly that the decline does not relax an obligation another asset attaches to the operation itself, and the body has to state that rather than let silence be read as permission. This costs a clause and reverses nothing — the alternative, a gate of this skill's own, is what the three arguments above reject.

**3a. The deference clause is reused whole, including the absent-conventions branch.**
`terraform-practice`'s precedence requirement has three parts: the project overrides, conflicts are reported rather than resolved silently, and — where the project records *no* convention — the answer is named as project-specific and asked about rather than invented. An earlier draft of this change carried the first two and dropped the third, which would have been a divergence from the precedent with no reason recorded, exactly what the Context section above commits not to do.

The third part transfers, so it is restored. Its rationale is if anything stronger here: the questions a shell skill cannot answer for a project — which interpreter its scripts target, where scripts live, which external tools may be assumed present — arise in every repository, whereas Terraform's equivalents arise only where Terraform is used. And a repository with nothing recorded is the normal case, so the branch is the common path rather than an edge.

**4. `set -e` is required *and* undermined in the same breath.**
The common failure in shell guidance is to prescribe `set -euo pipefail` and stop, which produces a script whose author believes errors abort. They do not abort in `if` and `while` conditions, in `&&`/`||` chains, under `!`, or in functions called from those positions — which is to say, precisely where a script tests something that might fail. Prescribing the preamble without its exceptions is worse than prescribing nothing, because it substitutes false confidence for attention.

The alternative — omitting the preamble in favour of explicit status checks everywhere — was rejected as unrealistic; the preamble does catch the common case. So both are required: the preamble as the default, and explicit handling where the preamble is known not to reach.

**5. ShellCheck is a required check, but not a sufficient one.**
Bash has an unusually good static checker, and converting a body of advice the agent must remember into a check it must run is the more reliable mechanism. So a clean run is required before a script is called finished.

It cannot be the *whole* criterion, and saying otherwise would undercut the rest of this change. A default run does not report the guard against an empty-versus-unset variable, does not report a missing `pipefail`, and reaches the `set -e` suppression positions only through optional, off-by-default checks — which is to say it misses the empty-variable guard, the single strongest safety requirement here. Making it determinative would license reporting a script finished while two of this change's own requirements are unmet.

Three options were weighed. Dropping the checker and returning to advice-the-agent-remembers gives up the mechanism that motivated it. Shrinking the skill's obligations to what the checker sees would delete the empty-variable guard, which is backwards. So: necessary but not sufficient — a clean run *plus* a stated pass, by reading, against the obligations the checker does not report, and a named fallback criterion for when the tool is absent rather than no criterion at all. Which findings the installed version actually reports is verified during authoring rather than assumed, since it varies by version and by which optional checks are enabled.

Two conditions keep the mechanism honest: unavailability is reported rather than silently skipped, and suppression directives must be narrow and reasoned.

The suppression rule is deliberately modelled on `terraform`'s `ignore_changes` rule — same shape of failure, where a mechanism for handling known-benign findings becomes a mechanism for making inconvenient findings disappear. Stating it the same way in both skills is intentional.

**6. The skill states when to stop using bash.**
A skill named after a tool has a structural bias toward that tool, and shell scripts fail most expensively when they grow past what the shell handles well — JSON parsing by regex, error recovery across several failure modes, a thousand-line script nobody can review. Requiring the skill to name that boundary makes it useful in the one situation where its own subject is the wrong answer. The boundary is stated as a signal to raise, not a veto, since the user may have good reasons to continue.

**7. Name `bash`; one new tag `bash`; flat file; no `allowed-tools`.**
The bare tool name is what users type and matches the `terraform` precedent. `shell-scripting` was rejected as less likely to be typed; `shell` was rejected as a tag alongside `bash` because the two would read as synonyms — the drift `AGENTS.md` explicitly warns about — and a genus/species pair only earns its keep when the genus will classify something else later, which is speculative here.

No `allowed-tools`: a scoped grant is for a skill wrapping one external command. This skill invokes ShellCheck but is not a wrapper around it, and a stray restriction on an open-ended skill fails far from its cause.

Flat file, on the projection that the body lands within the ~5,000-word budget. If the traps section grows past a single readable pass, `references/` is the escape hatch — but splitting pre-emptively would put the traps behind a load boundary, and they are the content most needed unprompted.

## Risks / Trade-offs

- **Trigger competition with `terraform`.** A prompt like "write a script to tear down staging" sits between the two, and both could plausibly claim it. → *Mitigation*: the split is by artifact rather than by task — `.tf` files and Terraform runs to `terraform`, shell semantics to `bash` — stated in both descriptions. Both loading on a task that spans them is the correct outcome, not a failure. `terraform`'s recorded fixtures are re-run as part of this change.
- **The scope bound on the HITL decline protects only where the other asset is loaded.** Decision 3's non-relaxation clause binds when `terraform` and `bash` are both in context — the predicted co-load. But a prompt phrased purely as shell work ("write me a teardown script") can select `bash` alone, leaving `terraform`'s confirmation obligation never in context and this skill supplying structural guards but no gate. → *Mitigation*: partial and named rather than closed. The body instructs that where a script drives a tool this library covers, that tool's asset be loaded and followed — cross-asset routing, which stays inside Decision 3's rejection of a gate. The residual is that routing depends on the agent recognising the tool. This is not a regression against the status quo, where no `bash` skill exists and the same single-load gap is total; it is a gap the fix narrows rather than eliminates.
- **The traps list is the whole value, and it is a judgment call.** Each entry was selected for contradicting a careful reading rather than for being obscure, but "what a model supplies unprompted" is a moving target that ages. → *Mitigation*: counterintuitiveness is the selection criterion precisely because it survives model improvement better than obscurity does; the spec fixes a minimum list so later edits cannot quietly erode it.
- **ShellCheck may be unavailable in the environment the skill runs in**, which would remove the mechanical half of the completion criterion exactly where it is most needed. → *Mitigation*: the requirement covers the unavailable case explicitly — report it, and fall back to a named read-through against the enumerated traps, the preamble, and the structural guards — so the criterion degrades to something stated rather than to nothing.
- **The read-through half of the completion criterion is the agent checking its own work**, which is weaker than a tool and could become a formality reported without being performed. → *Mitigation*: accepted rather than closed. It is strictly better than the alternative of a criterion that cannot see the empty-variable guard at all, and the obligations it covers are enumerated in the spec rather than left as "check it over", so the report names specific things.
- **Declining the HITL gate could read as a safety regression** against `terraform`'s precedent, particularly to a reviewer who sees the two side by side. → *Mitigation*: recorded as a decision with its reasoning, and written into the spec as an explicit prohibition, so the reasoning is inherited rather than re-litigated.
- **Overlap with a future `github-actions` skill.** CI workflow steps are bash embedded in YAML, so both will trigger on the same material. → *Mitigation*: the boundary is the one `terraform-practice` already fixed — this skill owns shell semantics, the CI asset owns workflow structure — so it is inherited rather than re-decided, and the obligation to re-run fixtures lands on that change when it arrives.

## Open Questions

- Whether the `set -e` exceptions belong in the safety section or in the traps section. They are both — the strongest single trap, and inseparable from the preamble that introduces them. Resolve at Draft by deciding which placement leaves the other section coherent, not by duplicating.
- Whether the traps list as specified fits one readable pass alongside the other sections, or forces the `references/` split Decision 7 defers. Assessed at Draft against the real outline rather than projected now.
- Whether the description can distinguish this skill from `terraform` on artifact rather than task without becoming a list of file extensions. The trigger check is what settles it.
