# Scenario coverage

Accounts for every `#### Scenario:` in the three delta specs of
`add-project-workflow`, per `change-test-authoring`'s counting form: covered
by a named case, or uncovered with a reason. See `README.md` for why this
suite is written directly rather than through `openspec-test-writer`.

## specs/project-bootstrap/spec.md (36 scenarios)

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
| A project's adopted version is readable | Covered — `managed-block-current-version.sh` |
| Project content below the block survives | Covered — `existing-agents-md-appended.sh` |
| A project with only a CLAUDE.md | Covered — `claude-md-only.sh` |
| Rules written but not yet loadable are reported as such | Covered — `empty-directory-new-project.sh`, `import-line-reported.sh` |
| An existing block at a different version is reported, not rewritten | Covered — `managed-block-older-version.sh` |
| Rules remain meaningful without the toolkit installed | Uncovered by this suite — a static property of the fragment's own text (role-before-tool phrasing), not project-init's runtime behavior; verified by reading `rules/development-workflow.md` (section 2) |
| A non-default harness is selected | Covered — `tools-passthrough.sh` |
| Completion is verifiable rather than asserted | Covered — implicitly, every `SUCCESS` case asserts against the report's enumerated form |
| Nothing is committed without confirmation | Covered — `empty-directory-new-project.sh` (asserts no commit exists after a bare run) |
| Discovery is named, not started | Covered — `empty-directory-new-project.sh` (asserts no foundation change directory exists) |
| Behavior is identical on a system shipping an older bash | Uncovered by this suite — requires an actual bash 3.2 host, which this runner does not have; verified instead by hand-review for 4.x-only constructs (tasks 5.17, 5.19) and ShellCheck (5.16, 5.18) |

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

## specs/toolkit-structure/spec.md delta (26 scenarios)

All 26 are uncovered by `tests/cases/` — every one describes repository
layout, documentation content, or plugin-installation behavior, none of
which `scripts/project-init` exercises at runtime. Verified instead by
direct inspection (this session already confirmed several empirically: the
plugin cache contents in section 1, `rules/README.md` and `AGENTS.md`
content in section 7) and by `openspec validate --strict`, which confirms
every `MODIFIED` header matches an existing requirement and no scenario
already in `specsRoot` was dropped.
