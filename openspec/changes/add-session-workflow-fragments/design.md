# Design

## The problem this shapes around

Three fragments have to be written such that a project can adopt any one of
them without the other two, while the three together describe one coherent
working arrangement. Those two goals pull against each other: the cheapest
way to make three documents coherent is to have them reference each other,
and a document that references a sibling is not independently attachable.

Everything below is downstream of resolving that tension in favour of
independence, and paying for it in a controlled amount of restatement.

## The cut is by applicability, not by phase

The natural cut is chronological — what a session does at the start, what it
does at the end. It is the wrong one. Two concerns run down the middle of
every phase boundary:

```
   phase cut                     applicability cut
   ─────────                     ─────────────────
   ┌─ START ──────────┐          ┌─ isolate ──────────────┐
   │ orient           │          │ orient                 │
   │ create worktree  │          │ create worktree        │
   └──────────────────┘          │ provision              │
   ┌─ END ────────────┐          │ tear down              │
   │ archive          │          └────────────────────────┘
   │ pull request     │          ┌─ deliver ──────────────┐
   │ remove worktree  │          │ archive                │
   └──────────────────┘          │ pull request           │
                                 │ await confirmed merge  │
   worktree setup and            └────────────────────────┘
   teardown land in
   different documents;          each document is one axis;
   PR delivery is welded         a project takes the axes
   to worktree teardown          it actually has
```

A project that runs sessions serially has no use for isolation but every use
for delivery. A project with no remote is the reverse. Under the phase cut
neither can adopt what it needs without also adopting what it does not.

Creation and teardown must stay in one document for the opposite reason: they
are not two concerns but one invariant seen from both ends. A project that
adopted creation alone would accumulate worktrees and branches with nothing
reporting it — and `commerce-ops`, which has creation rules and no teardown
rule, is the demonstration.

The shared-service namespace a session allocates is the one thing teardown
here does *not* reclaim; that is `add-namespace-reclamation`'s subject, and
`commerce-ops`' three orphaned databases are its evidence rather than this
change's. The invariant argument survives the split because it rests on the
teardown gate — the observable that says a worktree may go — which this
fragment still owns at both ends.

*Alternative considered:* one fragment covering all three axes. Rejected
because it is unattachable in two of the three project shapes above, and
because `rules/development-workflow.md` — already a single large fragment —
is the reason `update-managed-block` exists. A smaller unit of adoption is
the lesson that change is teaching.

*Alternative considered:* four fragments, orientation separate. Orientation
is the smallest of the four and was separated on the theory that a project
might want it alone. On inspection the theory is thin: the reason a session
must report where its change stands is that it is resuming work another
session left in a worktree, which is the isolation fragment's premise. A
document whose only rule depends on another document's premise is not
independently attachable, which was the entire argument for splitting it out.

## How independence is actually achieved

Each fragment states its own gates in terms it can check by itself.

The interlock that would otherwise couple them is teardown: it must not
happen while the change is still live. `worktree-isolation.md` therefore
states the gate as an observable — *the branch is merged into the trunk (or
its abandonment is recorded in the change's own artifacts), nothing
uncommitted remains, and where the project has a remote and the change was
not abandoned, nothing unpushed* — not as *after `change-delivery.md`'s
confirmation step*.

The abandonment route was added because a merge-only gate is unsatisfiable
for a change that legitimately ends without one, so its worktree and branch
accumulate — in the single case the gate forecloses, it produces the outcome
it exists to prevent. It is a *recorded* route rather than an operator's
say-so at the gate for the reason orientation exists at all: the session that
tears a worktree down may not be the session that abandoned the change, and
cannot see an exchange it was not part of. The record is committed before the
gate is read, or it trips the one clause it does not displace and blocks the
teardown it was written to authorise. And it displaces only what the
record covers — the branch's commits, merged or unpushed — never uncommitted
changes the decision never mentioned. Where both fragments
are attached, that confirmation is what satisfies the gate; where only
isolation is attached, the gate is satisfied however that project merges.
Neither document names the other.

Every remote clause is conditioned deliberately, and *every* means every —
the fetch that precedes creation as much as the push state the gate reads. A
project with no remote is one of the two shapes justifying the cut in the
first place, and an unconditional remote clause is unsatisfiable there: the
gate never opens, or the working tree is never created, worktrees and
namespaces accumulate, and the fragment produces exactly the failure it
exists to prevent in the project it was supposed to serve. Writing the
exemplar's own case as unsatisfiable would have discredited the argument the
exemplar carries.

The first pass at this conditioned the gate and left the creation rule saying
"a freshly fetched trunk" — the same defect, moved to the fragment's opening
line, where it bites earlier. Conditioning one clause of a presupposition is
not conditioning the presupposition.

The isolation fragment's rules are scoped too, and to a different axis: they
govern a working tree that carries a session's change. Unscoped they would
bind every working tree in the repository, including ones created and
destroyed inside a single act of tooling — `agent-authoring` mandates one for
a cold-run check — which hold no change, no trunk-bound branch, and therefore
no artifacts in which the gate's abandonment route could be recorded. Such a
tree could satisfy neither route and would be unremovable under a rule
written to prevent exactly that accumulation. The charitable reading, that a
scratch tree obviously is not "a session's working tree", is the one this
design refuses by name below; so the scope is stated instead.

The independence rule is scoped to the three session-scoped fragments, not to
`rules/` at large. `deferred-work.md` must reach outside the set — see below
— and a rule forbidding every reference would have forbidden the one
reference that keeps a bootstrapped project coherent.

This costs a small amount of duplicated context, and that cost is deliberate.
A fragment that only makes sense beside its siblings is the failure mode
being avoided, so restatement across fragments is correct here and should not
be refactored away by a later reader tidying up.

## Phrasing: the action is durable, the defect is not

`commerce-ops` derived this principle while revising its own worktree rules,
and it is adopted verbatim as the authoring standard:

> A rule states an action; a defect appears only as the reason that action
> matters; and the rule is phrased so the durable half is the instruction and
> the perishable half is the consequence.

The failure it prevents is specific. A rule written around today's damage
("the tier reports `Passed` for a run that skipped") competes with fixing the
damage: once the fail-open is closed, the rule is wrong and must be rewritten,
and until someone notices, it is misinformation. The same knowledge written
as an action ("provision the worktree before relying on a verification
result") survives the fix and is in fact enforced harder by it.

Applied here: every rule in all three fragments is an instruction. The
incidents in `proposal.md`'s Why appear inside the fragments only as the
reason a given instruction matters, and never as a standing entry of their
own.

## Isolation of external state

Filesystem isolation is what `git worktree add` provides. It is not what
breaks. What breaks is shared mutable state the verification touches — in
`commerce-ops`' case one Postgres instance whose integration tier "writes
freely and issues at least one unscoped `DELETE`".

Four arrangements were weighed for that instance:

| | one namespace, serialized | per-worktree schema | per-worktree database | per-worktree container |
|---|---|---|---|---|
| extra port / memory | none | none | none | **per session** |
| what varies per session | nothing | `search_path` | the name in the URL | port + project name |
| extensions, roles, `public` | fine | **instance-scoped, leak across worktrees** | fine | fine |
| hard-coded schema references | fine | **break** | fine | fine |
| portable to engines without schemas | fine | **no** | fine | fine |
| failure mode | **silent corruption; flaky tests that read as defects** | partial leakage | isolated | isolated |

Per-worktree database wins on cost-adjusted isolation: one knob (the name in
the connection string, which already comes from configuration), and it
behaves normally for everything schema-scoping breaks. Per-worktree container
buys engine-level isolation — different Postgres versions, different
extensions — which no worktree of one project needs, and costs real
machinery: `commerce-ops` pins `127.0.0.1:5432:5432`, so N containers means
parameterizing the port, discovering it after start, rendering the URL from
what was discovered, and tracking a volume per project to reclaim.

None of that table reaches the fragment. The fragment states the general
obligation — *a session's verification does not share mutable external state
with another session's; it takes its own namespace, named deterministically
after its worktree, in whatever form the project's naming constraint
requires* — and the project's own conventions supply the service, the naming
shape and the commands. The naming clause is deliberately loose because
`commerce-ops` proves a project can impose a shape of its own: its resolver
does a suffix check, so a per-worktree database must end `_test` —
`commerce_ops_<worktree>_test` and not `commerce_ops_test_<worktree>`.

Orientation and provisioning had to be ordered against each other, and the
order is not arbitrary. Orientation is the fragment's opening rule and
requires a real verification run; provisioning says a result obtained before
provisioning is worthless. Read as written and unordered, the opening rule
directs a session into a fresh worktree to run a tier that skips, and to
report its success — `proposal.md`'s second incident, reproduced by following
the fragment literally. The resolution splits the report rather than
weakening it: stage and committed state are readable from the repository at
once, and the verification half either follows provisioning or is reported as
not run and why. Orientation keeps its place; what it loses is permission to
present an unprovisioned green as a result.

Removing release from this change makes the *sequential* case load-bearing,
which is why provisioning carries an end-state obligation: a namespace
outlives the worktree that named it, so a later worktree deriving the same
name inherits whatever the last one left. The obligation is stated as a state
to reach rather than as commands, which keeps the looseness about naming form
and provisioning operations that the rest of this section argues for.

What further properties such a name must carry to be safely *reclaimable* —
a marker reserved to the scheme, an identity stable across a checkout's
working trees — belongs with reclamation and is specified there, not here.
This fragment needs only that the name be deterministic, so that which
session holds which namespace is readable.

## Reclamation is not here

An earlier draft of this design specified reclamation in full: reconciliation
at teardown rather than a remembered release step, a two-condition
eligibility test, three failure branches, an ordering constraint. It was
removed, and the removal is the design decision worth recording.

Six review rounds landed every critical and major finding in that one
requirement while the other ten produced none, and the sixth still found a
hole — the checkout identity that eligibility recomputes was never required
to be invariant across a checkout's own working trees, which is precisely the
property reconciliation needs, and the binding the tasks recommended could
not supply it from a linked working tree carrying tracked files only.

The pattern rather than the instance is what decided it. Reclamation is an
algorithm whose every predicate — eligible, claims, enumeration succeeded,
this checkout's identity — this change leaves to a project's binding. Prose
can require the predicates to exist. It cannot make them agree with one
another, and each round discovered one disagreement.

So `worktree-isolation.md` allocates and does not release, and says so. The
obligation moves to `add-namespace-reclamation`, which may ship the
provisioning script this section previously refused — a change scoped to
`scripts/` has its own Impact, and `toolkit-structure` already admits shipped
tooling there with a dependency-free harness to exercise it. The refusal
recorded here was always scoped to *this* change and named a separate change
as its successor; this is that successor.

The cost is stated in `proposal.md` Decision 5 rather than repeated: an
adopting project accumulates namespaces in the interval, which is today's
state everywhere, and the argument that kept creation and teardown together
now rests on the teardown gate rather than on reclamation.

## The one reference outside the set

`rules/development-workflow.md` already says, in a paragraph every
bootstrapped project carries inlined: *"An improvement noticed along the way,
that is not part of that change's stated scope, becomes a separate proposed
change rather than being folded in."* `deferred-work.md`'s independent path
offers a deferred-work file entry as an alternative to a proposal. Read side
by side in a project holding both, one permits what the other requires, and a
session cannot satisfy both.

The conflict is real rather than verbal. A normative fragment read by an
agent does not get the charitable reading in which "a separate proposed
change" loosely means "separate future work"; it gets the literal one.

Three routes out were weighed:

1. **State the seam in `deferred-work.md`.** A deferred-work entry *is* the
   separate proposed change, recorded rather than opened; both rules share
   the obligation that the work leaves the change in progress. **Chosen.**
   It costs one paragraph and leaves `development-workflow.md` untouched, as
   Impact promises.
2. **Drop the file-entry route**, so the two rules say the same thing.
   Rejected: the file entry is the option the `commerce-ops` evidence most
   strongly supports, and it is the one that survives the change being
   archived.
3. **Revise `development-workflow.md`.** Rejected on the versioning grounds
   the proposal already gives — it is stranded at `v1` and enlarging its body
   enlarges the diff `update-managed-block` was scoped against.

This is why the independence rule is scoped to session-scoped fragments
rather than stated across `rules/`: route 1 requires exactly the kind of
reference an unscoped rule would forbid.

## Why a new capability

`project-bootstrap` owns the content of `rules/development-workflow.md` —
"The workflow rules name a role before naming a tool", "The workflow rules
state an ordered sequence whose gates have checkable preconditions" — but it
owns that content as a consequence of inlining the fragment, which is what
makes a project's copy `project-bootstrap`'s business. Nothing in this change
is inlined and nothing is bootstrap, so filing these requirements there would
attach them to a capability whose purpose statement does not describe them.

`toolkit-structure` owns a fragment's *form* — its directory, its
frontmatter, its consumption paths — and explicitly not what any fragment
says. It needs no change: it already permits any number of fragments under
`rules/`.

So `session-workflow`, new, owning what session-scoped fragments must say.

## Two decisions about the fragments as artifacts

**Not inlined by `scripts/project-init`.** It hard-codes one fragment path
and one marker. Teaching it N blocks is `update-managed-block`'s scope, and
that change is blocked on three open questions of its own; coupling a new
fragment set to it would strand both. `@` import and hand-copying already
work, and `toolkit-structure` already documents them.

**No `version:` frontmatter.** `toolkit-structure` requires a version of a
fragment "that is inlined into a consuming project"; `project-bootstrap` owns
the increment condition, also scoped to inlining. A version on a fragment
nothing inlines is a number no requirement obliges anyone to increment, and
an unincremented version is worse than an absent one because it reads as a
claim. Adding one later is a frontmatter-only edit, which `rules/README.md`
already says is not itself a body change.

*Alternative considered:* declare `version: 1` now so that inlining later is
not a migration. Rejected: the migration it avoids is one line, and the
staleness it invites is silent.
