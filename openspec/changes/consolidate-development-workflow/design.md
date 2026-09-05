## Context

See `proposal.md` — Why.

`scripts/project-init` inlines one hardcoded fragment's body into `AGENTS.md`
under a managed block. That is the only mechanism putting a fragment into a
project, and it is why the workflow fragment is in force in three projects and
the session fragments in none.

`session-workflow` currently governs three fragments and requires each to be
adoptable without the others. `project-bootstrap` separately governs the
workflow fragment — how it reaches a project, its version, the ordering of its
gates and the bound on its dispatch loops.

## Goals

- The session obligations reach a project by the path that already works.
- One text per rule, so a change to a rule is made once.
- A change's stage readable by a session that was not there — from the
  repository where the repository holds the fact, and by asking where it does
  not. Decision 6 withdrew the stronger form, that every stage be derivable.

## Non-Goals

- `scripts/project-init`, `tests/` beyond repairing what this change breaks, and
  `project-bootstrap`. The variant selection and the second managed block are
  `add-session-workflow-tooling`.
- A publication for projects that do not deploy. See decision 3.
- Reclaiming a session's database. `add-namespace-reclamation` owns it; v3 names
  the gap inline as `worktree-isolation.md` does today.

## Decisions

### 1. One document, and the three fragments removed rather than kept

The three are independently adoptable, and that is what makes them long: each
restates shared context, states every gate self-containedly, and carries
conditionals for project shapes that may adopt one and not another.

Consolidating removes that cost entirely. What it gives up is à-la-carte
adoption, which nothing has ever exercised — no project adopted any of the
three, because nothing could install them.

**They are removed rather than kept as a superseded alternative.** Kept, every
future rule change is made twice; and the two texts already disagree about where
the archive commit goes, so the drift is present rather than prospective.

**Alternative rejected: keep them and mark v3 primary.** It preserves work
already reviewed, and buys a property with no consumer at the price of a
permanent double-maintenance obligation on a library maintained by one person.

### 2. `session-workflow` survives, retargeted; the seam with `project-bootstrap`
is stated

Both capabilities now bear on one file, so ownership must be explicit or the
next change will amend the wrong one.

- `project-bootstrap` owns **how the workflow rules reach a project and what
  shape they take there**: the managed block, the version and its increment
  condition, that a role is named before a tool, that the gates form an ordered
  sequence with checkable preconditions, and that an automatic dispatch loop is
  bounded.
- `session-workflow` owns **what the session-derived rules say**: the branch and
  working tree, provisioning, the report and its vocabulary, delivery, teardown,
  and work that outlives the session. Where `project-bootstrap` requires that
  something exist without fixing its value — a bound on a dispatch loop, say —
  this capability may fix the value for a loop it states.

**Consolidation makes one inherited permission illegal, and it is dropped rather
than carried.** `change-delivery.md` was permitted to name the specification
tooling directly instead of stating a role, because `project-bootstrap` does not
govern that file. It governs `rules/development-workflow.md`, and requires there
that every obligation be stated as a role, permitting — never requiring — a tool
named beneath it, and forbidding one in the role sentence. So v3 states the archive step as a role, as it already does for
its review dispatches. **The same rule catches a second inherited permission**, and it is worth naming
because the two look unrelated: `worktree-isolation.md` fixed a change's working
tree at `.claude/worktrees/` — a harness's own directory, sitting in the rule
sentence. That was legal there for the same reason the tooling name was legal in
`change-delivery.md`, and it stops being legal on the file `project-bootstrap`
governs. So v3 fixes `.worktrees/` as the rule's path and names
`.claude/worktrees/` beneath it as Claude Code's binding.

These are the kind of defect consolidation creates rather
than inherits, and they are why the seam had to be written down before the merge
rather than after.

**Alternative rejected: remove `session-workflow` and move everything into
`project-bootstrap`.** One owner for one file is tidier, but `project-bootstrap`
is about bootstrapping — it would then own the substance of rules that have
nothing to do with initializing a project, and the capability's own purpose
statement would stop being true.

### 3. v3 assumes a remote, pull requests, CI and a deploy — no conditionals

Every project this library is written for has all four. The forge is not among
them as a fifth item, and that is deliberate: pull requests imply it, and
teardown's merge clause is where what it must report gets stated — a pull
request's merged state, the only merge evidence that survives a squash or rebase
merge. Naming it in the assumptions as well states twice what one clause states
once. The conditionals for
their absence are exactly the class of text that made the three fragments
expensive: `where the project has a remote`, `a project that runs sessions
serially`, `the gate is checkable without a delivery fragment`.

This repository does not deploy, and is deliberately **not** a consumer of its
own workflow fragment — its `AGENTS.md` carries no managed block. So v3's
assumption creates no contradiction here; it makes explicit what was already
true.

Should a library-shaped project need these rules, it gets its own publication
rather than a conditional in this one. A second publication is cheap and can be
written when there is something to write it for; a conditional is paid for by
every reader of every project, forever.

**This is the reverse of the reasoning in decision 1, and deliberately.** Two
publications of one rule set are a cost worth avoiding where both would be
maintained; they are worth paying where one of them does not yet exist and may
never.

The asymmetry has a boundary, and the specification now states it: the moment a
second publication *is* written, decision 1's argument applies to that pair in
full. So `session-workflow` owns it alongside the others and states each shared
obligation once, naming which publications it binds — the arrangement already
holding for the workflow fragment and the binding fragment. Anticipating a
second publication is not the same as having somewhere for it to live.

### 4. The database is a binding, not a section

v3 states service-neutrally that a working tree carries tracked files only, that
verification which cannot reach what it needs skips rather than fails, and that
a session takes its own namespace in any shared service its verification writes
to. `rules/development-workflow-database.md` binds those to a containerized
Postgres.

This is the pattern v3 already uses for Claude Code: state the role, name the
binding beneath it. It keeps the binding small — the running container, a
database per working tree, migrate-is-not-seed, and the affordance below — and
lets a project on another stack replace one file rather than edit v3.

Until the tooling change, the binding is pasted by hand beneath the block.

### 5. The database is stated as an affordance before an obligation, and the
order is normative

The observed failures are of two kinds, and only one has a defensive form:

| observed | what catches it |
|---|---|
| "Docker isn't available in this WSL setup", container up the whole time | check before concluding |
| no `DATABASE_URL` in the worktree, tier skipped | provision before relying |
| tier skipped, `pre-push` reported `Passed` | a skip is not a pass |
| two sessions in one database, failures reading as defects | a database per working tree |
| reaching for a double or a lighter engine rather than the real one | **the affordance** |

A fragment that only warns the database is hard to reach leaves a session free
to substitute something reachable and violate nothing it says, while proving the
code works against something other than what production runs. So the fragment
states first that a real database is running and that integration tests run
against it, and only then what must be provisioned before a result means
anything.

### 6. Three stage families, generative, and no ledger behind them

The report exists to be read by a session that was not present. Prose is
re-interpreted at every hand-off; a name from a closed set is read once. A
stage names a state, never an act — an act is what someone did, which a
resuming session cannot read off the repository.

Three families rather than two, because `ship:` is where a session *waits*, and
the only actionable content of a waiting state is which one it is.

**The transitions are the closed set and the states derive from them**, so the
fragment states a rule and examples rather than nineteen names. An enumeration
beside a generating rule is a second source that drifts from the first.

**Decision: nothing requires that every stage be derivable, and no ledger is
mandated to make one so.** An earlier draft required both, and built
a named ledger to hold eight kinds of record — dispatches, verdicts,
dispositions, operator confirmations, waivers, blocks, abandonments and pull
requests — with commit rules for the four that arrive when no further commit is
coming. Two review rounds went into it.

It was over-built, and the operator's question is what showed it: the stage is
reported for their information, so a stage that is one step off costs a sentence
of correction. Six of the eight records were bought to make the stage exactly
derivable, and that precision buys nothing anyone depends on.

One record survives because it gates a decision rather than a report: **the
production-confirmation waiver**, which the archive proceeds on and which is the
only trace of why the trunk's specification describes behavior production does
not have. It goes to the change's own artifacts, needing no named ledger. The
abandonment record is a second, already obliged by the teardown gate as its own
second route.

**The review verdict went too, and it is the closest call here.** It looks
load-bearing, because the implementation gate checks that a review permitted
proceeding. But the rules already require the approved plan to be committed
before tests are derived from it, so the commit is that marker; a separate
record states the same fact twice, and a session could write a false one as
easily as it could commit an unapproved plan. What the record buys is the
occasional re-dispatched review, which returns the same verdict.

`ship:waived` went with it, but the gap it was patching is real and outlives
derivability: the report obligation stands, and a session that has just recorded
a waiver still has to name a stage. An earlier draft patched it by saying a
recorded waiver "satisfies `ship:confirmed`" — reporting a state that is not
true so the change could move on.

**The fix is to define the transition rather than to patch the state.** `confirm`
completes on the operator's confirmation *or* a recorded waiver, because those
are the two ways the gate is passed and the delivery sequence already closes the
record on either. `ship:confirmed` is then true of a waived change, and no
name is owed. A state whose transition has genuinely completed is not the same
thing as a state asserted to have been reached.

### 7. A change keeps one branch, brought back to the trunk after each merge

Delivery merges a change's branch more than once — the work, then the record —
so a session needs somewhere to put the record's commit. The obvious answer is a
second branch, and three review rounds were spent on where to cut it from, what
teardown covers when a change holds several, and how a later session enumerates
a set it did not create.

**Decision: a change keeps one branch, and it is brought back to the freshly
fetched trunk after each merge before work continues on it.** The remote branch
is deleted on merge and the local one survives, so reusing it costs nothing; the
property the multi-branch rule was actually buying — *start from the trunk* —
is kept, since returning to the trunk is what stops the record's pull request
re-presenting the work diff under a squash or rebase merge, and what keeps the
archive applying to the specifications as they now are.

The branch is also rebased onto the trunk periodically while the change is in
progress, not only when it is cut: a change spanning several sessions otherwise
first meets the trunk at its pull request.

**What this deletes** is the reason to record it here: a whole requirement, the
branch records, teardown's coverage of a branch set and its
enumeration, the reconciliation between the one-branch rule and delivery, and
the proposal-only-branch exclusion — roughly 35 lines of a file every session in
every adopting project reads. Three of the plan review's majors and one
code-review high lived in that apparatus; the complexity was generating the
defects rather than answering them.

**The invariant is the change's, not the session's.** A change outlives the
sessions that work on it, which is what the orientation report exists for, so
binding branch and working tree to the session would let a change acquire
another of each whenever a new session picked it up. Sessions on one change run
one after another, never concurrently — concurrent ones would share a working
tree.

**Alternative rejected: a second branch cut from the trunk.** Correct, and what
this change carried through six review rounds. It buys nothing the reuse does
not, and costs the enumeration machinery above.

### 8. A healthy deploy is not the change working

Deploy-healthy → record treats the deploy's health as the change's success, and
they fail separately: a deploy reports that new code is running, and nothing
about whether the behavior the change existed to produce is the behavior
production now has.

This is also why the pull-request count is a floor rather than a fixture. Both
failure branches produce work, and work reaches the trunk through a pull
request; a sequence written as exactly two leaves a session that has just merged
a fix with no stated position, since the record's slot is spent. The record's
pull request is the last one, however many the change took.

So a gate sits between them. The change's purpose is that effect; recording
delivery before observing it records an intention.

A session usually cannot make the observation — production is reached through
interfaces it does not hold. The obligation is therefore to **propose how to
observe**: what to look at, what provokes it, what result means it worked.

**The gate needs an exemption, stated in advance and by class, or it forecloses
an ordinary class of change.** A refactor, a dependency bump or an internal
cleanup has no externally observable effect, so it can never answer "what would
we look at". With no exemption, its record is never written — and teardown is
conditioned on the record's pull request having merged, so its branch and
working tree become unremovable. That is the accumulation the teardown rule
exists to prevent, reached by a change that did nothing wrong.

So: where the session can propose no observation it says so plainly and names
the class, the operator waives the gate, the waiver is recorded in the change's
artifacts, and the record rests on the waiver. Stated in advance for a named
class rather than decided at the gate — the form `project-bootstrap` already
requires of every precondition this fragment states.

Saying so plainly survives the exemption. What the exemption removes is the
stall, not the disclosure.

A healthy deploy with the effect absent does not automatically re-enter the fix
loop. It may be a defect, or the change may have been the wrong change, which is
a new proposal rather than a correction.

**Each of those needs a terminal, and the wrong change had none.** A defect
re-enters at the review gate. The wrong change could not: the record needs a
confirmed effect it will never get; the first waivable class does not cover it,
because an observation *was* proposed and made, and improvising an exemption at
the gate is what stating exemptions in advance forbids; and the abandonment
route cannot be used, because its record must assert the work is not wanted and
this work is merged, deployed and running. A compliant session would stop
holding a branch set and a working tree no route can remove.

**Decision: the wrong change is the confirmation gate's second waivable class**,
named in advance on the same terms as the first — a change whose observation was
made, whose effect is absent, and which is not to be corrected in place. Being
superseded by a new proposal is the typical case and is deliberately **not** a
defining condition: a change judged wrong and reverted, or simply dropped,
satisfies the class as fully, and a definition requiring a successor would leave
it in neither class and back at the dead end this exemption exists to close. Same disclosure, same recorded waiver, same route to the
record.

**Alternative rejected: route it to abandonment.** Cheaper to state, but the
abandonment record must assert the work is unwanted, which is false for merged
and deployed work — and it would leave the change directory unarchived on the
trunk with its abandonment recorded only on branches teardown deletes.

The record stays truthful on this route: the change shipped, and what shipped
did not do what was wanted. That is worth having on the trunk rather than losing
with the session that found it.

### 9. The report is a fixed row, and it bookends the session

A row in a known shape is read at a glance and a missing cell is visible as a
gap; a paragraph is re-parsed every time.

Entering and stopping are one obligation seen from two ends. They differ in one
cell: the entering report carries the verification result, because that is what
a session arriving does not know and a session leaving does — and because,
arriving, it must come from a real run made after provisioning or be reported as
*not run, and why*.

### 10. An identified change is opened with a handoff, not a proposal

A session that identifies a change it will not work on may open it on a branch
of its own. What it puts there was a `proposal.md`, and that is wrong twice: a
proposal is the artifact the workflow reviews before anything is built, so one
written in passing draws a review round it has not earned; and it is a formed
document, which a session with no time for it either writes badly or does not
write at all.

**Decision: the identified change carries a `handoff.md` and no proposal.** It
holds what the originating session knows and the next will not — why the change
was identified, what the originating work established that bears on it, and what
it must not undo. The session that takes the change up writes the proposal, with
the handoff as input.

This is not a lighter proposal. A proposal states what will be built and is
reviewed; a handoff states what was learned and is read. Naming them apart is
what stops the second being treated as the first.

**Alternative rejected: `brief.md` or `notes.md`.** Both read as a proposal in
draft, which invites exactly the treatment the decision exists to prevent.

### 11. The change queue is a separate artifact from the deferred-work file

`docs/deferred-work.md` exists in this repository and in `commerce-ops`, holding
what the project deliberately has not done, deleted when it stops being true.
`commerce-ops` grew `docs/proposed-change-order.md` separately for identified
changes, deleted when the change is archived, and states the split in its own
words.

They cannot share a file: one entry is swept on being fixed and the other on
being shipped, so an entry in the wrong one is deleted early or kept forever.

**Decision: `docs/change-queue.md`**, with the path fixed in the specification
for the reason `.worktrees/` is fixed — a path stated only in a change's
artifacts is archived with them, and a requirement whose subject is then
unnameable cannot be checked afterwards.

**Alternative considered: adopt `commerce-ops`'s `docs/proposed-change-order.md`.**
More precise and already populated; longer, and inherited by every project.
Rejected because the fragment is written for projects that have never seen one.
Reversible — a path in one fragment and one requirement.

### 12. The vocabulary is aligned with OpenSpec's, and the renames ride here

`handoff.md` surveyed what the wider OpenSpec ecosystem calls the things this
change names. Four of its findings are adopted and one is declined.

**Adopted.** `apply` replaces `doing` as the `build` transition, because `apply`
is the ecosystem's most load-bearing verb — `/opsx:apply`, the
`openspec-apply-change` skill, `openspec instructions apply`, `applyRequires`,
the `apply:` block every schema carries — and `doing` names no operation.
`archive` replaces `record` as the last `ship` transition, because `archive` is
unambiguous across the CLI, the skills and the `openspec/changes/archive/`
directory, while `record` is also a plain verb this fragment uses several times,
in the one document where a stage name has to be unmistakable. The
test-authoring artifact becomes `test-plan.md` and the review verdicts become
`APPROVED` / `CONDITIONALLY APPROVED` / `FIX REQUIRED` / `REJECTED`, both to
match names a forked schema already declares.

**Declined: `build:review` → `build:code-review`.** The collision is real —
everywhere else in the ecosystem, and in `plan:review` here, "review" means a
read-only pass over artifacts before code exists, and a session reading an
unqualified `review` can dispatch the reviewer that refuses a diff. But the
fragment already answers it more cheaply, by requiring the family prefix always
be written and saying why: `plan:reviewing` and `build:reviewing` dispatch
different reviewers. Qualifying one member of a generated set would also break
the generation rule decision 6 rests on — the transitions are the closed set and
the states derive from them — for a disambiguation the prefix already carries.

The `PROCEED WITH CHANGES`-has-no-stage gap the handoff names closes with the
verdict rename rather than a new stage: `CONDITIONALLY APPROVED` says what it
is, and the fragment states that such a pass is permission conditional on the
fixes it names, applied without a further round. That sentence is v2's, carried
forward unchanged under task 1.3 rather than written here, and it is obliged by
`project-bootstrap`, not by this capability — its bounded-dispatch-loop
requirement obliges the fragment to state a loop's exits, and a pass conditional
on named fixes is one. So the gap closes against a requirement that holds over
v3, rather than against text nothing binds.

**They ride with this change rather than following it** because every affected
word is uncommitted here. Renaming now is a substitution; renaming after the
archive costs a `MODIFIED` delta against a published specification plus archived
history written in the superseded words. The same argument carries the two agent
renames — `openspec-change-reviewer` to `change-plan-reviewer`,
`openspec-test-writer` to `change-test-writer` — which additionally drop a prefix
naming the tool rather than the work, and which collided with the OpenSpec
skills installed under `.claude/`.

**This widens the change, and that is the cost.** The alternative was a rename
change of its own, which would have been the tidier scope and is what
`design.md`'s Non-Goals would otherwise imply. It was rejected on the
cheap-now-expensive-later argument above, and the widening is bounded: both
renames touch filenames, verdict tokens and agent names, and no obligation.

## Risks / Trade-offs

- **v3 is roughly twice v2 and is always in context.** → It is far smaller than
  v2 plus the three fragments, because the independence conditionals are what
  cost most. The vocabulary also removes prose: a named stage replaces a
  sentence describing where things stand.

- **Three projects hold the `v1` block and nothing updates them.** → Pre-existing
  and owned by `update-managed-block`. This change widens the gap and does not
  create it.

- **Removing three fragments discards work that passed six review rounds.** →
  The reasoning survives in the requirements, which are retargeted rather than
  rewritten. What is discarded is the conditionals, which is the intent.

- **One record lands in the artifacts of a change whose gate is waived.** → It
  gates a decision a later session must make. An earlier draft required seven more, to make the
  stage exactly derivable; they went with the derivability requirement.

- **The production-confirmation gate rests on an operator waiver that could be
  given reflexively.** → It is recorded in the change's artifacts with the class
  named, so a change archived on a waiver says so permanently and a pattern of
  them is readable. The alternative — no exemption — forecloses refactors
  entirely.

- **The false-pass hole stays closed by session discipline, not structurally.**
  → Continuous integration failing rather than skipping is the one rule of the
  four that would have closed it structurally, and it is recorded for the setup
  capability rather than added here, because a session never performs it. Until
  that change lands, an adopting project relies on the fragment's
  provisioning rule and its report-as-not-run instruction. That is weaker, and
  it is the price of keeping one-time obligations out of a document every
  session reads.

- **A project on another database stack must replace the binding fragment.** →
  That is what a binding is for; the alternative is v3 naming Postgres.

## Migration Plan

Projects carrying a `development-workflow` block keep it, at whatever version
they hold, until something updates it — this change writes no project's
`AGENTS.md`. Nothing in the library imports the three removed fragments, and
nothing outside it can, since no project adopted them.

`commerce-ops` adopts v3 when the block can be updated, at which point its
hand-written session rules are deleted and `docs/proposed-change-order.md` is
reconciled against `docs/change-queue.md`. That project's work.
