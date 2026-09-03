# Scenario coverage

Accounts for every `#### Scenario:` in the delta specs of the changes that
have shaped this suite — `add-project-workflow`, which established it, and
`revise-development-workflow`, which added 13 scenarios across two
capabilities — per `change-test-authoring`'s counting form: covered by a
named case, or uncovered with a reason. See `README.md` for why this suite is
written directly rather than through `openspec-test-writer`, and for the
second, narrower exemption `revise-development-workflow` records there.

Most scenarios this suite cannot cover are of one kind, and it is worth
naming once rather than repeating per row: the harness exercises
`scripts/project-init`'s runtime behavior, while several requirements
constrain the *prose* of a fragment the script copies without interpreting.
A property of that prose is not observable by running the script, so it is
verified by reading — except where it can be made mechanical, which
`fragment-role-before-tool.sh` does for the role-before-tool constraint.
That is a stated limit of what this harness can reach, not an omission.

## specs/project-bootstrap/spec.md (48 scenarios)

| Scenario | Status |
|---|---|
| A non-skill-aware tool can use it | Covered — `help-output.sh` |
| An explicit target is acted on and stated | Covered — `explicit-target-argument.sh` |
| An unusable target blocks | Covered — `unusable-target-blocks.sh` |
| The entry point is not buried inside a skill | Uncovered — static filesystem layout, not tool runtime behavior; verified by directory listing |
| No Claude Code environment is present | Uncovered here — caller-side behavior (the resolution chain lives in the skill, not the script, per the spec's own split); verified manually by task 6.3 |
| A caller cannot resolve any root | Uncovered here — caller-side; verified manually by task 6.3 |
| The executable bit is not relied upon | Covered — `executable-bit-not-relied-upon.sh` (and implicitly, every other case invokes via `bash`) |
| Fragments come from the copy the script belongs to | Covered — `self-location-conflicting-env.sh` |
| Explicit root reaches the working tree through the caller | Uncovered here — caller-side; verified manually by task 6.3 |
| A machine consumer can branch on the result | Covered — implicitly by every case's `assert_exit` against the documented codes |
| A command missing for an already-satisfied concern does not block | Covered — `command-absent-satisfied-proceeds.sh` |
| The fragment is read even when nothing will be written | Covered — `fragment-absent-block-present-blocks.sh` |
| Missing fragment blocks rather than degrades | Covered — `fragment-absent-blocks.sh` |
| A wrapper cannot find the tool | Uncovered here — caller-side; verified manually by task 6.2/6.3 |
| Empty directory takes the new-project path | Covered — `empty-directory-new-project.sh` |
| Existing repository takes the adoption path | Covered — `adoption-no-foundation-change.sh`, `existing-git-and-openspec.sh` |
| A subdirectory of an existing repository is not treated as already initialized | Covered — `subdirectory-of-existing-repo.sh` |
| Repeated execution is not destructive | Covered — `repeated-execution-idempotent.sh` |
| A partially initialized directory is completed, not refused | Covered — `existing-git-no-openspec.sh` |
| Existing specification tooling is skipped, not reinitialized | Covered — `existing-git-and-openspec.sh` |
| Failure midway leaves a reported, recoverable state | Covered — `delegated-init-failure.sh`, `recovery-after-failure.sh` |
| A delegated command's writes are attributed, not concealed | Covered — `adoption-agents-md-diff-only.sh` |
| An existing ignore file is preserved exactly | Covered — `existing-gitignore-preserved.sh` |
| An existing conventions file receives only the managed block | Covered — `existing-agents-md-appended.sh` |
| Created ignore file carries no stack assumption | Covered — `gitignore-enumerated-entries.sh` |
| A project's adopted version is readable | Covered — `managed-block-current-version.sh` for the version marker, `inlined-body-matches-fragment.sh` for the body, which is compared against the fragment byte-for-byte. The latter guards faithful inlining by the script; it cannot detect a project whose block has fallen behind the toolkit, because the script always re-inlines from the current fragment |
| Project content below the block survives | Covered — `existing-agents-md-appended.sh` |
| A project with only a CLAUDE.md | Covered — `claude-md-only.sh` |
| Rules written but not yet loadable are reported as such | Covered — `empty-directory-new-project.sh`, `import-line-reported.sh` |
| An existing block at a different version is reported, not rewritten | Covered — `managed-block-older-version.sh` |
| Rules remain meaningful without the toolkit installed | Covered — `fragment-role-before-tool.sh`, which asserts mechanically that no harness-specific name appears outside a binding paragraph. Was review-only until `revise-development-workflow` made it checkable |
| A non-default harness is selected | Covered — `tools-passthrough.sh` |
| Completion is verifiable rather than asserted | Covered — implicitly, every `SUCCESS` case asserts against the report's enumerated form |
| Nothing is committed without confirmation | Covered — `empty-directory-new-project.sh` (asserts no commit exists after a bare run) |
| Discovery is named, not started | Covered — `empty-directory-new-project.sh` (asserts no foundation change directory exists) |
| Behavior is identical on a system shipping an older bash | Uncovered by this suite — requires an actual bash 3.2 host, which this runner does not have; verified instead by hand-review for 4.x-only constructs (tasks 5.17, 5.19) and ShellCheck (5.16, 5.18) |
| A plausible wrong tool is excluded by name | Covered — `fragment-role-before-tool.sh` (asserts a negative binding is stated) |
| An excluded tool's own contract is what the exclusion rests on | Uncovered — the reason's *accuracy* against `agents/openspec-change-reviewer.md` is a judgment, not a string match; verified by reading |
| A stage boundary names an observable rather than a stage | Uncovered — a property of the fragment's prose; verified by reading |
| An obligation dispatched against incomplete inputs is prevented, not merely discouraged | Uncovered — prose property; verified by reading |
| A missing precondition halts rather than annotates | Uncovered — prose property; verified by reading |
| An exemption stated in advance is not a gap noted at the gate | Uncovered — prose property; verified by reading |
| A gate does not foreclose a change that structurally cannot satisfy it | Uncovered — prose property; verified by reading, against `project-foundation`'s stated exemption |
| The bound is reached rather than exceeded | Uncovered — prose property; verified by reading |
| The bound survives the binding being absent | Uncovered — prose property; verified by reading |
| A non-revisable outcome exits rather than iterates | Uncovered — prose property; verified by reading |
| An edited fragment is distinguishable from the copy already adopted | Covered — `managed-block-older-version.sh`, which now reads the tool's version from the fragment via `fragment_version` rather than asserting a literal |
| A frontmatter-only edit does not consume a version | Uncovered — an obligation on a future author, not behavior `project-init` exhibits; verified by reading `rules/README.md` |

## specs/project-foundation/spec.md (14 scenarios)

All 14 are uncovered by `tests/cases/`, for the same reason: this directory
exercises `scripts/project-init` only (per section 4's own scope note), and
every foundation scenario describes conversational or skill behavior
(`skills/project-foundation/`) with no deterministic script to run against
it. Verified instead by: manual skill trigger-checks (task 8.5), and
structural review of `skills/project-foundation/SKILL.md` and
`rules/project-foundation.md` against the spec's requirements (section 6).

| Scenario | Verified by |
|---|---|
| A non-skill-aware tool follows the same procedure | Structural review — the checklist lives in a fragment, readable independently |
| The checklist does not accumulate in projects | Structural review — `rules/project-foundation.md` is `kind: procedural-checklist`, never inlined |
| Non-goals are recorded even when scope is clear | Structural review — `rules/project-foundation.md` states this explicitly |
| Stack-specific ignore entries are a foundation deliverable | Structural review — task 6.6 |
| A technical decision is proposed rather than asked | Structural review — `skills/project-foundation/SKILL.md`'s classification |
| An identity decision is not invented | Structural review — same |
| A skipped decision is detectable after the fact | Structural review — the fixed `design.md` section set (task 6.5) |
| A decision absorbed into a shared section stays visible | Structural review — the `Identity` named-item requirement (task 6.5) |
| A conversation resumed in a new session loses nothing | Structural review — task 6.7's incremental-persistence instruction |
| Artifacts are produced by the existing mechanism | Structural review — task 6.7 |
| Test authoring is skipped for a stated reason | Structural review — `rules/project-foundation.md` (section 2) |
| The exemption does not extend past foundation | Structural review — same |
| Lifecycle position is derived, not stored | Structural review — no state file exists anywhere in this change |
| A later architectural change is not a violation | Structural review — `rules/project-foundation.md` states this explicitly |

## specs/toolkit-structure/spec.md delta (27 scenarios)

Of the 27, the one this change adds — "The increment rule has exactly one
owner" — is uncovered: it asserts that a normative obligation is stated in
exactly one capability, which is a property of two specification files rather
than of anything `scripts/project-init` does. Verified by reading both, and
by `rules/README.md` naming the owner.

The other 26 are uncovered by `tests/cases/` — every one describes repository
layout, documentation content, or plugin-installation behavior, none of
which `scripts/project-init` exercises at runtime. Verified instead by
direct inspection (this session already confirmed several empirically: the
plugin cache contents in section 1, `rules/README.md` and `AGENTS.md`
content in section 7) and by `openspec validate --strict`, which confirms
every `MODIFIED` header matches an existing requirement and no scenario
already in `specsRoot` was dropped.

## specs/session-workflow/spec.md (37 scenarios)

This change ships no executable. Its deliverable is three markdown fragments
under `rules/`, so the scenarios divide by what a shell case can reach: a
property of the finished files, or a description of what an agent following
them would do.

**One covered in full** — "A fragment carries no version claim"
(`session-fragment-frontmatter.sh`).

**Seven covered in part**, each with the unasserted half named in the
change's `test-manifest.md`: the two adoptability scenarios and "The gate is
checkable without a delivery fragment" (`session-fragments-name-no-sibling.sh`,
`change-delivery-names-no-working-tree.sh`), "A recursive tool does not
descend into sibling working trees" and "The deferred-work file does not yet
exist" (`session-fragments-name-fixed-paths.sh`), "A project carrying both
fragments has one rule to follow, not two"
(`deferred-work-states-workflow-seam.sh`), and "A fragment is adopted without
tooling" (`session-fragments-not-inlined.sh`).

**Twenty-nine uncovered**, for two reasons. Most describe what a session
*does* — report verification as not run rather than as a pass, decline to
inherit a surviving namespace, halt teardown on uncommitted work. There is no
program in this repository to run them against, the same limit this file
already records for `project-foundation` and the `toolkit-structure` delta.
The rest are properties of prose: whether a rule's durable half is its
instruction, whether creation and teardown are *stated* as one invariant,
whether provisioning is phrased as a state rather than an act. A token scan
cannot tell a rule from a mention, and one built to try would fail on a
faithful wording. Tasks 4.1, 4.2, 4.4, 4.6 and 4.7 direct each of these by
reading, and say so.

Two candidates were declined rather than approximated, and the reasoning is
in `test-manifest.md` under *Deliberately untested*. The namespace-release
check (task 4.6) is the sharper one: requirement 6 obliges
`worktree-isolation.md` to *state* that it allocates and does not release, so
a correct fragment necessarily contains a sentence carrying both a release
verb and the word "namespace" — any lexical scan for that pair fails on a
compliant fragment.
