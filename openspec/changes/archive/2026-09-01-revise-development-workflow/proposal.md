## Why

`rules/development-workflow.md` v1 states eight obligations as an unordered
set. Working under it in real projects surfaced a class of failure it cannot
prevent: an agent that satisfies every rule individually while running them
in the wrong order — dispatching a reviewer at a half-written change package,
starting implementation before review, deriving tests from specification
deltas that were still moving. Nothing in v1 states a sequence, so nothing is
violated.

It also carries one binding that is simply wrong. Its "Independent review
before completion" rule asks for a post-implementation review of the
implementation and binds it to `ai-toolkit:openspec-change-reviewer` — an
agent whose own description states it "reviews the plan, not the code that
follows it — diffs belong to code review". The rule points an agent at a job
that agent declines, so the review it asks for has never been the review that
happens.

## What Changes

- **The fragment gains an explicit ordering with checkable gates.** Review of
  the change package, then a commit of the approved plan, then test
  authoring, then implementation, then verification, then review of the diff.
  Each gate names what must be observably present before it is passed, so an
  agent can check the precondition rather than judge whether the spirit of a
  rule was met.
- **Review is repositioned from a post-implementation check to a gate on
  implementation**, matching what `ai-toolkit:openspec-change-reviewer`
  actually does, and is required to be dispatched only against a complete
  artifact package.
- **The revise-and-re-review loop becomes bounded** — an initial review plus
  at most five automatic re-reviews, after which the agent reports where the
  loop stands and asks before continuing. A verdict that the change's concept
  is unsound exits the loop immediately rather than consuming rounds.
- **A commit of the approved plan is required before tests are derived from
  it**, fixing the baseline the test-to-scenario mapping is written against.
- **The test-authoring gate keeps v1's scoping.** It applies to a change with
  behavior tests can be derived from, and yields to an exemption a
  specification or project rule states in advance — `project-foundation`'s
  `SHALL`-level exemption, and a change carrying no specification deltas.
  Author independence stays in the role sentence, not the binding.
- **Post-implementation review returns, correctly bound** to `/code-review`,
  and carries an explicit negative binding naming
  `ai-toolkit:openspec-change-reviewer` as the wrong agent for that role.
- **BREAKING** for consuming projects in the sense that matters here: the
  fragment's `version` goes `1` → `2`, and `scripts/project-init` does not
  rewrite an existing managed block. Every project already carrying the v1
  block keeps it and is reported as version-skewed. Propagating v2 to those
  projects is deliberately **not** in this change's scope — see Impact.
- **The fragment's version-increment rule gets one owner.** `toolkit-structure`
  states it in whole-file terms today; this change needs it body-scoped, so
  `project-bootstrap` owns the condition, `toolkit-structure` keeps the
  frontmatter's form and defers by name, and `rules/README.md` is narrowed to
  match. Two capabilities answering the same edit differently is the defect
  being removed.
- Test cases that hardcode the literal version `1` are changed to read the
  version from the fragment, so that a future fragment edit does not break
  the suite for a reason unrelated to what it tests.

## Capabilities

### New Capabilities

None. This change alters what the workflow-rule fragment must contain and
how a caller must sequence the roles it names, both of which fall under the
existing `project-bootstrap` capability.

### Modified Capabilities

- `toolkit-structure`: its "One directory level for every asset type"
  requirement currently fixes both the rule fragment's frontmatter form and
  the condition under which `version` increments. It keeps the form and
  defers the increment condition to `project-bootstrap` by name, so one rule
  has one owner.
- `project-bootstrap`: the requirement governing the fragment's content
  ("The workflow rules name a role before naming a tool") is extended to
  admit a binding that excludes a tool as well as one that names it. Three
  requirements are added: that the rules state an ordered sequence whose
  gates have checkable preconditions; that any automatic agent-dispatch loop
  the rules state is bounded and states its bound as a role-level obligation
  rather than only inside a harness binding; and that the fragment's
  `version` increments whenever its body text changes.

## Impact

- `rules/development-workflow.md` — body substantially rewritten (two
  sections rewritten, one added, one restored with a corrected binding, five
  sections plus the opening paragraph carried over byte-identically);
  frontmatter `version: 1` → `2`.
- `openspec/specs/project-bootstrap/spec.md` — one requirement modified,
  three added, via this change's delta spec.
- `openspec/specs/toolkit-structure/spec.md` — one requirement modified, to
  defer the version-increment condition rather than state a second, divergent
  copy of it.
- `tests/cases/managed-block-older-version.sh` and
  `tests/cases/self-location-conflicting-env.sh` — assert the literal
  `version 1` / `v1` and fail on the version bump for a reason unrelated to
  what either tests.
- `tests/cases/managed-block-current-version.sh` — the worse case: its `v1`
  fixture stops being "a block at the current version", so it keeps passing
  while no longer covering the scenario it exists for. A silent loss of
  coverage rather than a visible failure.
- All three are changed to derive the expected version from the fragment.
- `tests/coverage.md` — new scenarios need coverage entries.
- Delta-spec scenarios constraining prose are verified by review, not by the
  harness, except the role-before-tool check, which is mechanical. Recorded
  in `tests/coverage.md` as a stated limit.
- **Not in scope: propagating v2 to projects already carrying the v1 block.**
  `scripts/project-init` reports version skew and never rewrites an existing
  block, by an existing requirement of `project-bootstrap` that this change
  does not touch. Three projects on this machine currently carry the v1 block
  (`commerce-ops`, `commerce-ops-product-dossier`, `infrastructure`) and will
  continue to. A block-updating capability is its own change: it needs its
  own decisions about hand-edited blocks and its own spec surface, and
  bundling it here would produce a change too large to review in one sitting.
