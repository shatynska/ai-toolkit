## Context

`rules/development-workflow.md` is a `standing-constraint` fragment inlined
verbatim by `scripts/project-init` into a consuming project's `AGENTS.md`,
between markers carrying its `version`. It is the only asset in this library
whose text becomes an instruction another agent follows in a project that
may not have the library installed. See `proposal.md — Why` for what v1 fails
to prevent.

Two constraints shape everything below:

- **The existing `project-bootstrap` requirement "The workflow rules name a
  role before naming a tool".** Anything harness-specific — an agent name, a
  verdict token, a slash command — belongs in a binding paragraph, never in
  the sentence stating the obligation.
- **`scripts/project-init` never rewrites an existing managed block.** It
  reports version skew and stops. A fragment edit therefore reaches new
  projects only; existing ones keep the version they adopted.

## Goals / Non-Goals

**Goals:**

- State the fragment's obligations as an order, not a set, and give each
  gate a precondition an agent can check rather than judge.
- Correct the misbinding of `ai-toolkit:openspec-change-reviewer` to a
  post-implementation review it explicitly declines, and restore that review
  under a binding that can actually perform it.
- Bound the revise-and-re-review loop.
- Record these as `project-bootstrap` requirements, so the next edit to this
  fragment is checked against them rather than against this change's memory
  of them.
- Give the fragment's version-increment rule a single owner. It is currently
  stated by `toolkit-structure` in whole-file terms and needed here in
  body-scoped terms; two capabilities answering the same edit differently is
  the defect, not which one answers.

**Non-Goals:**

- Propagating v2 into projects already carrying the v1 block. Out of scope
  per `proposal.md — Impact`; it needs its own decisions about hand-edited
  blocks and its own spec surface.
- Persisting the review-loop count anywhere durable. See Risks.
- Any change to `scripts/project-init`'s behavior. This change edits the
  fragment the script reads and the specification governing that fragment's
  content; the script's own logic is untouched.

## Decisions

### The fragment's v2 body is normative here, not paraphrased

The complete body is reproduced at the end of this document. A fragment
inlined verbatim into other projects is the one artifact where "the design
describes the intent and the implementation supplies the words" fails: the
words *are* the behavior. Reviewing a paraphrase would review something no
project will ever read.

### Review moves from post-implementation to a gate on implementation

*Alternative considered:* keep v1's post-implementation placement and fix
only the binding. Rejected — the agent v1 names reads `proposal.md`,
`design.md`, `tasks.md` and the delta specs and returns a recommended action
on the plan. Its useful moment is before implementation, not after. Keeping
the placement and swapping the agent would discard the pre-implementation
review entirely, which is the one this change most needs.

Both reviews are kept, because they answer different questions: the earlier
asks whether the plan is sound, the later whether the code is that plan.
Collapsing them into one would drop whichever question the surviving
reviewer does not ask.

### The post-implementation binding names an excluded tool as well as the right one

*Alternative considered:* name `/code-review` and say nothing about the
wrong agent. Rejected — the role description ("an independent reviewer
checks the change against its specification") matches
`ai-toolkit:openspec-change-reviewer` closely enough that an agent reading
the role in a repository shipping that agent will reach for it. That is
precisely the mistake v1 made in writing. Naming the exclusion, with the
reason drawn from the excluded agent's own description, is what stops the
role from being re-filled wrongly.

This generalizes into the MODIFIED requirement: a binding may exclude as
well as name, and must say why.

### The loop bound is one initial review plus five automatic re-reviews

*Alternatives considered:* five dispatches total; unbounded; a stall
detector that stops when the same issue survives two rounds.

Five *re*-reviews (six dispatches) is the reading of the requester's
instruction that matches its wording — the cap is on restarting review, and
the initial review is not a restart. The off-by-one is resolved explicitly
in the fragment's own words ("an initial review and five automatic
re-reviews") rather than left to a reader's arithmetic, because a rule an
agent has to count off-by-one correctly is a rule that will sometimes be
counted wrong.

The stall detector was drafted and then removed. It would have fired at
round two in most real loops, making the five-round cap unreachable and
therefore dead text. Two counters with different trigger conditions in one
instruction is worse than one countable number: an agent applies whichever
it read most recently. If a stall detector is wanted later it should replace
the count, not sit beside it.

`REJECT` exits rather than consuming a round, because it is defined outside
the reviewer's severity mapping — it is never reached by accumulating
issues, so revising and re-dispatching cannot answer it. Without this the
bound would be spent on rounds that structurally cannot succeed.

### The bound is stated in the role, the verdict tokens in the binding

`PROCEED`, `PROCEED WITH CHANGES`, `CHANGES REQUIRED` and `REJECT` are
vocabulary owned by `agents/openspec-change-reviewer.md`. They are
harness-specific and stay in the binding. The *shape* they describe — a
verdict permitting proceeding, a verdict permitting it conditionally, a
verdict requiring revision, a verdict no revision answers — is stated in the
role in harness-neutral terms, so the rule survives a project that reviews
by some other means.

The bound itself sits in the role rather than the binding for the same
reason, and this is recorded as a requirement: an unbounded loop is most
expensive exactly where the binding is unfamiliar.

### The commit before test authoring is *suggested*, not made

The fragment's own "Small, reviewable commits" section says "Suggest the
commit; do not make it without confirmation." Writing "and commit" into the
new gate would put two rules of the same document in contradiction, which
lets an agent follow whichever it prefers and cite the document either way.
The new gate defers to the existing rule by name.

The commit is required at that point rather than merely allowed because it
fixes the baseline `openspec-test-writer`'s `test-manifest.md` maps
scenarios to. A mapping written against specification deltas that continue
to move goes stale with nothing reporting it.

### Verification precedes the post-implementation review

Symmetric with the precondition on the pre-implementation review: a reviewer
handed a diff whose tests fail spends its round re-reporting what
verification already said. The fragment states the ordering explicitly
("Dispatch it against a diff that already passes verification") rather than
leaving it to section order, per the ADDED requirement that a gate name an
observable; the section order agrees with it and is not what carries it.

### Tests read the version from the fragment instead of asserting `1`

Three cases assert the literal `v1` / `version 1`. They test block
placement, self-location and skew reporting — none of them tests *which*
number the fragment carries. Left as they are, every future fragment edit
breaks three tests for a reason unrelated to what any of them covers, which
trains the next author to edit assertions rather than read them.
`managed-block-older-version.sh` keeps a hardcoded *older* number, since a
fabricated older version is the fixture that case exists to construct.

### `/code-review` is a harness-provided binding, and that is why it is one

Every other binding in the fragment names an asset this library ships.
`/code-review` does not: it is a Claude Code built-in skill, not an
`ai-toolkit` asset, and nothing under `agents/` or `skills/` defines it.

That is the correct binding rather than a gap. The role needs a reviewer
that reads a diff; this library ships no such asset, and inventing one to
satisfy a symmetry with the other bindings would add an agent to justify a
sentence. The binding paragraph is where a harness-specific name belongs,
and the fragment's own framing — "where this project uses Claude Code, names
the binding for that role beneath it" — already scopes it to that harness.

The asymmetry with the *negative* binding is deliberate. This change's
MODIFIED requirement obliges an exclusion to rest on the excluded tool's own
contract, because an exclusion a reader cannot check is indistinguishable
from a preference. A positive binding carries no such obligation: it either
resolves in the harness or it does not, and the role above it stands either
way.

### A declined commit blocks the next step rather than being worked around

The commit gate sits between two rules that could otherwise deadlock: tests
must be derived from a committed plan, and commits are suggested rather than
made. Where the suggestion is declined, neither rule tells an agent what to
do, and an undefined branch in an instruction document is one an agent
resolves by preference.

The fragment states it: report that the next step is blocked on the commit
and stop there. Stopping is correct rather than merely safe — a declined
commit is usually a signal the plan is not settled, which is exactly when
deriving tests from it wastes the derivation.

### The version-increment rule gets one owner, named in both capabilities

`openspec/specs/toolkit-structure/spec.md` already holds "`version` … increments
when its text changes", inside a requirement stating that its form "is fixed
here". This change's added requirement is body-scoped and forbids an increment
for a frontmatter-only edit — so for exactly that edit the two would give
opposite answers. One numeric rule held in two capabilities is one an edit to
either silently falsifies.

*Alternatives considered:* (a) move the requirement into `toolkit-structure`;
(b) drop it and rely on the sentence already there.

(b) is rejected on this change's own Goals — the existing sentence is
whole-file scoped and does not say what the skew report needs said. (a) is
defensible, since increment discipline is an authoring property; it was
rejected because the *reason* the increment matters belongs to
`project-bootstrap`: the version exists to distinguish a project's inlined copy
from a current one, and only the capability that inlines the fragment can say
which part of it a project actually carries. Separating the rule from its
rationale is what produced the duplication in the first place.

`project-bootstrap` therefore owns the increment condition; `toolkit-structure`
keeps the frontmatter's form and defers the condition to it by name; each says
so explicitly. There is precedent for the placement: `project-bootstrap`
already owns a content constraint on this same fragment ("The workflow rules
name a role before naming a tool").

### Carried sections are reproduced byte-identically, not rewrapped

The five sections v2 does not change — `Verification before any completion
claim`, `Small, reviewable commits`, `Incremental development and scope
control`, `Requirements and assumptions`, `The repository is the source of
truth` — together with the fragment's opening paragraph, are copied from v1
byte for byte. New and rewritten sections are wrapped at v1's own maximum of
76 columns.

*Alternative considered:* rewrap the whole fragment uniformly. Rejected —
rewrapping a carried section changes every line of it, so in every consuming
project's diff a reflowed line is indistinguishable from an edited one, and
task 5.1's diff review has to re-read five sections nothing intended to
touch. The transcription is verified mechanically rather than by eye, since
"byte-identical" is not a property reading catches.

### The exemption path is stated in advance, never decided at the gate

`openspec/specs/project-foundation/spec.md` records a `SHALL`-level
exemption: the foundation change cannot have tests derived from it, because
test authoring needs the test command and test-path locations that the
foundation change itself produces. `openspec/specs/change-test-authoring/spec.md`
adds a second case — a change with `skip_specs: true` has no deltas to
derive from and owes only that the existing suite stays green.

v1 accommodated both through the words "a change **with testable
behavior**". The draft this change started from dropped that qualifier while
compressing the sentence, which would have made an unsatisfiable gate the
first thing a newly bootstrapped project meets — `rules/project-foundation.md`
is a `procedural-checklist` and is *not* inlined, so an agent reading only
`AGENTS.md` would have no sight of the exemption at all.

*Alternative considered:* inline the foundation exemption into the workflow
fragment. Rejected — `AGENTS.md` (this repository's conventions) rules out
inlining a procedural checklist precisely because it would leave permanent
instructions about a one-time change in a standing-constraint document.

The repair keeps the gate in observable form and makes the *set* of
preconditions conditional instead: tests are required where the change has
behavior tests can be derived from and no exemption stated in this project's
rules applies. An exemption stated in advance is a decision recorded where
the next reader finds it; a gap noted at the gate is a judgment made by
whoever happened to arrive there. The delta spec distinguishes the two
explicitly, because the ADDED requirement's "halts rather than annotates"
scenario would otherwise forbid the exemption path along with the gap.

### Author independence stays in the role, not the binding

v1's role sentence required tests be derived "by an independent author …
not written by whoever writes the implementation". The draft compressed this
to "the test author operates strictly from the specification deltas", which
leaves independence carried only by the Claude Code binding that happens to
dispatch a separate agent.

That is the exact failure this change's own ADDED requirement argues
against: a project filling the role by other means reads only the role
sentence, and nothing there would stop the implementer writing the tests.
The clause is restored to the role. No trade-off was found against it; the
compression appears to have been incidental to rewording rather than a
decision, and it is recorded here so it is not re-compressed later.

## Risks / Trade-offs

**The loop count exists only in the agent's conversation.** Nothing records
that four rounds already happened. A compacted context, or a fresh session
resuming the change, restarts the count at zero silently. → Not mitigated,
deliberately. The alternatives — writing a counter into the change's
artifacts, or into a state file — add a durable mechanism to a document
whose whole delivery mechanism is inlined prose, and the failure they
prevent (a loop running eleven rounds across two sessions instead of six)
is bounded and visible in a way an unbounded loop is not. Recorded here so
the next author does not rediscover it as a defect.

**Three projects stay on v1 and now diverge from the library's stated
workflow.** `commerce-ops`, `commerce-ops-product-dossier` and
`infrastructure` carry the v1 block. After this change the library
prescribes a workflow those projects do not carry, and
`scripts/project-init` will report the skew without resolving it. → Accepted
and stated in the proposal; the follow-on block-updating change is the
mitigation, and until it exists the skew report is the honest signal.

**The fragment grows by roughly half.** Longer instructions are skimmed
more. → Partly mitigated by keeping every added sentence load-bearing: each
new paragraph either states a precondition, states a bound, or states why a
rule is the shape it is. No added sentence merely restates another. The
trade-off is accepted because the failures being prevented are silent ones,
and a rule that is not stated is not skimmed either — it is absent.

**A negative binding can become stale.** The exclusion of
`ai-toolkit:openspec-change-reviewer` from the diff-review role rests on
that agent's own description. If the agent's scope ever changes, the
fragment states something false in every project carrying it. → The
requirement added here obliges a negative binding to rest on the excluded
tool's own contract, which makes the dependency explicit and checkable
rather than incidental.

## Migration Plan

No runtime migration; the change is text plus tests.

`tasks.md` is the authoritative scope list; this is the shape of it.

1. Rewrite `rules/development-workflow.md`'s body; set `version: 2`.
2. Decouple the four version-coupled test cases from the literal version,
   and add the new cases this change's requirements call for.
3. Update `tests/coverage.md` for the 13 added scenarios and `rules/README.md`
   for the narrowed version rule.
4. Run `bash tests/run.sh` and `openspec validate --strict`.
5. Both delta specs reach `openspec/specs/` at archival, not by hand.
6. New projects initialized after this lands receive v2. Existing projects
   are untouched and report skew, as designed.

Rollback is `git revert` — the fragment is read at run time from the working
tree, so reverting the file restores v1 behavior with no other action.

## The v2 fragment body

Normative. `scripts/project-init` strips the frontmatter and inlines
everything below it verbatim.

```markdown
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
```
