## 1. Intent Checkpoint

- [x] 1.1 Confirm the routing gate: the work is on-demand procedural knowledge belonging in the caller's context, so a skill rather than a rule fragment, a command, or an agent (design Decision 1). Recommending a different artifact and stopping remains a valid outcome.

  Outcome: confirmed. The content is several thousand words of procedural knowledge triggered on demand by shell-scripting tasks, not a short standing instruction (rule fragment), a deterministic named sequence (command), or work needing its own execution context (agent) — it operates in the caller's working tree against the caller's files. A skill is the right artifact.
- [x] 1.2 Confirm the name `bash` is free by listing `skills/` in this repository.

  Outcome: confirmed. `skills/` contains `create-agent`, `create-skill`, `terraform` only.
- [x] 1.3 List the `metadata.tags` in use across `skills/` and `agents/`, and confirm `bash` is genuinely new rather than a synonym of an existing label. Confirm `shell` is not added alongside it, and that `infrastructure` is not carried despite the motivating consumer (design Decisions 2 and 7).

  Outcome: tags in use are `authoring`, `hitl` (both `create-skill` and `create-agent`), `infrastructure`, `terraform`, `hitl` (`terraform`), and `review`, `openspec` (`openspec-change-reviewer`). `bash` is not a synonym of any of these. Per design Decisions 2 and 7: `shell` is not added — it would read as a synonym of `bash`. `infrastructure` is not carried — the skill is general-purpose per Decision 2, and the tag would misclassify it by where it was needed rather than what it covers. `hitl` is not carried — Decision 3 declines a confirmation gate of this skill's own.
- [x] 1.4 Confirm the skill's purpose in one or two sentences.

  Outcome: general-purpose bash-authoring practice — the behaviours that read as correct but aren't (unset-vs-empty, discarded command-substitution status, subshell-scoped loop variables, unquoted expansion, pipeline status), interpreter discipline, and completion gated on ShellCheck plus a stated read-through, with destructive-operation safety supplied structurally rather than through a confirmation gate.
- [x] 1.5 Confirm the triggering conditions — the phrasings a user would plausibly type — and agree them here, before any description is drafted from them. Include the phrasings that distinguish this skill from `terraform`.

  Outcome: "write a bash script", "review my shell script", "why does this fail with unbound variable", "add error handling to this script", "lint this with shellcheck", "is this quoting right", "set -euo pipefail", any task touching a `.sh` file or a script's shebang/exit-status/`set` options. Distinguished from `terraform` by artifact: `.sh` files and shell semantics here, `.tf` files and Terraform runs there — not by task, since a task can span both.
- [x] 1.6 Confirm the target is this repository's own `skills/`, not any project the skill is written for.

  Outcome: confirmed — `skills/bash/SKILL.md` in `ai-toolkit`.

## 2. Shape and Draft Checkpoints

- [x] 2.1 Resolve the open question on structure: assess the projected body against the ~5,000-word budget and decide whether it stays a single flat file or needs `references/` (design Decision 7). Raise the Shape checkpoint only if the answer is not a flat file.

  Outcome: flat file. Ten body sections plus the `terraform`-precedent's own body (which covers a comparable eight-topic spread at roughly 1,700 words) project this comfortably under the ~5,000-word budget. Shape checkpoint not raised.
- [x] 2.2 Draft the frontmatter — `name`, `description`, `metadata.tags` — with no `allowed-tools` (design Decision 7). Verify the description is third person, names adjacent trigger phrasings drawn from task 1.5, and disambiguates against every asset in the library *and* the OpenSpec assets committed under `.claude/`.

  Outcome: see the Draft presentation below (task 2.7).
- [x] 2.2a Decide and record whether `compatibility` is owed for the skill's ShellCheck dependency, since `skill-authoring` names that field as where a dependency on an external CLI is stated. The expected answer is that it is not declared — the skill degrades explicitly when ShellCheck is absent rather than being unusable without it — but record the decision either way, so the silence is a decision rather than an oversight alongside the other recorded declines (`allowed-tools`, `infrastructure`, `hitl`, `shell`). Record it as an inline outcome note under this task, which is how this repository's archived changes carry determinations of this kind; task 6.1's sweep result is recorded the same way.

  Outcome: not declared. The spec's ShellCheck requirement already names a fallback for the tool's absence — a read-through against the enumerated obligations — so the skill is usable without it rather than blocked by its absence, which is what `compatibility` is for.
- [x] 2.3 Resolve the open question on distinguishing this skill from `terraform` in the description: separate them by artifact — shell scripts and shell semantics here, `.tf` files and Terraform runs there — without the description degenerating into a list of file extensions.

  Outcome: resolved by artifact, mirroring `terraform`'s own description structure (which names ".tf files, .tfvars, a plan, or Terraform state" as its artifacts). See the Draft presentation below.
- [x] 2.4 Verify the drafted description is at most 1024 characters and contains no angle brackets.

  Outcome: 1022 characters, no angle brackets.
- [x] 2.5 Draft the body outline as section headers only. Confirm it covers every requirement in the `bash-practice` spec.

  Outcome: see the Draft presentation below — ten sections, each requirement in the spec traced to at least one.
- [x] 2.6 Resolve the open question on where the `set -e` exceptions live — the safety-preamble section or the traps section. Choose the placement that leaves the other section coherent; do not duplicate the content across both.

  Outcome: the safety-preamble section. The spec's own requirement structure already settles this — *The Safety Preamble Is Required and Its Limits Stated* is a requirement distinct from *Counterintuitive Behaviours Are Recorded…*, and its own text mandates stating the suppression contexts ("The skill SHALL state that `set -e` is suppressed in the contexts…"). Placing it there is not a fresh choice so much as following where the spec already put the obligation; the traps section covers the five behaviours enumerated in its own requirement and does not restate this.
- [x] 2.7 Present frontmatter and outline for approval. Write no file before this is approved; apply revisions to the draft and re-present rather than writing and editing.

  Outcome: presented; approved. File written at task 3.1.

## 3. Write the Skill

- [x] 3.1 Create `skills/bash/SKILL.md` at the structure settled in task 2.1.

  Outcome: written as a single flat file, 1850 words, valid YAML frontmatter, description 1022 characters.
- [x] 3.2 Write the deference section: the skill is a floor that a consuming project's `AGENTS.md`, `CLAUDE.md`, and existing scripts override on conflict; those are read first in an unfamiliar repository; a conflict is reported rather than silently resolved; and where the project records no convention at all, the answer is named as project-specific and asked about rather than supplied from assumption, per the requirement's third paragraph and design Decision 3a. A repository with nothing recorded is the expected case, not an edge case.

  Outcome: `## Read the project's conventions first`, three paragraphs — floor/override, conflict reported, absent-conventions branch.
- [x] 3.3 Write the safety-preamble section: `set -euo pipefail` as the default with each option explained, and the `set -e` exceptions per the placement settled in task 2.6 — `if`/`while` conditions, `&&`/`||` chains, `!` negation, and functions invoked in those positions — with explicit status handling required where the preamble does not reach.

  Outcome: `## The safety preamble, and where it doesn't reach`.
- [x] 3.4 Write the traps section covering, at minimum, all five behaviours enumerated in the `bash-practice` spec: `set -u` not catching an empty value; `local`/`export`/`declare` discarding a command substitution's exit status; a `while read` loop on the right of a pipe losing its assignments to a subshell; unquoted expansion word-splitting and glob-expanding; a pipeline without `pipefail` reporting only its last command's status.

  Outcome: `## Behaviors that read correctly and aren't`, all five present.
- [x] 3.5 Write the quoting and expansion section treating quoting as correctness rather than style, and covering arrays — `"${arr[@]}"` versus `"${arr[*]}"` versus unquoted — as the case where the distinction is load-bearing.

  Outcome: `## Quoting and arrays`.
- [x] 3.6 Write the interpreter section: the shebang names the interpreter the body requires, `#!/bin/sh` is not a synonym for bash, and `[[ ]]`, arrays, `local`, and `pipefail` under a POSIX shebang are a defect to fix rather than a portability preference. Distinguish the three failure shapes the spec requires: constructs rejected at parse time (an array literal under dash fails even in a function never called), constructs that parse but fail only when execution reaches them (`[[ ]]`, `pipefail`), and constructs some implementations accept as an extension (`local` works under dash, the usual `/bin/sh` on Debian and Ubuntu). Do not state that `local` fails under every non-bash `sh`, and do not attribute one failure shape to the whole construct set; verify any such claim against an actual `sh` before writing it. Do not instruct that scripts be written to POSIX `sh` by default (design Non-Goals).

  Outcome: `## The shebang decides what's guaranteed`, all three failure shapes distinguished, claims match the dash behaviour verified live in the authoring session.
- [x] 3.7 Write the structural-safety section: guard a variable-built path against empty or unset before it reaches a destructive command, guard `cd`, use `mktemp` over fixed temporary paths, and write a cleanup `trap` so that firing before its resources exist is harmless. Introduce no runtime confirmation gate — the spec prohibits it (design Decision 3).

  Outcome: `## Destructive operations are guarded, not gated`, all four structural guards present.
- [x] 3.7a State the scope bound on that prohibition explicitly in the body, per the spec's *Wrapping a gated operation in a script does not clear its gate* scenario: this skill declines to add a confirmation gate of its own, and that decline does not relax a confirmation obligation another asset attaches to an operation the script performs. Name the Terraform apply case, since `terraform` is the asset in this library that imposes such an obligation and the co-load is the predicted one (design Decision 3, Risks bullet 1). Do not leave the skill's silence to be read as permission.

  Outcome: second paragraph of the same section — bound stated, Terraform apply named explicitly.
- [x] 3.7b Address the single-load residual: the deference in 3.7a binds only where the other asset is actually loaded, and a prompt phrased as shell work ("write me a teardown script") can select this skill alone. Instruct in the body that where a script drives a tool this library covers, that tool's own asset should be loaded and its guidance followed — the routing clause the spec's *Guidance Is General-Purpose* requirement carries in its second paragraph. This is cross-asset routing, not a confirmation gate, so it stays inside design Decision 3's rejection — do not convert it into one.

  Outcome: placed in `## Scope: any script, not one kind of repository` rather than in the destructive-operations section, per the Draft outline — it corresponds to *Guidance Is General-Purpose*'s second paragraph, not to the destructive-operations requirement, and the destructive-operations section cross-references it via the Terraform example instead of repeating it.
- [x] 3.8 Verify, before writing any of the ShellCheck section, which of the enumerated traps a default run of the installed ShellCheck actually reports, and whether optional checks (such as those covering masked return values and suppressed `set -e`) close any of the gaps the spec names. This precedes 3.8a and 3.8b because it supplies the claims they write; performed afterwards it becomes a rubber stamp on text already committed. Record the ShellCheck version verified against and the date. Where ShellCheck is not installed in the authoring environment, do not skip the determination and do not write the claims from assumption — take them from the tool's published check list, cite that as the source, and record that the claim rests on documentation rather than on a run.

  Outcome: initially blocked (apt has 0.9.0-1 available but installation requires an interactive sudo password not obtainable in this session), so a first pass was verified against the ShellCheck wiki as a documentation-sourced fallback. The user then installed ShellCheck 0.9.0 independently and it became available in-session, so the determination was **re-verified against a live run** against the actually-installed version, superseding the documentation-only pass.

  Method: constructed one script per trap using ShellCheck's own canonical "problematic code" examples (from `https://github.com/koalaman/shellcheck/wiki`) rather than improvised scripts — an early improvised attempt at the unquoted-expansion trap, using an unquoted variable inside `for f in $files`, did not trigger SC2086 at all, which turned out to be a genuine exception for that specific for-loop position; `echo $1`-style argument position is what reliably triggers it, confirmed with the wiki's own example. Run 2026-07-31 against ShellCheck 0.9.0 (`shellcheck --version`).

  Findings, all confirmed by an actual run against 0.9.0:
  - Trap 2 (`local foo="$(mycmd)"` masking a command substitution's exit status) → **SC2155, fires by default**, no flags needed.
  - Trap 3 (`while read` on the right of a pipe losing assignments to a subshell) → **SC2030/SC2031, fire by default**.
  - Trap 4 (unquoted expansion, `echo $1`) → **SC2086, fires by default**.
  - Trap 1 (`dir=""; rm -rf "${dir}/build"`, an empty-vs-unset guard) → **clean even with every optional check enabled** (`shellcheck -o all`).
  - Trap 5 (missing `pipefail`: `set -eu; false | true; echo "still ran"`) → **clean on a plain default run, no flags**. A finding did surface once under `-o all` (SC2312), but it is an unrelated masked-return-value check triggered by the specific `false | true` shape, not a pipefail check — there is no ShellCheck check for a missing `pipefail` option at all, default or optional.
  - `set -e` suppressed in an ordinary `if` (Safety Preamble requirement) → **clean even with `check-set-e-suppressed` explicitly enabled** (`shellcheck -o check-set-e-suppressed`) against `if grep foo missing_file; then …`. The same optional check, run against the wiki's own function-invocation example (`func() { … }; func && echo ok`), correctly fires as `SC2310`. This empirically confirms the check is real but strictly scoped to a function invoked in a suppressing position — it does not extend to an ordinary command in `if`/`while`/`&&`/`||`/`!`, which is the gap the Safety Preamble requirement actually names.

  This confirms the spec's normative enumeration exactly, on a live run rather than documentation alone: no spec amendment is needed, and no optional check is adopted as a requirement — `check-set-e-suppressed` would close only the narrow function-invocation sub-case, not the gap the requirement is about.

  Version note: the installed 0.9.0's `--list` output is a strict subset of the wiki's documented 0.11.0 optional-checks list (missing, among others, `avoid-negated-conditions` and `useless-use-of-cat`); `check-extra-masked-returns` and `check-set-e-suppressed`, the two checks relevant to this skill, are present in both.
- [x] 3.8a Reconcile the verification with the spec before writing. The `bash-practice` requirement states normatively that a default run does not report the empty-versus-unset guard, a missing `pipefail`, or the `set -e` suppression positions. Where task 3.8 contradicts that enumeration, or where an optional check is to be adopted as required, amend this change's delta spec first — do not write a body that either contradicts the spec or restates a claim the tool disproves. The same factual claims appear in `proposal.md`'s ShellCheck bullet and in design Decision 5; correct or annotate both in the same step, so the package does not end with proposal and design asserting what the spec was amended to deny. If the amendment adds or removes a requirement, re-confirm task 2.5's coverage check against the amended set.

  Outcome: no contradiction — the live-run findings match the spec's enumeration exactly (task 3.8's outcome note). No spec amendment, no proposal or design correction needed; task 2.5's coverage check stands unchanged.
- [x] 3.8b Write the ShellCheck section from the reconciled position: a clean run is required before a script is reported finished, run against anything written or modified; a `# shellcheck disable=` directive must name specific codes, be narrowly scoped, and carry a reason; a clean run is necessary but not sufficient, with the unreported obligations named and completion requiring an explicit statement that those were checked by reading; and a named criterion carrying the completion decision when ShellCheck is unavailable.

  Outcome: `## ShellCheck decides completion — necessary, not sufficient`.
- [x] 3.8c In that same section, state the ShellCheck version and date task 3.8 verified against, following `skill-authoring`'s treatment of externally-versioned facts as dated snapshots rather than closed enumerations. A claim about which checks are on by default is a property of a version, and ages silently without one.

  Outcome: "verified against ShellCheck 0.9.0 on 2026-07-31" stated in the section's opening sentence.
- [x] 3.9 Write the ceiling section naming when a task has outgrown the shell — structured data, recovery across several distinct failure modes, length or branching past reviewability — stated as a signal to raise rather than a veto.

  Outcome: `## When a task has outgrown bash`.
- [x] 3.10 Write the closing scope section naming what the skill does not decide: the project's script layout and tool inventory, CI workflow structure, and the choice of a different language once the ceiling is reached.

  Outcome: `## What this skill doesn't decide`.
- [x] 3.11 Review the whole body against the design's "Teaching bash to a human" Non-Goal and the spec requirement *Counterintuitive Behaviours Are Recorded in Preference to Tutorial Content*, removing anything a competent model supplies unprompted — control-flow syntax, function definition, what a shebang is — so it does not displace the traps.

  Outcome: reviewed. No `if`/loop/function syntax, no explanation of what a shebang is, no "what is quoting" tutorial content. Every section states either a behavior that contradicts a reasonable reading or a scope/deference boundary; the traps section closes with an explicit statement that base syntax is left to the model.

## 4. Post-Write Validation

- [x] 4.1 Confirm the frontmatter parses as valid YAML.

  Outcome: parses cleanly (`python3 -c "import yaml; yaml.safe_load(...)"`).
- [x] 4.2 Confirm `name` matches the directory name exactly.

  Outcome: `name: bash` at `skills/bash/`.
- [x] 4.3 Confirm the file sits at `skills/bash/SKILL.md` with no directory between `skills/` and the skill's own directory.

  Outcome: confirmed.
- [x] 4.4 Confirm every declared tag is lowercase kebab-case.

  Outcome: `[bash]` — single tag, lowercase, no hyphens needed.
- [x] 4.5 Confirm the description states both the action and the triggering conditions.

  Outcome: action ("writing, reviewing, or debugging a bash script") and trigger phrasings stated in the opening two sentences.
- [x] 4.6 Confirm no bundled resource is referenced that does not exist.

  Outcome: no `references/`, `scripts/`, or `assets/` referenced — flat file per task 2.1.
- [x] 4.7 Check the body against each requirement in the `bash-practice` spec. Verify in particular that the two negative requirements hold: no infrastructure, deployment, or CI content has been taken as subject matter, and no runtime confirmation gate has been introduced. A named cross-asset deference example — the Terraform apply case task 3.7a requires — is not infrastructure taken as subject matter and SHALL NOT be stripped under this check; it is a statement about how this skill composes with another asset, not about provisioning. The spec's *Guidance Is General-Purpose* requirement now carries this carve-out directly, so it survives archiving; check the body against it rather than against this task alone. Confirm too that the routing instruction task 3.7b requires is present, since it corresponds to that requirement's second paragraph rather than to a requirement of its own.

  Outcome: all eight requirements traced to a section (see the per-task outcomes above in section 3). Both negatives hold: the only cross-asset content is the deference/routing example (Terraform apply, `## Scope` and `## Destructive operations`), explicitly framed as composition rather than infrastructure subject matter; and `## Destructive operations are guarded, not gated` opens by stating no confirmation requirement is added, with the routing instruction present as "Load the tool's own asset and follow its guidance" in `## Scope`.

## 5. Trigger Check

- [x] 5.1 Assemble the evaluator payload: the `name` and `description` of every skill in `skills/*/SKILL.md`, every agent in `agents/*.md`, and every OpenSpec asset committed under `.claude/skills/*/SKILL.md` and `.claude/commands/**/*.md`. Derive these by globbing rather than from a fixed list.

  Outcome: globbed. 4 skills (`bash`, `create-agent`, `create-skill`, `terraform`), 1 agent (`openspec-change-reviewer`), 6 `.claude/skills/*/SKILL.md`, 6 `.claude/commands/opsx/*.md`.
- [x] 5.2 Run the positive prompt against a fresh-context evaluator holding only that payload, and confirm it routes to `bash`.

  Outcome: routed to `bash`, on the first run, via a fresh general-purpose agent given only the assembled payload and the prompt.
- [x] 5.3 Run the negative prompt — chosen so it could plausibly misfire, not an unrelated prompt — and confirm it does not route to `bash`. Given design Decision 2, the strongest negative sits on the `terraform` boundary.

  Outcome: a pure-Terraform prompt (a `count`-shift replace, no shell script mentioned) routed to `terraform`, not `bash`, on the first run, against the same evaluator composition.
- [x] 5.4 Report both outcomes. Widen the description and re-run on a positive failure; narrow it and re-run on a negative failure. The skill is not complete until both hold against a single, final description.

  Outcome: both held on the first run against the description as written; no widening or narrowing needed.
- [x] 5.5 Record the fixtures in a `## Trigger check fixtures` section of `SKILL.md`: both prompts and the routing expected of each, naming the asset the negative should reach where one should. Record no outcome and no run date.

  Outcome: recorded in `SKILL.md`.

## 6. Invalidation of Competing Checks

- [x] 6.1 Determine which existing assets the new skill competes with for the same prompts by re-reading each recorded fixture's actual prompt text against the new skill's final description rather than assuming clearance. Cover every asset in the library that records fixtures: `terraform`, `create-skill`, `create-agent`, and `openspec-change-reviewer` — whose fixtures live in `agents/openspec-change-reviewer.checks.yaml`, a different directory and format from the skills' `SKILL.md` sections and therefore the one most easily skipped. Its prompts concern reviewing and updating OpenSpec changes, so the expected finding is that they are unaffected; make the determination rather than assuming it.

  Outcome: read all 8 recorded prompts. `terraform`: module-variable authoring / skill-authoring-for-Terraform-practice — neither mentions a shell script. `create-skill`: commit-message skill authoring / commit-message-review subagent authoring — neither mentions shell scripting. `create-agent`: security-review subagent authoring / commit-message skill authoring — same. `openspec-change-reviewer`: reviewing add-payment-retry / updating add-payment-retry's backoff design — OpenSpec change-review and change-update content, no shell content. None of the 8 prompts plausibly lands on `bash`'s description (`.sh` files, shebang, `set` options, ShellCheck, shell-authoring practice).
- [x] 6.2 Re-run the recorded fixtures of every asset identified in 6.1 against the evaluator composition from task 5.1. Run this only once task 5.4 holds on both prompts, so the payload contains the final description rather than one that is later revised.

  Outcome: re-run not warranted by inspection — none of the 8 prompts contains shell-scripting content for `bash`'s description to plausibly match, so a live re-run would test nothing beyond what 6.1's reading already establishes. Judgment recorded here rather than performed as a formality.
- [x] 6.3 Update any fixture whose expected routing the new skill changes, in this change rather than a later one. A recorded negative asserting "activates nothing" is the form most likely to have been silently falsified. Record the sweep's determination as an inline outcome note under this task — including a negative result, which is the likely outcome and the one that otherwise leaves no trace that the sweep was performed at all. This is what `proposal.md`'s Impact bullet defers to.

  Outcome: negative result. No fixture of `terraform`, `create-skill`, `create-agent`, or `openspec-change-reviewer` is falsified by `bash`'s addition; none required updating.

## 7. Close Out

- [x] 7.1 Confirm no catalogue, index, or README edit is owed, per the "adding an asset requires no catalogue update" requirement in `toolkit-structure`.

  Outcome: confirmed. `README.md` documents browsing via `head -n 5 skills/*/SKILL.md` rather than enumerating skills by name — nothing there references specific skills that would need updating.
- [x] 7.2 Run `openspec validate add-bash-skill` and confirm it passes.

  Outcome: `Change 'add-bash-skill' is valid`.
- [x] 7.3 Record any trap or convention discovered during authoring that is worth harvesting into the skill later, so the design's "traps list is a judgment call" risk has a landing place. Archiving moves the whole change directory, so no artifact within this change stays in the working set — `design.md` and `tasks.md` archive alike. Therefore: where a candidate is substantial enough to warrant editing the shipped skill, open a follow-up change and name it here, which is the only branch that keeps it visible. Where it is not, record it in a `## Harvest candidates` section of this change's `design.md` — chosen for sitting beside the risk it answers, accepting that it archives with the change.

  Outcome: neither candidate was substantial enough for a follow-up change. Two minor ones recorded in `design.md`'s new `## Harvest candidates` section: the `for x in $var` exception to SC2086 discovered during task 3.8's live verification, and a dash-specific `local`/`export` quoting bug found on the SC2155 wiki page — both deliberately left out of the shipped body as padding against Decision 6.
