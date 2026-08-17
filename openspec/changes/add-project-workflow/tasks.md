## 1. Verify the assumptions the design rests on

These run first because each can invalidate a structural decision. None depends on code being written.

- [ ] 1.1 Confirm a `scripts/` directory at the repository root ships in an installed copy: add a throwaway file, install via `/plugin marketplace add` + `/plugin install`, and observe it present in the plugin cache alongside `rules/`. Remove the throwaway afterwards. (`tests/` is not checked here — it does not exist until section 3, and nothing in the change requires it to ship.)
- [ ] 1.2 Confirm whether `$CLAUDE_PLUGIN_ROOT` is populated at skill runtime, using a throwaway skill that echoes it under `claude --plugin-dir ~/projects/ai-toolkit`. Record the result in `design.md` — if unpopulated, the skill documents `$AI_TOOLKIT_ROOT` as a setup step and the resolution chain is unchanged.
- [ ] 1.3 Confirm `openspec init` behaves non-interactively with an explicit `--tools` value, and record which value the script uses as its documented default.
- [ ] 1.4 Enumerate exactly what `openspec init --tools <default>` creates or modifies in a directory that already contains `AGENTS.md`, `CLAUDE.md`, `.gitignore` and source files. Record the list in `design.md`. This bounds the never-overwrite guarantee against a delegated command whose writes the tool does not control — checking only that the command "does not fail" would leave the change's headline safety property unverified on the adoption path.
- [ ] 1.5 Confirm `openspec init` does not fail when run inside a directory that is already a Git repository but has no `openspec/`, since that is the adoption path.
- [ ] 1.6 Establish whether Claude Code loads a project's `AGENTS.md` when no `CLAUDE.md` imports it, and record the result in `design.md`. This repository's own `toolkit-structure` models conventions as reaching Claude Code through a `CLAUDE.md` holding a single `@AGENTS.md` import — if that import is load-bearing, writing `AGENTS.md` alone leaves the workflow rules inert on the harness this library primarily serves, while the run reports `SUCCESS` and stamps a version. Determine it before implementation; it decides whether the report must name an import line the user has to add.
- [ ] 1.7 Establish the same for the other harnesses the change claims read `AGENTS.md` natively, or narrow the claim in `proposal.md` to the ones actually verified.

## 2. Write the rule fragments

The script reads these, so they exist before it does.

- [ ] 2.1 Write every fragment's frontmatter in the form the `toolkit-structure` delta fixes — `kind`, plus `version` where the fragment is inlined — so the script's parser and the fragments agree by construction.
- [ ] 2.2 Write `rules/development-workflow.md`: spec-driven development, test design before implementation, independent review after it, verification before any completion claim, small focused commits suggested and never made automatically, scope control, and repository-over-conversation as the source of truth.
- [ ] 2.3 State each rule as a role first, naming `ai-toolkit:openspec-test-writer` and `ai-toolkit:openspec-change-reviewer` beneath the relevant rules as Claude Code bindings rather than as bare references.
- [ ] 2.4 Declare `kind: standing-constraint` and an initial `version` in `rules/development-workflow.md`, giving the script a value to stamp into the marker.
- [ ] 2.5 Write `rules/project-foundation.md` carrying the nine foundation decisions, declared `kind: procedural-checklist` and explicitly not intended for a project's conventions file.
- [ ] 2.6 State in `rules/project-foundation.md` the foundation change's exemption from test authoring, with its reason, and that the exemption does not extend past foundation.
- [ ] 2.7 Add the `kind` declaration to every fragment already in `rules/` — `test-manifest.md` and any other — so the widened `toolkit-structure` requirement is true of the repository the moment it lands rather than violated on day one.

## 3. Build the test harness

The repository has no test infrastructure; this is new ground rather than an addition.

- [ ] 3.1 Write `tests/run.sh` with `assert_exit`, `assert_file`, `assert_file_absent`, `assert_unchanged`, and `assert_contains`, discovering and executing every case in `tests/cases/` and reporting a pass/fail count.
- [ ] 3.2 Give each case an isolated temporary directory created and removed by the harness, so no case can observe another's filesystem state.
- [ ] 3.3 Make the harness exit non-zero when any case fails, so it is usable from a shell or a future CI job.
- [ ] 3.4 Confirm the harness reports a deliberately failing case as failing — an untested harness proves nothing about the cases it runs.

## 4. Write the test cases before the script exists

Derived from the scenarios in `specs/project-bootstrap/spec.md`. All fail until section 5. Root resolution is not covered here: it belongs to the caller, not the script, so it is verified in section 6.

- [ ] 4.1 Record why these cases are written here rather than dispatched to `ai-toolkit:openspec-test-writer`, which the workflow rules this change ships would otherwise require. The dispatch contract's essential inputs — a test command and a test-path glob — do not exist until section 3 creates them, which is the same structural bootstrap problem the foundation exemption records. State it as an exemption with its reason, so the first suite in the repository is not authored in silent violation of the rule the change is introducing.
- [ ] 4.2 Empty directory: every concern created, exit `0`, report names foundation discovery as the next step.
- [ ] 4.3 Existing Git repository without specification tooling: repository skipped, tooling created, each concern reported separately.
- [ ] 4.4 Existing repository and existing specification tooling: both reported as already satisfied, neither reinitialized.
- [ ] 4.5 Existing `.gitignore`: byte-for-byte unchanged, presence reported, nothing appended or merged.
- [ ] 4.6 Existing `AGENTS.md` with project content: managed block appended, every line outside it unchanged.
- [ ] 4.7 `CLAUDE.md` present and `AGENTS.md` absent: `AGENTS.md` created with the block, `CLAUDE.md` unmodified.
- [ ] 4.8 Existing managed block at the current version: skipped, not duplicated, not rewritten.
- [ ] 4.9 Existing managed block at an earlier version: left unchanged, and the report states both versions and that reconciling them is out of scope.
- [ ] 4.10 Required fragment absent from the script's own copy: `BLOCKED`, exit `2`, no conventions file written without the rules.
- [ ] 4.11 Repeated execution: a second run against an unchanged directory modifies, truncates, or duplicates nothing.
- [ ] 4.12 Adoption of a repository with existing history: no foundation change created, report names foundation discovery as available.
- [ ] 4.13 Created `.gitignore` contains exactly the entries enumerated in the requirement, and no stack-specific entry.
- [ ] 4.14 After a full adoption run, `AGENTS.md` differs from its original only by the appended block, and any other file the delegated initializer touched is attributed to it in the report.
- [ ] 4.15 Delegated initializer forced to fail, using a stub earlier on `PATH`: terminal outcome `ERROR`, exit `1`, and a report naming which concerns completed and which did not. Without this the `ERROR` path — and exit code `1` — is never asserted anywhere, in a change whose stated thesis is that failure semantics are contract rather than formatting.
- [ ] 4.16 External command absent for an **outstanding** concern: `BLOCKED`, exit `2`, **and the directory otherwise untouched** — no repository initialized, no file created. Asserting the outcome without asserting the untouched directory would pass against an implementation that validates lazily.
- [ ] 4.17 External command absent for an **already-satisfied** concern: the run proceeds, that concern is reported as already present, and the outcome is not `BLOCKED`. This is the case that distinguishes a precondition set scoped to outstanding concerns from one validated unconditionally, and the two differ observably.
- [ ] 4.18 `--tools` with a non-default value: the passthrough reaches the delegated command rather than being ignored or overridden.
- [ ] 4.19 Re-run after the forced failure of case 4.15 completes the unfinished concerns and reports `SUCCESS`, verifying the documented recovery path rather than assuming idempotency delivers it.
- [ ] 4.20 Target directory: a run given an explicit path argument initializes that directory and not the current one, and the report states which directory it acted on.
- [ ] 4.21 Unusable target: a path that does not exist, is not a directory, or is not writable produces `BLOCKED`, exit `2`, and creates nothing.
- [ ] 4.22 Subdirectory of an existing repository: run in an uncommitted directory that sits inside a committed repository but has no `.git` of its own — the repository concern is reported unsatisfied, a new repository is initialized rooted at the target (not the enclosing one), and mode derives from the new repository's commit history. This is the case the target-scoping rule exists to fix; without a case it ships unverified.
- [ ] 4.23 Fragment absent while a managed block is already present: `BLOCKED`, because the report cannot state "the version the tool carries" without reading the fragment, even though the conventions-file concern itself is satisfied. Distinguishes the fragment's unconditional read from the scoped-to-outstanding treatment given to external commands.
- [ ] 4.24 `--help` states the tool's modes, arguments, flags, outcomes and exit codes — the portable interface a wrapper for another harness is written against, and the one surface no other case touches.
- [ ] 4.25 Self-location under a conflicting environment: the script run from one copy with an environment variable naming a different toolkit root reads its own copy's fragments and stamps that copy's version.
- [ ] 4.26 Conditional on task 1.6 finding the import load-bearing: the report names the import line a project needs for the rules to load. This is the newest obligation in the change and its stated failure mode is the silent divergence the whole change exists to prevent, so it does not ship on an unexercised code path.
- [ ] 4.27 Account for every scenario in the three delta specs as either covered by a named case or uncovered with a reason, in the counting form `change-test-authoring` defines. Coverage is a count there rather than a judgment, and section 4's exemption from dispatching the test-writer removes the agent, not the accounting it would have produced.
- [ ] 4.28 Before section 5, confirm each case fails on the script's absence and is free of harness, path, or syntax errors of its own — absence is the only failure available at this point, so this establishes the cases are runnable, not that their assertions bite.

## 5. Write the script

- [ ] 5.1 Create `scripts/project-init` with `#!/usr/bin/env bash`, using no construct unavailable in bash 3.2.
- [ ] 5.2 Derive the script's own directory from its invocation path and read fragments relative to it, consulting no environment variable — a script that re-resolved could inline text from one copy while stamping the version of another.
- [ ] 5.3 Operate on the current working directory, accept an optional path argument naming a different target, and state the target in the report before making any change.
- [ ] 5.4 Validate preconditions before attempting any concern: the fragment unconditionally (it is read regardless of which concerns are outstanding, since the report needs its version even when nothing is written), target-directory validity, and external commands scoped to the concerns that are actually outstanding — so a `BLOCKED` outcome is true to its definition that no filesystem change was made, without refusing to run over a command a satisfied concern never needed.
- [ ] 5.5 Parse `kind` and `version` from fragment frontmatter in the form fixed by the `toolkit-structure` delta, and fail loudly rather than defaulting if either is absent.
- [ ] 5.6 Implement the three terminal outcomes with exit codes `0`, `1`, `2`, ensuring the reported outcome and the exit code can never disagree.
- [ ] 5.7 Implement per-concern checks — repository, specification tooling, ignore file, conventions file, managed block — each completing what is absent and skipping what is present.
- [ ] 5.8 Derive mode from whether the repository has at least one commit; use it only to select how the report names the next step.
- [ ] 5.9 Create the `.gitignore` only when absent, with the entries enumerated in `specs/project-bootstrap/spec.md` verbatim.
- [ ] 5.10 Resolve the conventions file per the spec's ordered rule: append to `AGENTS.md` if present; create `AGENTS.md` if absent, leaving any `CLAUDE.md` untouched.
- [ ] 5.11 Append the managed block with the delimiters and do-not-edit notice from `design.md`, stamping the fragment version into the opening marker.
- [ ] 5.12 Where a managed block already exists, skip it and report both its recorded version and the version the tool carries.
- [ ] 5.13 Implement `--tools` as a passthrough with the default recorded in task 1.3.
- [ ] 5.14 Write `--help` covering modes, arguments, flags, outcomes, and exit codes, sufficient for someone to write a wrapper without reading any skill.
- [ ] 5.15 Emit the report: the target directory, each concern and its outcome, the terminal outcome, the next step, plus the obligations other requirements place on it — the workflow version where a block was inlined, both versions where one was already present, any import line still needed for the rules to load, and attribution of files written by the delegated initializer.
- [ ] 5.16 Run the full suite from section 4 and confirm every case passes.
- [ ] 5.17 Confirm each assertion is load-bearing by altering a behaviour deliberately and observing the corresponding case fail — a suite that passes against a broken script proves nothing.
- [ ] 5.18 Run ShellCheck clean, and state explicitly which obligations it does not cover, per `skills/bash`.
- [ ] 5.19 Review for bash 4.x-only constructs by hand — associative arrays, `${var,,}`, `readarray` — since ShellCheck does not check version compatibility by default.

## 6. Write the Claude Code skills

Root resolution lives here, not in the script.

- [ ] 6.1 Write `skills/project-init/SKILL.md` as a thin wrapper: resolve the toolkit root through the ordered chain, invoke `bash <root>/scripts/project-init`, relay the report, offer a commit and wait for confirmation, name the next step without taking it.
- [ ] 6.2 Implement the chain in the skill — `$AI_TOOLKIT_ROOT`, then `$CLAUDE_PLUGIN_ROOT`, then the machine-local path — and state that it reports blocked and invokes nothing if none resolves, never running the underlying commands itself.
- [ ] 6.3 Verify the chain manually at every level, including its failure: explicit variable set; variable unset with the plugin installed; both unset falling back to the machine-local path; and all three unresolvable, where the skill must report blocked and invoke nothing. This is the coverage `tests/cases/` cannot reach, so an untested blocked-caller path would go unverified entirely.
- [ ] 6.4 Write `skills/project-foundation/SKILL.md` as the conversational wrapper over `rules/project-foundation.md`, carrying the supplied-versus-proposed classification and the stop condition, without duplicating the checklist.
- [ ] 6.5 Specify the seven fixed `design.md` section headings, with `Identity` carrying a named item per absorbed decision so an unanswered one stays individually visible.
- [ ] 6.6 Specify that the stack-specific `.gitignore` extension is a deliverable of the `Development Tooling` decision, closing the gap bootstrap deliberately leaves.
- [ ] 6.7 Specify that decisions are written as they settle, and that foundation delegates artifact creation to the existing change-authoring path rather than generating artifacts itself.
- [ ] 6.8 Specify archival of the foundation change as the completion signal, and that nothing afterwards reconciles the project against it — a later architectural shift is a new change, not a foundation violation.
- [ ] 6.9 Write both descriptions to draw the boundary between deterministic setup and foundation decisions explicitly, per `skills/create-skill`.
- [ ] 6.10 Author both skills through `ai-toolkit:create-skill` rather than by hand, so `skill-authoring`'s frontmatter contract, tag-vocabulary check, human-in-the-loop checkpoints and post-write validation are discharged by the standard that owns them rather than partially re-derived here.
- [ ] 6.11 Record the trigger-check fixtures in each `SKILL.md` — a positive prompt and a negative one naming the competing asset that should serve it — per `skill-authoring`'s requirement that fixtures be recorded, not merely that a check be run.

## 7. Update documentation

- [ ] 7.1 Update `AGENTS.md` with the three categories: library assets, shipped tooling (`scripts/`), and repository tooling (`.claude/`).
- [ ] 7.2 State in `AGENTS.md` what belongs in `scripts/` — deterministic operations with exactly one correct outcome, meant to be run directly — and what belongs inside a skill's own `scripts/` instead.
- [ ] 7.3 State explicitly in `AGENTS.md` that `scripts/` contents ship and are meant to be run by consumers, naming `.claude/` as the home for repository-only tooling, since the directory name suggests otherwise.
- [ ] 7.4 Document `tests/` as a dependency-free harness for shipped tooling, and that running it may require the external commands that tooling drives while using the library still requires nothing installed.
- [ ] 7.5 Update `AGENTS.md`, the root `README.md`, **and `rules/README.md`** to describe both rule consumption paths. `rules/README.md` currently states that rules are not carried by the plugin, which is exactly what the widened requirement forbids documentation from saying — leaving it unedited would violate the requirement the moment it lands.
- [ ] 7.6 Document the two fragment kinds and the frontmatter form that declares them.

## 8. Verify end to end

The suite exercises the script directly and cannot reach skill invocation, real plugin installs, or interactive tooling.

- [ ] 8.1 Run the new-project path manually in an empty directory through to a created foundation change, using the installed plugin rather than the working tree.
- [ ] 8.2 Run the adoption path against a scratch copy of a repository that has code and an `AGENTS.md` but no OpenSpec, so the delegated initializer actually runs — the one condition under which task 1.4's findings can be observed in place.
- [ ] 8.3 Decide whether this repository keeps the managed block in its own `AGENTS.md`, before running 8.4. Keeping it puts a generated copy of `rules/development-workflow.md` into a file whose contents `toolkit-structure` enumerates without contemplating a generated block, and creates a drift-prone duplicate of a library fragment inside the library. Reverting is the default; keeping requires widening the documentation requirement in this same change.
- [ ] 8.4 Run the adoption path against `ai-toolkit` itself: repository and tooling skipped, `.gitignore` and `AGENTS.md` content untouched apart from the appended block, no foundation change created. Apply the decision from 8.3 to the result.
- [ ] 8.5 Confirm both skills trigger on their intended prompts and neither fires on the other's, per `skills/create-skill`'s trigger-check requirement.
- [ ] 8.6 Enumerate every asset competing for the prompts these two skills answer to — including any under `.claude/`, which `skill-authoring` expressly contemplates as a fixture destination — then re-run the recorded checks of those that compete and state which were found not to. Scoping to `create-skill` and `create-agent` by assertion would let a recorded negative elsewhere silently become false.
- [ ] 8.7 Confirm the workflow rules read sensibly in a project without the plugin installed — each rule states an obligation, and the named agents read as bindings rather than as required references.

## 9. Review and close

- [ ] 9.1 Dispatch `ai-toolkit:openspec-change-reviewer` against this change before considering it complete.
- [ ] 9.2 Resolve the `design.md` open question on `PATH` documentation, or record it as still deferred with the reason.
- [ ] 9.3 Confirm no file under `.claude/` was modified, since `openspec update` regenerates that directory.
- [ ] 9.4 Commit in reviewable units rather than as one change, per the workflow this change establishes.
