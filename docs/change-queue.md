# Change queue

Changes this repository has identified but not yet opened, the order to work
them in, and what each depends on.

An entry is deleted when its change is archived. The working order is this
file's own ordering, so deleting an entry closes the gap and no entry carries a
position another entry's deletion would falsify. Delete this file when the last
entry goes.

This is not `docs/deferred-work.md`. An entry there names something the
repository has deliberately **not** done and is deleted when it stops being
true; an entry here names work that will be done and is deleted when it ships.
One is swept on being fixed and the other on being shipped, so an entry filed
in the wrong file is either deleted early or kept forever.

Each entry names the change that argued it rather than repeating the argument.

## `add-session-workflow-tooling`

`scripts/project-init` learns a workflow variant so
`rules/development-workflow-database.md` can be written as a second managed
block, alongside the block it already writes for
`rules/development-workflow.md`. It reports version skew per block rather than
for one fragment.

Until it ships, the database binding reaches a project by `@` import or by
hand-paste, and carries a `version` nothing increments.

**Argued in**: `consolidate-development-workflow` (proposal, *Follow-up*; and
design decision 3, which fixes the three-block composition the tool writes).

**Depends on**: `consolidate-development-workflow` having produced the binding
fragment. Interacts with `update-managed-block`, which must locate a block by
its own marker rather than assume one block per file.

## `seed-the-worktree-ignore-entry`

`rules/development-workflow.md` v3 fixes a change's working tree at
`.worktrees/<name>`, with `.claude/worktrees/` as the Claude Code binding, and
neither root is named in the ignore file `scripts/project-init` writes.
`project-bootstrap`'s requirement "The minimal ignore file is enumerated, not
described" fixes the created file at exactly seven entries "and no others", and
`tests/cases/gitignore-enumerated-entries.sh` asserts it.

So a freshly initialized project carries the working-tree rules and not the
containment, and the window in which a forced clean at the project root destroys
every session's unmerged work opens at initialization rather than closing there.
v3 states neither the ignore entry nor the recursive-tool scoping, per
`session-workflow`'s rule that a one-time setup obligation is recorded for the
capability that owns project setup rather than added to a fragment every session
reads. This entry is that record.

The change is two obligations, both one-time and neither a session's:

- **the ignore entry** — add the working-tree roots to the enumerated set, with
  a `project-bootstrap` delta amending the requirement and the test case that
  guards it. Without it, sibling trees fill `git status` and `git add -A`
  commits one as an embedded repository;
- **scoping every recursive tool** that does not read the ignore file — test
  collection, linters, type checkers, container build context — so it cannot
  descend into a working-tree root. Without it, one session's run includes every
  other session's source tree. Discharged once per tool, and again when a tool
  is added.

**Argued in**: `consolidate-development-workflow`'s implementation review,
round 2. The gap is new to that change — the obligation lived in
`rules/worktree-isolation.md` until then, and `project-init` never inlined that
fragment.

**Depends on**: nothing. Independent of `add-session-workflow-tooling`.

## `add-development-workflow-skill`

A skill carrying the reasoning behind `rules/development-workflow.md`, so the
fragment can stay short and a session that wants the argument can reach it.

**The constraint that makes this safe, and that the skill must be written
against: nothing in it may change an outcome.** A skill is model-invoked, so
there is no guarantee it loads at the moment it is relevant. Anything a session
must know to act correctly — an instruction, a gate, an exemption, an edge case
with a different answer — stays in the fragment. The skill holds why, worked
examples, and what was rejected. A rule that reads as optional detail but
changes what a session does is the failure this constraint exists to prevent.

The material already exists: `consolidate-development-workflow`'s `design.md`
holds twelve decisions with their rejected alternatives, and the archived
`add-session-workflow-fragments` and `revise-development-workflow` hold more.
The skill assembles what is written rather than inventing it.

Pointers from the fragment to the skill land with this change, not before —
until the skill exists a pointer names something a reader cannot open, which the
fragment's own no-dangling-reference rule forbids.

**Argued in**: `consolidate-development-workflow`'s implementation, on the
operator's observation that detail belongs somewhere reachable but not in a
file every session reads in full.

**Depends on**: nothing. `skills/create-skill/SKILL.md` is the authoring
standard.

## `move-setup-gates-to-project-setup`

Four obligations found in `commerce-ops` and `infrastructure` while writing
`rules/development-workflow.md` v3. Each is sound and none belongs in a fragment
every session reads, because a project discharges each once at setup:

- **Continuous integration fails rather than skips** on a dependency the
  verification requires but cannot reach. A skip a test declares for itself — a
  platform it does not apply to, an optional dependency — is a decision, not a
  gate that failed to run. `commerce-ops` enforces this and has a merged pull
  request that claimed a tier which had skipped.
- **A commit or push hook is not an authority.** It exists only in a clone where
  someone installed it, so its silence is not a pass.
- **Secrets are kept out of version control by the ignore file**, not by
  vigilance at commit time, so committing one takes an override rather than an
  oversight.
- **The project states its test command and test-path glob** — already obliged
  by `project-foundation`, which routes both into a named section of the
  project's conventions. Listed here only so the set is complete; it needs
  nothing.

The first three want a home: `project-foundation`'s checklist, `scripts/project-init`,
or both. The change decides which and states them there.

**Argued in**: `consolidate-development-workflow`, which carried all four in the
fragment until the operator observed they are one-time actions a session never
performs.

**Depends on**: nothing.

## `add-change-code-reviewer`

An agent wrapping `/code-review` with this library's own emphases, completing
the pair `change-plan-reviewer` / `change-code-reviewer`. New authoring rather
than a rename, so `skills/create-agent`'s trigger check and cold-run check
apply.

Once it exists, the workflow fragment's code-review binding names it instead of
`/code-review`, and the negative binding on the plan-review gate can be
re-examined: it currently excludes `/code-review` because that command sounds
general enough to reach for before any diff exists.

**Argued in**: `consolidate-development-workflow`, alongside the rename of
`openspec-change-reviewer` to `change-plan-reviewer`.

**Blocks nothing, but the fragment already names it.** `rules/development-workflow.md`'s
code-review binding reads `ai-toolkit:change-code-reviewer`, so until this
change lands that binding points at an agent that does not exist. Deliberate:
the alternative was naming `/code-review` and rewriting the line twice. In the
interval a session reaching `build`'s review gate has to improvise, which is
the cost being accepted.

**Extend the dangling-reference case when the agent lands.**
`tests/cases/workflow-fragment-no-dangling-reference.sh` scans for `rules/`
paths, fragment filenames and `@` imports; it does not scan for an
`ai-toolkit:` agent name with no file behind it, which is why nothing in the
suite reports this gap or would report its recurrence. The check cannot be
added before the agent exists without failing the suite on a state this change
intends, so it belongs to this change rather than to that one.

## `evaluate-an-openspec-schema-for-our-artifacts`

OpenSpec supports custom schemas, and the `anvil` schema — listed in OpenSpec's
own documentation table — declares artifacts this repository already produces:
`review.md` carrying a machine-readable `VERDICT:` line, `test-plan.md`, and
`verify.md` carrying `DECISION:`.

The value is not the two extra files. It is that a **schema-declared** artifact
is surfaced by `openspec instructions apply` and `openspec status`, where a
bespoke one is not. `change-test-authoring` currently has to oblige the agent to
say out loud that `test-plan.md` "is not an artifact the OpenSpec schema knows
about, so it must be read deliberately" — a defect a schema fixes rather than
documents.

**Adding `review.md` and `verify.md` as bespoke files would not be worth it**,
and `consolidate-development-workflow` established why: it removed a ledger that
recorded verdicts, on the grounds that the commit of an approved plan already
marks that a verdict cleared, and that the write cost falls on every change
forever. A hand-written verdict file is that ledger under another name. What
changes the arithmetic is the schema: the reviewer's report has to land
somewhere regardless, and a declared artifact is where, at no extra obligation.

`verify.md` is the weakest of the three — a recorded `DECISION: PASS` is a claim
about one commit and goes stale on the next.

So the change is: evaluate adopting or forking a schema, not adding files.
Decide whether `test-plan.md` becomes schema-declared, whether the review's
report gains a home, and what that costs in `.openspec.yaml` and in every
change's shape.

**Argued in**: the vocabulary survey at
`openspec/changes/consolidate-development-workflow/handoff.md`, and
`consolidate-development-workflow`'s design decision 6.

**Depends on**: nothing, but best after `consolidate-development-workflow`
lands, since it would reshape the artifacts that change is defining.

## `unwrap-markdown-prose`

Every markdown file in this repository hard-wraps its prose at 75–81 columns,
and nothing requires it to. There is no `.editorconfig`, no markdownlint or
prettier configuration, no clause in `AGENTS.md` and no requirement in any
specification. The convention propagated by imitation: each file copied the
shape of the last.

It is mentioned exactly once, in `revise-development-workflow`'s design, which
decided not to rewrap carried sections because "in every consuming project's
diff a reflowed line is indistinguishable from an edited one". That is a good
reason not to rewrap *while editing* and no reason to keep wrapping; it
entrenched the habit without arguing for it.

The change is: unwrap every markdown file to one sentence per line, which keeps
diffs line-scoped — the only real benefit hard wrapping had — and record the
convention so the next file written by imitation does not wrap again. It must
be a change that does nothing else, so that every line in its diff is reflow
and no edit hides in the noise, which is the failure the archived decision was
avoiding.

`rules/development-workflow.md` is already unwrapped, in
`consolidate-development-workflow`, at the operator's direction. Every other
file is outstanding: `README.md`, `AGENTS.md`, `rules/`, `skills/`, `agents/`,
`docs/`, `tests/` and `openspec/specs/`.

**Argued in**: `consolidate-development-workflow`'s implementation, on the
operator's finding that the wrapping is undocumented and unwanted.

**Depends on**: nothing. Best done when no other change is in flight, since it
touches every file.

## The suite's own gaps

Three questions the test-writing pass raised and did not resolve, recorded
here because each is a change rather than a deferral:

- `tests/run.sh` has **no single-case selector**, so running one case means an
  explicit three-variable invocation.
- The suite omits `set -euo pipefail`, which the `bash` skill's floor requires
  of a shell script in this repository.
- No convention records whether an obsolete case is **deleted or rewritten**.
  `consolidate-development-workflow` deleted six and said so; nothing makes
  that the rule.

**Argued in**: `consolidate-development-workflow`'s `test-plan.md`, under
*Unresolved project questions*.
