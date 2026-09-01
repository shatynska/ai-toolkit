---
kind: standing-constraint
version: 2
---

# Development workflow

These rules establish how work proceeds on this project once it has a
foundation. They apply independently of any single tool — each names an
obligation as a role to fill, and where this project uses Claude Code, names
the binding for that role beneath it.

## Spec-driven development and spec review

Use a specification-driven change process for non-trivial features, changes,
and significant architectural decisions. Do not begin implementing or
applying a non-trivial change without a corresponding change proposal
recording what is intended and why.

A change's artifacts — its proposal, its design, its specification deltas,
its task list — are the record of intended behavior and the decisions behind
it. They are read before implementation, not written after the fact to
describe what was already done.

Review is dispatched against the complete set, never against a package still
being written: a reviewer given half a package spends its round reporting
absent sections rather than defects, and a round that establishes only "this
is incomplete" is one spent, not one passed. Complete means every artifact
the change calls for exists — an artifact a change legitimately does not
have does not make its package incomplete.

Before any code is written or applied, the change must be independently
reviewed, then revised and re-reviewed until the reviewer's verdict permits
proceeding. Where a verdict permits proceeding only conditionally, the
conditions it names are applied before proceeding — a conditional pass is
not an unconditional one, and applying conditions of that kind does not
require a further review round.

The revise-and-re-review loop is bounded. Beyond an initial review and five
automatic re-reviews, do not dispatch a further round unasked: report where
the loop stands, what is still outstanding, and ask before continuing. A
loop that has not converged in six rounds is rarely one round from
converging, and an unbounded loop spends the reviewer against a change no
one has looked at since it started.

Where the reviewer judges the change's concept unsound rather than its
artifacts defective, that is not another revision round at all: stop and
raise it immediately, whatever the count stands at, because no amount of
rewriting the artifacts answers it.

An approved plan is committed before tests are derived from it. The commit
fixes the baseline those tests map to; where the specification deltas keep
moving while tests are being written against them, the mapping goes stale
with nothing reporting it. Per the commit rule below, suggest that commit
rather than making it unasked — and where it is declined, report that the
next step is blocked on it and stop there, rather than proceeding without
it.

_Claude Code binding:_ once `proposal.md`, `tasks.md`, every delta spec, and
`design.md` where one is written are complete, dispatch
`ai-toolkit:openspec-change-reviewer`. On `CHANGES REQUIRED`, revise the
artifacts and re-dispatch, up to the five automatic re-reviews the bound
above allows. On `PROCEED WITH CHANGES`, apply the `[MINOR]` fixes it lists
— that verdict is permission conditional on them — and continue without a
further review round. On `PROCEED`, continue. On `REJECT`, stop and raise
it.

## Test design before implementation

Before implementing a change with behavior that tests can be derived from,
have an author other than whoever writes the implementation derive tests
from that change's approved specification deltas — not from implementation
code. Two processes that see only the implementation share its blind spots;
a test author with no sight of the implementation does not.

Where this project's rules, or a procedure or specification they defer to,
state an exemption from test authoring for a named class of change, that
exemption applies. It applies by having been stated in advance, not by being
decided at the gate, and the reason is stated when it is used. A change that
declares it carries no specification deltas has none to derive from and owes
no new tests; what it owes is that the existing suite stays green. Deltas
that are merely unwritten are not that declaration — an absence found at the
gate is the gap this rule forbids, not an exemption.

Test authoring is dispatched only against a plan that has passed review and
been committed — never against artifacts still being written, and never
ahead of review. A test derived from a specification the review has not yet
cleared encodes whatever defect that review would have caught.

_Claude Code binding:_ dispatch `ai-toolkit:openspec-test-writer` only after
the reviewer's verdict permitted proceeding, any conditions it named were
applied, and the approved plan was committed — and strictly before applying
changes or implementing code.

## Implementation and execution

Only after the specification has passed review, and the tests it calls for
have been derived from its specification deltas, may the change be applied
and implemented in code.

Three things are checkable before implementation begins: a review verdict
that permitted proceeding, a commit holding the approved plan, and the tests
derived from that plan — or, in place of those tests, the stated exemption
that excused them. Where any of the three is absent and no stated exemption
covers it, take the missing step first rather than starting implementation
and noting the gap.

## Verification before any completion claim

Implementation existing is not the same as a change being complete. Run the
verification relevant to the change — tests, type checking, linting,
formatting, a build, or whatever else the project's conventions require —
and do not report a change as complete without having run it.

## Independent review before completion

Verification establishes that a change does not fail. It does not establish
that the change is the one its specification asked for. After implementing a
change, have an independent reviewer read the diff against the change's own
specification before the change is called complete. That reviewer checks
that each requirement is implemented, that the implementation matches what
the specification describes rather than something adjacent to it, that the
tests derived from the specification deltas cover the behavior that actually
changed, that no unrelated scope was introduced, and that the project's
conventions were followed.

This review reads code; the review that gates implementation reads plans.
They are separate obligations and neither substitutes for the other — the
earlier one asks whether the plan is sound, this one asks whether the code
is that plan.

Dispatch it against a diff that already passes verification. A reviewer
handed a change whose tests fail spends its round on the failure, which
verification had already reported.

_Claude Code binding:_ run `/code-review` over the change's diff before
treating the change as done. Do not use
`ai-toolkit:openspec-change-reviewer` for this role — it reviews a change's
planning artifacts and explicitly not the code that follows them.

## Small, reviewable commits

Prefer small, focused commits that represent a complete, meaningful unit of
work, over large commits bundling unrelated concerns. After a meaningful
milestone is reached, proactively suggest creating a commit rather than
waiting to be asked.

Before committing: look at the diff being committed, run the verification
relevant to what changed, and check that no secret or unintended file is
included. Suggest the commit; do not make it without confirmation.

## Incremental development and scope control

Prefer changes small enough to review in one sitting. Where a change grows
to cover multiple independent concerns, or grows too large to review as a
unit, consider splitting it into separate changes instead.

Implement only what belongs to the change currently in progress. An
improvement noticed along the way, that is not part of that change's stated
scope, becomes a separate proposed change rather than being folded in.

## Requirements and assumptions

Do not silently invent a requirement that was not stated and cannot
reasonably be inferred. Where an important decision cannot be inferred, ask
rather than guess.

Record significant decisions in the project's own artifacts rather than
relying on them surviving only in conversation history — a decision that
exists only in a conversation is not available to whoever reads the project
next.

## The repository is the source of truth

Do not rely on earlier conversation context for information the repository
itself can supply. Prefer reading a file, a spec, or a commit over recalling
what a previous exchange said about it — the repository does not go stale
the way a remembered conversation does, and it is what the next person, or
the next session, will actually see.
