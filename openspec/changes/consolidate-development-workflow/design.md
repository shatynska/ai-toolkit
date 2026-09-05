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
- A change's stage readable from the repository by a session that was not there.

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
that every obligation be a role with the tool named beneath it and never in the
role sentence. So v3 states the archive step as a role, as it already does for
its review dispatches. This is the kind of defect consolidation creates rather
than inherits, and it is why the seam had to be written down before the merge
rather than after.

**Alternative rejected: remove `session-workflow` and move everything into
`project-bootstrap`.** One owner for one file is tidier, but `project-bootstrap`
is about bootstrapping — it would then own the substance of rules that have
nothing to do with initializing a project, and the capability's own purpose
statement would stop being true.

### 3. v3 assumes a remote, a forge, CI and a deploy — no conditionals

Every project this library is written for has all four. The forge is not
decoration: teardown's merge clause reads a pull request's merged state, which
is the only merge evidence that survives a squash or rebase merge. The conditionals for
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

### 6. Three stage families, and every stage derivable

The report exists to be read by a session that was not present. Prose is
re-interpreted at every hand-off; a name from a closed set is read once.

Three families rather than two, because `ship:` is where a session *waits* — on
a merge, on a deploy, on a confirmation it cannot make itself — and the only
actionable content of a waiting state is which one it is.

Each family carries its own review and its own relation to tests, and the
vocabulary spends two words rather than one on the difference: `plan:tests` is
tests written from the delta specs, `build:verify` is tests run against the
implementation. One word for both is ambiguous exactly where a resuming session
needs precision.

**Derivability is what forces a change beyond naming**, and it does not hold
uniformly across the vocabulary. Two kinds of name are in it:

- a **transient** stage names an activity in progress — `plan:draft`,
  `plan:revise`, `build:doing`, `build:verify`, `build:fix`. A session stopping
  inside one leaves the artifacts and the tree it had reached; the next session
  re-enters the activity rather than reading that it was in it. Safe, because
  each is idempotent.
- a **persistent** stage names something that happened, and every one of them
  must leave a trace or it is unreportable by whoever comes next.

Three classes of persistent stage leave none today: a review in flight, a
verdict received, and an operator's confirmation of what the repository does not
show — a deploy's health or a production effect.

A merge is deliberately not in that third class, and the distinction is worth
keeping straight because a first draft got it wrong. The merge *stage* is
traced: the forge reports it, and the teardown gate reads it. The operator's
*confirmation* of the merge is still recorded, because a session may not infer a
merge and because the deploy gate needs to know the confirmation was given — but
`ship:merged` itself is derived from the forge, not from the record.

**Decision: the dispatching or asking session records the dispatch, the verdict,
what it did about the verdict, and each operator confirmation, in the change's
own artifacts** — as `test-manifest.md` already records the one gate that does
leave a trace. The dispatch is recorded when made, not when it returns, or the
in-flight case stays lost.

A first draft of this decision recorded verdicts alone and asserted every stage
derivable. That was false for half the vocabulary, and the transient/persistent
split is what makes the remaining claim true rather than merely stated.

**Alternative rejected: amend the reviewer's output contract to write a file.**
Wider blast radius, and wrong on ownership — what a session did with a verdict
is the session's fact, not the reviewer's. A reviewer writing its own verdict to
disk still would not record whether anything was done about it.

### 7. The branch topology is its own requirement, because delivery is where a
change stops having one branch

Every other phase holds exactly one branch. Delivery does not: the record takes
one of its own, and each remedial cycle takes another. That makes three
questions live that are dead everywhere else — where the post-merge commits are
made, from what the record's branch is cut, and what teardown covers.

The post-merge commits are not incidental. Each operator confirmation, and a
waiver where one is given, is written *after* the work merges, and is exactly
what decision 6's recording obligation exists to produce.

**Decision: every branch a change creates, the record's included, is cut from
the freshly fetched trunk, and the record's branch carries the operator
confirmations, any waiver, and the archive commit.** A remedial cycle keeps its
own gate records on its own branch, with the code they gate — a rule over every
post-merge commit would put a fix's diff in the record's pull request, which is
the defect this route was chosen to avoid. This is the branch-creation rule the fragment already states for a
session's first branch, applied unchanged — delivery adds branches, not an
exception.

**A first draft cut the record's branch from the work branch's tip**, reasoning
that confirmations written before the merge would otherwise be stranded on a
branch teardown deletes. That reasoning is self-refuting: the record's branch is
created *after* the work merges, so everything on the work tip is already on the
trunk and nothing can be stranded. What the draft actually did was reintroduce
the defect it cited to reject its own alternative — cut from a squash-merged or
rebase-merged work branch, the record's branch shares no commit with the trunk's
version of that work, so the record's pull request re-presents the entire work
diff. It also left the record branch cut from a trunk-that-was, so an archive
applied to specifications another change had edited in the interval conflicts.

**Teardown therefore covers every branch the change created**, not "the branch",
and each is checked on its own pull request rather than derived from another's
state — they are siblings now, not a chain. Which means the set must be
enumerable by a session that created none of it, so each branch is recorded in
`gate-log.md` when cut and each pull request when opened. The branch is recorded
at the earlier moment because the record's branch can exist for several sessions
before its pull request does, and a change abandoned in that window would
otherwise hold a branch no enumeration reaches.

The set is the branches carrying the change's own work — work, remedial, record.
A proposal-only branch belongs to the change it proposes and is excluded, or
teardown would enumerate a branch that will never have a pull request to check
it against.

**The topology is its own requirement rather than a block inside delivery.**
It churned across three review rounds, teardown depends on it, and a requirement
headed on a pull-request count is the wrong place for a rule about where
branches come from — the same mismatch that made three predecessor requirements
replaceable rather than modifiable in this change.

**Teardown's merge clause requires at least one merged pull request, not merely
that every one merged.** A change abandoned before any pull request was opened
satisfies the universal vacuously, and a gate passed by having done nothing
would authorise deleting unmerged work on exactly the class of change the
abandonment route exists to serve.

**And the clause is stated against the pull request, not against ancestry.** A squash or rebase merge puts a branch's changes on the trunk
without making it an ancestor, so `git branch --merged` reports every branch of
every change unmerged in such a project and teardown never happens — the
accumulation the gate exists to prevent, produced by the check that authorises
removal. This exposure predates the change; what the change adds is a gate
covering three branches instead of one, which is what made it worth fixing here.

**Alternative rejected: keep the record commit on the work branch and re-push
it.** Fewer branches, but it contradicts the delivery requirement's own "a
commit of its own, on a branch of its own", and the record's pull request would
carry the work's diff a second time — the same defect, reached another way.

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
made, whose effect is absent, and which will be superseded by a new proposal
rather than corrected. Same disclosure, same recorded waiver, same route to the
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

### 10. The change queue is a separate artifact from the deferred-work file

`docs/deferred-work.md` exists in this repository and in `commerce-ops`, holding
what the project deliberately has not done, deleted when it stops being true.
`commerce-ops` grew `docs/proposed-change-order.md` separately for identified
changes, deleted when the change is archived, and states the split in its own
words.

They cannot share a file: one entry is swept on being fixed and the other on
being shipped, so an entry in the wrong one is deleted early or kept forever.

**Decision: `docs/change-queue.md`**, with the path fixed in the specification
for the reason `.claude/worktrees/` is fixed — a path stated only in a change's
artifacts is archived with them, and a requirement whose subject is then
unnameable cannot be checked afterwards.

**Alternative considered: adopt `commerce-ops`'s `docs/proposed-change-order.md`.**
More precise and already populated; longer, and inherited by every project.
Rejected because the fragment is written for projects that have never seen one.
Reversible — a path in one fragment and one requirement.

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

- **`gate-log.md` is a new artifact at every change's root.** → Named rather
  than left to "the change's artifacts", for the reason every other path in this
  capability is named: an unlocated record is one a resuming session searches
  for and two sessions file in two places. Its entries are committed with the
  next commit the session proposes where one is coming in that session, so the
  fragment's suggest-before-committing rule does not make every gate cost two
  confirmations. Four cases commit on their own, because for them no next commit
  arrives: every post-merge entry, the record's own pull request, an abandonment
  record, and a block written by a session that is ending.

- **Recording dispatches, verdicts and confirmations adds an artifact to every
  change, and adds writes mid-flow.** → Each write is a line, and it replaces a
  re-dispatched review or a re-asked confirmation, which are not. The
  alternative is a vocabulary whose persistent half no session can report.

- **The production-confirmation gate rests on an operator waiver that could be
  given reflexively.** → It is recorded in the change's artifacts with the class
  named, so a change archived on a waiver says so permanently and a pattern of
  them is readable. The alternative — no exemption — forecloses refactors
  entirely.

- **A project adopting v3 must reconfigure its continuous integration.** → It is
  the only obligation here reaching outside the library's files, and it is
  disclosed in the proposal's Impact rather than found at adoption. It is also
  the only one of the four new rules that closes the false-pass hole
  structurally rather than by session discipline.

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
