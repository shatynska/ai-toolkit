## REMOVED Requirements

### Requirement: Session-scoped rules are separate fragments cut by applicability

**Reason**: The property this requirement bought — each fragment adoptable without the others — has no consumer and never had one. No project adopted any of the three, because nothing could install them: `rules/` has no loader, the `@` import path is machine-local, and the one tool that inlines a fragment reads a single hardcoded path. Meanwhile the property is what made them long, since every gate had to be checkable inside the fragment stating it and no fragment could name a sibling. The obligations are consolidated into `rules/development-workflow.md`, which the tool already installs.

**Migration**: Every obligation the three fragments carried is restated by the requirements of this capability, retargeted at the workflow fragment. `rules/worktree-isolation.md`, `rules/change-delivery.md` and `rules/deferred-work.md` are deleted. No project imports them, so no consuming project is affected; a reader looking for them finds their content in the workflow fragment's body.

### Requirement: Session-scoped fragments declare a kind and, while nothing inlines them, no version

**Reason**: The requirement withheld a `version` for as long as no tool inlined the fragments, and anticipated its own lifting — "Should that change, the `version` key becomes owed by the requirements already cited, without this one being amended." That change is this one. The workflow fragment is inlined by `scripts/project-init` today; the database binding fragment will be, by the tooling change already queued. In the interval between this change landing and that one, the binding fragment carries a version nothing yet inlines — a bounded and named interval, rather than the open-ended one the removed requirement was written against.

**Migration**: `toolkit-structure` fixes the frontmatter's form and `project-bootstrap` owns the condition under which a version increments. Both apply to the workflow fragment already. The database binding fragment declares `kind: standing-constraint` and a `version` — permitted rather than owed until something inlines it, since `toolkit-structure` requires a version only of an inlined fragment and forbids one nowhere. Its increment becomes owed, and owned, when the tooling change inlines it.

### Requirement: A working tree is torn down only against an observable gate

**Reason**: Two of its scenarios assert properties this change removes — that the gate is satisfiable in a project with no remote, and that it is checkable without a delivery fragment. Both exist because the isolation fragment had to stand alone in a project that might have neither. With one document and a stated profile, they are dead clauses that a reader must decide to ignore. The requirement is replaced rather than amended because its scenarios, not only its prose, encode the removed property.

**Migration**: Replaced by "A session's branch and working tree are removed only against an observable gate", which keeps both routes, the displacement analysis, the commit-the-record-first clause and the execution-context clause, and drops the conditionals for a project with no remote and for a delivery rule stated elsewhere.

### Requirement: A change is delivered through a pull request that carries its own record

**Reason**: Its central scenario asserts that the change's record ships inside the pull request carrying the work. Where merging to the trunk triggers a deploy — which every project this library is written for does — that writes "this change shipped" at the moment the work was merely merged, and writes it identically where the deploy that followed failed.

**Migration**: Replaced by "A change is delivered through at least two pull requests, the last carrying its record", which keeps the entry gate, the tooling-precondition clause and the confirmed-never-inferred merge, and adds the deploy, the production-confirmation gate between the merge and the record, and a remedial cycle that carries its own pull request.

### Requirement: A second change surfacing in a session is recorded, not carried

**Reason**: Two of its clauses no longer hold. It names `docs/deferred-work.md` as the destination for an identified change, and that file already exists in this repository and in `commerce-ops` holding something else — what the project deliberately has not done, deleted when it stops being true, rather than an identified change, deleted when that change is archived. And its reconciliation scenario is written for a project carrying the inlined workflow rules alongside a separate deferred-work fragment — a pairing consolidation removes, since the two obligations now sit in one document and the seam between them is internal rather than cross-file.

**Migration**: Replaced by "A second change surfacing in a session is recorded in the change queue", which keeps the one-change rule, the dependent and independent paths, the proposal-only-branch clause and the reason the artifact sits outside the change, and routes identified work to `docs/change-queue.md` with the two artifacts' deletion conditions stated.

## MODIFIED Requirements

### Requirement: A rule states an action and a defect appears only as its reason

Each session-derived rule in the workflow fragment, and each rule in the database binding fragment, SHALL be phrased as an action to take. A defect, incident, or current shortcoming MAY appear only as the reason a stated action matters, never as a standing entry of its own.

Each rule SHALL be phrased so that its durable half is the instruction and its perishable half is the consequence. A rule built around a defect goes stale when the defect is fixed and, until someone notices, contradicts the fix.

A rule SHALL NOT be omitted on the grounds that the defect motivating it is being fixed, where the instruction survives the fix. The instruction and the damage are separable, and only the damage expires.

#### Scenario: A rule outlives the defect that motivated it

- **WHEN** the defect a rule cites as its reason is subsequently fixed, or is enforced more strictly
- **THEN** the rule's instruction is unchanged and still correct, and only the consequence it names is out of date

#### Scenario: An incident does not become a standing entry

- **WHEN** an incident from a consuming project is used as evidence for a rule
- **THEN** it appears as the reason that rule's action matters, and no rule consists of the incident alone

### Requirement: A session reports where its change stands before acting

The workflow fragment SHALL require a session, on entering a working tree, to report the state of the change it finds there before taking any other action on the change: which change it is, what stage it has reached, how far through its task list it is, what has been committed, and whether its verification currently passes.

**It SHALL require the same report as the last thing said before the session stops.** Orientation and hand-off are one obligation seen from two ends; a session that reports on arrival and not on departure leaves the next one to reconstruct what it already knew.

**The report SHALL be a single row of fixed cells, in a fixed order, and SHALL NOT be a paragraph.** The cells are the change's name, its stage named from the vocabulary below, its task progress, and its committed state. The entering report SHALL carry one further cell, the verification result, because that is the half a session arriving does not know and a session leaving does.

The fixed row is required rather than recommended because the report's whole purpose is to be read by a session that was not present. Prose is re-interpreted at every hand-off; a row in a known shape is read at a glance, and a missing cell shows as a gap rather than passing as an omission nobody notices.

That report SHALL be derived from the repository — the change's own artifacts, the commit log, and, except as the composition clause below provides, an actual run of the verification — and SHALL NOT be assembled from recalled conversation. A session entering a working tree is resuming work some other session left there, and the working tree is the only party that knows how far it got.

The fragment SHALL state how this composes with provisioning, because the two do not compose on their own. The stage and the committed state are readable from the repository immediately. A verification result is not: a working tree that has not been provisioned produces a run that skips and reports success, so an orientation report assembled before provisioning states that verification passes on exactly the evidence the provisioning requirement below says is worthless. The fragment SHALL therefore require that the verification cell come either from a run made after provisioning is complete, or be reported as *not run, and why* — never from a run made against an unprovisioned tree.

Nothing here licenses skipping the report. Orientation still precedes the work; what it may not do is present an unprovisioned tree's green as a result.

#### Scenario: A session resumes a working tree left by another session

- **WHEN** a session begins in a working tree holding a change it did not start
- **THEN** it reports the change's name, its stage, its task progress, its committed state and its verification result before continuing the work

#### Scenario: The report is a row, not a paragraph

- **WHEN** a session reports where its change stands
- **THEN** the report is a single row of fixed cells in the fixed order, so a session reading it later takes the stage from a known position rather than from a sentence

#### Scenario: A session reports on the way out as well as the way in

- **WHEN** a session stops
- **THEN** the last thing it says is that row, so the next session's arrival report has something to be checked against rather than reconstructed from nothing

#### Scenario: An unprovisioned working tree's green is not reported as a result

- **WHEN** a session enters a newly created working tree that has not been provisioned, and the project's verification would skip rather than fail
- **THEN** the orientation report gives the change's stage and committed state, and reports verification as not run and why, or reports the result of a run made after provisioning — never the skipped run's success

#### Scenario: The report is derived rather than recalled

- **WHEN** the session has earlier conversation describing the change's state
- **THEN** the report is still derived from the repository and a run of the verification, because the conversation records what was true when it was written and the repository records what is true now

### Requirement: One session works in one branch and one working tree

The workflow fragment SHALL state what its working-tree rules govern before stating them: a working tree in which a session is doing a change's work. A working tree whose lifetime is bounded by the single act of tooling that created it, and which carries no branch destined for the trunk — a cold-run check of an agent under authoring, for example — is outside them.

The discriminator is the branch and the lifetime, not the contents. A working tree created from a committed ref carries whatever that commit held, a change's own artifacts included, so "holds no change" would exclude nothing and would leave the exemplar named here inside the rules it is named to be outside of.

Without that scope the rules bind every working tree there is, including ones that can satisfy neither the one-tree rule nor either route of the teardown gate, because they hold no change in whose artifacts an abandonment could be recorded. This repository's own `agent-authoring` capability already mandates such a working tree, so the collision is present rather than hypothetical.

The fragment SHALL require each session to work in a working tree of its own, on a branch of its own, created from the trunk freshly fetched from the remote.

The rule governs the branch a session works on at any moment, not the number of branches a change accumulates over its life. Delivery creates further branches — a record's, and one per remedial cycle — each cut from the trunk in the same way, and the fragment SHALL state that here rather than leave a reader to meet the one-branch rule and the delivery sequence as two rules that disagree. The obligation that a session carries only one change at a time belongs to the change-queue requirement below and is not restated here.

It SHALL name the location of a session's working tree as a single fixed path within the repository — `.claude/worktrees/`, one directory per working tree — rather than describing it as a path the project chooses. The path is named because the tooling that creates these working trees places them there; leaving it unnamed would put the containment obligations below out of reach of anyone checking them.

It SHALL state the two containment obligations that location carries:

- the working-tree root is named in the repository's ignore file; and
- every recursive tool the project runs that does not read that ignore file — test collection, linters, type checkers, container build context — is scoped explicitly so it cannot descend into it.

Without both, one session's run silently includes every other session's copy of the source tree, and a forced clean of the parent destroys unmerged work in every session at once.

#### Scenario: A working tree carrying no change is not held by these rules

- **WHEN** tooling creates a working tree that holds no change and no branch destined for the trunk — a cold-run check, say — and removes it when done
- **THEN** the one-tree rule and the teardown gate do not bind it, because the fragment scopes its rules to a working tree carrying a session's change

#### Scenario: Two sessions do not share a working tree

- **WHEN** a second session begins work on the same repository while a first is in progress
- **THEN** it works in its own working tree on its own branch, rather than sharing the working tree, index or checked-out branch of the first

#### Scenario: A recursive tool does not descend into sibling working trees

- **WHEN** a tool that walks the repository tree runs from the repository root
- **THEN** it is either scoped explicitly or excluded by the ignore file, and does not collect, lint, type-check or package another session's copy of the project

### Requirement: A working tree is provisioned before any verification result is relied on

The workflow fragment SHALL state that a newly created working tree carries tracked files only — no ignored configuration, no installed dependencies, no build artifacts, and no share of any external state the project's verification uses — and that provisioning it is a precondition of relying on any verification result obtained in it.

The reason SHALL be stated as the false pass, not as convenience: an unprovisioned working tree does not fail loudly. Verification that cannot reach what it needs skips, the gate reports success, and the result is indistinguishable from a run that passed.

It SHALL state that provisioning is complete when the end state of every step the project's own conventions name holds, not when the first one does. A partially provisioned environment fails in ways that read as defects in the change under test.

Where the project's verification writes to a shared external service, provisioning SHALL bring the session's namespace in it to the project's known initial state, whether or not a namespace already exists under the name this session derives. Because a namespace outlives the working tree that named it and the fragment states no release, a later working tree taking the same deterministic name inherits whatever the previous one left there — so the session's verification runs against a dead session's data, and its failures read as defects in the change under test. The obligation is an end state, not a sequence of commands: what reaches that state is the binding fragment's, or the project's.

Provisioning SHALL be stated throughout as a state to reach rather than as an act performed once, so that a session entering a working tree it did not provision reaches that state rather than having to determine whether an earlier session already did. Without this the composition clause above has no safe route: it makes provisioning the ordinary path to a reportable verification result, and a session that cannot tell whether re-performing a step is safe defaults permanently to reporting the result as not run.

Before concluding that a required shared service is unavailable, a session SHALL check for it. An assertion that a service is absent SHALL rest on having looked.

#### Scenario: A skipped verification tier is not read as a pass

- **WHEN** a working tree lacks the configuration its verification needs, and the verification therefore skips rather than fails
- **THEN** the fragment's rules direct that the result is not evidence of anything having run, and provisioning is completed before the result is relied on

#### Scenario: A namespace surviving from an earlier session is not inherited

- **WHEN** a session derives its namespace name and a namespace already exists under that name, left by an earlier working tree that has since been removed
- **THEN** provisioning brings it to the project's known initial state before any verification result is relied on, rather than the session running against what the earlier one left

#### Scenario: A session provisions a tree it did not provision itself

- **WHEN** a session enters a working tree an earlier session created and provisioned, and needs a verification result to report
- **THEN** it reaches the provisioned state directly, rather than having to establish which steps the earlier session performed before it can safely act

#### Scenario: Provisioning is not assumed to be one step

- **WHEN** the project's conventions name several provisioning steps
- **THEN** the fragment requires all of them, and does not treat the first step's success as provisioning having completed

#### Scenario: A shared service is checked before being declared absent

- **WHEN** a session cannot reach a service the project's verification requires
- **THEN** it checks whether the service is running before reporting it unavailable

### Requirement: A session's verification does not share mutable external state with another session's

The workflow fragment SHALL require that where a project's verification writes to a shared external service, each session takes its own namespace within that service rather than sharing one.

The namespace SHALL be named deterministically from the session's working tree, so that which session holds which namespace is readable rather than guessed.

The workflow fragment SHALL prescribe no concrete service and no naming form; both belong to the binding fragment, or to the project's own conventions where it has no binding fragment.

Reclaiming a namespace once its working tree is gone is **not** stated by the workflow fragment; it belongs to a separate, proposed capability for namespace reclamation, because the properties a name must carry to be safely reclaimable are properties of an algorithm rather than of a convention. It is named as proposed rather than as existing, so that a reader who cannot find it can tell an unwritten capability from a deleted one. The fragment therefore allocates and does not release, and SHALL say so rather than leave a reader to infer that the omission was an oversight. It SHALL state the consequence inline rather than by reference: a project carrying these rules accumulates namespaces and needs a sweep of its own until something reclaims them.

#### Scenario: Two sessions verify concurrently against one service

- **WHEN** two sessions run a verification that writes to the same shared service
- **THEN** each writes within its own namespace, and neither observes or destroys the other's data

#### Scenario: The project imposes its own naming form

- **WHEN** the binding fragment or the project's tooling constrains what a namespace may be called
- **THEN** the deterministic name derived from the working tree is expressed in that form, and the workflow fragment's rule is satisfied rather than contradicted

## ADDED Requirements

### Requirement: The session obligations are published in the workflow fragment and one binding fragment

The obligations this capability governs SHALL be published in two places and no more:

- `rules/development-workflow.md` — the workflow fragment, which states every obligation service-neutrally alongside the spec-driven gates it already carries, and which `scripts/project-init` inlines into a consuming project's conventions file;
- `rules/development-workflow-database.md` — the binding fragment, which binds the workflow fragment's provisioning and namespace obligations to a containerized relational database.

The workflow fragment SHALL state a role and name its binding beneath it, as it already does for specification tooling. The binding fragment SHALL NOT restate an obligation the workflow fragment states; it names the service, the naming form and the operations that reach the stated end state.

**The workflow fragment SHALL assume a remote, a forge that reports a pull request's merged state, continuous integration, and that merging to the trunk deploys, and SHALL state no conditional for their absence.** Every project these rules are written for has all four. A conditional for a shape no consumer has is paid for by every reader of every project that does have one, and it is the class of text that made the previous publication expensive.

A project of a shape these assumptions do not fit is served by a publication of its own rather than by a conditional here. A second publication is written when there is something to write it for; a conditional is carried forever whether or not anything needs it.

Where such a publication is written, **this capability owns it alongside the others**, and states each shared obligation once while naming which publications it binds — the arrangement it already holds for the workflow fragment and the binding fragment. Stated, because the argument against keeping two publications of one rule set is that both must be maintained, and that argument applies to this pair the moment it exists rather than being answered by the pair having been anticipated.

Neither fragment SHALL name a `rules/` path, a sibling fragment, or an import. In a consuming project the conventions file is a copy and no `rules/` directory is read, so a sentence naming a fragment file names something the reader cannot open.

Where a binding is itself a fragment rather than a tool name written inline, the workflow fragment SHALL refer to it by where the reader will find it — an adjacent section of the same conventions file, where the project carries one — and not by a path. The reference SHALL be conditioned on the project carrying that binding, since until the installing tool writes a second block the section exists only where someone pasted it, and an unconditional reference points at nothing in every project initialised in the interval. Otherwise the two clauses above cannot both be satisfied for the case this requirement exists to introduce, and a project holding the workflow fragment alone would carry a service-neutral obligation with no stated way to learn that a binding exists at all.

`project-bootstrap` owns how the workflow fragment reaches a project and what shape it takes there — the managed block, the version and its increment condition, that a role is named before a tool, that the gates form an ordered sequence with checkable preconditions, and that an automatic dispatch loop is bounded, what happens on reaching the bound, and which outcomes exit the loop rather than consume a round. This capability owns what the session-derived rules say, and MAY fix the numeric value of a bound for a loop it states — `project-bootstrap` requires that a bound exist and fixes no number.

Where this capability states a loop, it SHALL state the value, what happens on reaching the bound, **and** the outcomes that exit it — all three of what `project-bootstrap` requires of every loop the rules state, since a loop introduced here would otherwise arrive carrying only the part this capability remembered. The seam is stated because both capabilities bear on one file, and an unstated seam is resolved by whoever amends it first.

#### Scenario: A session obligation is stated once

- **WHEN** an obligation this capability governs is amended
- **THEN** it is amended in the workflow fragment, and the binding fragment changes only where the amendment touches the service, the naming form or the operations

#### Scenario: A reader of a project's conventions finds no dangling reference

- **WHEN** a session reads the workflow fragment's body as inlined in a project's conventions file
- **THEN** every reference resolves within that document, and no sentence names a file that exists only in this library

#### Scenario: A project without a deploy is not served by a conditional

- **WHEN** a project that does not deploy on merge needs these rules
- **THEN** it is served by a publication of its own, and the workflow fragment states its assumptions plainly rather than branching on them

#### Scenario: A second publication does not arrive unowned

- **WHEN** a publication for another project shape is written
- **THEN** this capability owns it alongside the workflow fragment and the binding fragment, and states each shared obligation once naming which publications it binds

### Requirement: A change's stage is named from a fixed vocabulary, and every stage is derivable

The report of where a change stands SHALL name the stage from a fixed vocabulary rather than describing it in prose. A prose description is re-read and re-interpreted by every session that resumes the work; a name from a closed set is read once.

The vocabulary SHALL be three prefixed families, ordered, corresponding to the three gates a change passes:

- `plan:` — `draft`, `review`, `revise`, `approved`, `committed`, `tests`
- `build:` — `doing`, `verify`, `review`, `fix`, `clear`
- `ship:` — `pr`, `merged`, `deployed`, `confirmed`, `record`, `done`

Off the ordered path, two further names SHALL be available in any family: `blocked:<what>` and `abandoned`.

A recorded waiver of the production-confirmation gate SHALL satisfy `ship:confirmed` for reporting. A waived change never truthfully observes its effect, yet it passes that stage on the way to its record; without this the one route the delivery requirement opens for it reports a stage the vocabulary says it cannot reach.

The families SHALL be three rather than two, because `ship:` is where a session *waits* — on a merge, on a deploy, on a confirmation it cannot make itself. The only actionable content of a waiting state is which one it is, and folding them into `build:` gives them one name.

Each of `plan:` and `build:` SHALL carry its own review and its own relation to tests, and the vocabulary SHALL NOT reuse one word across the two. `plan:tests` is tests being **written** from the change's specification deltas; `build:verify` is tests being **run** against the implementation. A single word for both makes a report ambiguous exactly where a resuming session needs precision.

**Every stage that persists across a session boundary SHALL be derivable from the repository**, since the report as a whole must be. A stage knowable only by having been present when it was reached is not reportable by the session that comes next.

The vocabulary contains two kinds of name and the requirement SHALL distinguish them, because a single universal claim over both is false and was asserted before it was checked.

**A transient stage names an activity in progress, not a state left behind.** `plan:draft`, `plan:revise`, `build:doing`, `build:verify` and `build:fix` are of this kind: a session that stops inside one leaves the artifacts, the task list and the working tree it had reached, and the next session re-enters the activity rather than reading that it was in it. This is safe because each is idempotent — re-running a verification, re-reading a draft, re-applying a finding costs a repetition and never a wrong result. A transient stage SHALL be reported from what the repository holds *now*, and the vocabulary SHALL NOT claim it is recoverable as a stage.

**A persistent stage names something that happened**, and every one of them SHALL leave a trace. Three classes leave none today:

- **A review in flight.** Dispatching a plan review or a code review ends in the conversation. A session that dispatched and then ended is indistinguishable from one that never dispatched — the loss this capability prevents for a dependency, one level up.
- **A verdict received.** What a review returned, and what was done about it, ends in the conversation too.
- **An operator's confirmation of something the repository does not show.** A deploy's health and a confirmed production effect are stated by the operator and written nowhere, so `ship:deployed` and `ship:confirmed` rest on a sentence the next session cannot see. A merge is not in this class — the forge reports it, and the teardown gate below already reads it — so `ship:merged` belongs with the stages traced from the repository. The delivery requirement's obligation to obtain the operator's confirmation of a merge stands regardless: what a session may not do is *infer* a merge, and reading the forge is not inferring.

**A review dispatch, the verdict it returns, what was done about that verdict, each operator confirmation, a production-confirmation waiver, a block, an abandonment, each branch the change cuts, and each pull request it opens SHALL therefore be recorded in a single named artifact at the change's root — `gate-log.md`** — as `test-manifest.md` already records the test gate at the same place.

A gate-log entry is written when the gate is passed and committed with the next commit the session proposes **where one is coming within the same session**. Otherwise the fragment's own rule that a commit is suggested and never made unasked would make every gate cost a second confirmation to record it, and a session asking twice per gate is answered less carefully each time.

**Where no further commit is coming in that session, the entry is committed on its own.** The fragment SHALL name the cases, because each is one where the batching rule silently loses the record it was written to keep:

- **Every post-merge entry** — the merge confirmation, the deploy's health, the effect or its waiver — committed on the record's branch when it is written rather than held for the archive commit. `ship:` is by design where a session waits and stops, so the interval between the merge confirmation and the archive commit routinely spans several session boundaries; batched, the record most likely to be written immediately before a session ends is the one left uncommitted.
- **The record's own pull request**, opened after the archive commit is pushed, so nothing follows it in that session.
- **An abandonment record**, which the teardown gate requires committed before it is evaluated. Deferred to a commit that never arrives, it trips the one teardown clause it does not displace, so the act authorising teardown blocks it.
- **A block recorded by a session that is ending**, which is lost to the first clean or branch switch, leaving the next session to re-enter an activity that will block again.

The file is named rather than left to the change's artifacts generally, for the reason `docs/change-queue.md` and `.claude/worktrees/` are named: a location stated only in a change's own artifacts is archived with them, and a resuming session that must search rather than read will find two sessions having filed the same kind of record in different places. The dispatch is recorded when it is made and not when it returns, or the in-flight case is exactly the one still lost.

The recording is the dispatching or asking session's obligation and not the reviewer's: `change-review` owns the reviewer's output contract and is not amended by this, and an operator is not obliged to write anything.

**A persistent stage whose trace is already the repository's or the forge's own state needs no recording rule for the stage itself**, and the requirement SHALL say which those are rather than leave a reader to assume every persistent stage owes a write. `plan:committed` is read from the commit log, `plan:tests` from the test manifest, `ship:pr` from a pushed branch with an open pull request, `ship:merged` from that pull request's merged state, `ship:record` from the record's branch and its pull request, and `ship:done` from the archive commit on the trunk. What none of those show, and what therefore must be recorded for a stage to be reportable, is a dispatch, a verdict, a disposition, and an operator's word.

That list says which *stages* need a recorded trace. It does not bound what `gate-log.md` holds: a record may be owed for a reason other than naming a stage. The pull-request record the topology requirement obliges is one — the forge shows a pull request, so `ship:pr` needs no entry, but nothing tells a later session *which* pull requests belong to this change, and the teardown gate is stated over that set.

**`blocked:<what>` and `abandoned` are persistent, and both are recorded in `gate-log.md`.** A session that ends blocked SHALL record what it is blocked on there — without it the next session reads a transient stage from the working tree and re-enters an activity that will block again. The abandonment record the teardown gate requires is written there too.

Every record this capability obliges goes to that one file. A record kind left to "the change's artifacts" is one two sessions file in two places, which is the reason the file is named at all — and stating that reason while exempting two record kinds from it would defeat it.

#### Scenario: A resuming session names the stage without interpreting prose

- **WHEN** a session enters a working tree holding a change another session left
- **THEN** it reads the stage from the change's artifacts and the commit log and names it from the vocabulary, rather than reconstructing a description

#### Scenario: A dispatched review survives the session that dispatched it

- **WHEN** a session dispatches a review, receives a verdict, and ends before acting on it
- **THEN** the verdict is readable in the change's `gate-log.md`, so the next session can tell `plan:approved` from `plan:draft` and does not re-dispatch a review that already ran

#### Scenario: A review still in flight survives the session that dispatched it

- **WHEN** a session records a dispatch, dispatches the review, and ends before any verdict arrives
- **THEN** the dispatch is readable in the change's `gate-log.md`, so the next session reports `plan:review` rather than finding a change indistinguishable from one that never dispatched

#### Scenario: An operator's confirmation is not lost with the conversation

- **WHEN** the operator confirms a merge, a deploy's health, or a confirmed production effect, and the session then ends
- **THEN** each confirmation is recorded in the change's `gate-log.md`, so the next session reports the `ship:` stage reached rather than re-asking for a confirmation already given

#### Scenario: A transient stage is re-entered rather than recovered

- **WHEN** a session stops while running verification or applying a review's findings
- **THEN** the next session reports what the repository holds now and re-enters the activity, because a transient stage names work in progress and re-entering it is idempotent

#### Scenario: Writing tests and running tests are not one word

- **WHEN** a report names a stage involving tests
- **THEN** `plan:tests` names tests being derived from the specification deltas and `build:verify` names tests being run against the implementation, and neither name is used for the other

#### Scenario: A change waiting on a deploy is distinguishable from one waiting on a merge

- **WHEN** a session reports a change that has been merged but whose deploy has not completed
- **THEN** the stage is `ship:merged` and not `ship:pr` or `build:clear`, so what is being waited on is readable from the name alone

### Requirement: A change is delivered through at least two pull requests, the last carrying its record

The workflow fragment SHALL state that a completed change reaches the trunk through pull requests, and that it takes **at least two**: the work, then the record that it shipped.

**Two is a floor, not a fixture.** Where the deploy is unhealthy, or the deployed change does not do what it existed to do and the cause is a defect in it, the remedy is itself work reaching the trunk — so it takes a pull request of its own, its own review, its own merge and its own deploy, and the sequence re-enters at the review gate rather than resuming mid-flight. A change that needed two remedial cycles was delivered through four pull requests, and nothing about that is exceptional.

The fragment SHALL therefore state the count as a minimum and SHALL identify the record's pull request as the **last** one rather than the second. A sequence written as exactly two leaves a session that has just merged a fix with no stated position: the record's slot is spent, and the only readings available are to skip the record or to treat the fix as though it never happened.

It SHALL state an entry gate: delivery begins only where the change's verification has run and passed against the branch head, and the post-implementation review has cleared.

**It SHALL bound the post-implementation review loop at three rounds**, and SHALL state that a re-review is dispatched only where the fixes applied were substantial enough to be worth reviewing in their own right. Past three, the session reports where the loop stands and asks rather than dispatching a fourth.

It SHALL also name the outcomes that exit the loop rather than consume a round: a review that clears exits forward, and a review judging the implemented change unsound rather than defective exits immediately and is raised, whatever the count stands at — no number of revisions answers it. A bound stated without its exits spends rounds on a verdict revision cannot satisfy. The bound differs from the plan-review bound stated elsewhere in the fragment because the loops differ: a plan review revises prose against a moving argument, a code review revises code against a specification already fixed.

The first pull request SHALL carry the work. The fragment SHALL require the operator's confirmation that it merged and that the deploy it triggered is healthy. A session SHALL NOT infer a merge, a deploy, or a confirmed effect from a green pull request, an approval, or silence.

**A healthy deploy is not the change working.** The fragment SHALL place a further gate between the healthy deploy and the record: the change's intended effect is confirmed in production. A deploy's health reports that the new code is running and reports nothing about whether the behavior the change existed to produce is the behavior production now has, and those fail separately.

The fragment SHALL acknowledge that a session usually cannot make that observation itself — production is reached through interfaces a session does not hold — and SHALL therefore oblige it to **propose how the effect can be observed**: what to look at, what to do to provoke it, and what result would mean the change worked. The confirmation itself is the operator's, on the same terms as the merge.

**The gate SHALL state its own exemption, in advance and by class.** A change with no externally observable effect in production — a refactor, a dependency bump, an internal cleanup, a change to the repository's own conventions — cannot pass a gate that asks what to look at, and a gate stating no exemption forecloses it permanently: the record is never written, and the teardown gate below is conditioned on the record's pull request having merged, so the branch and working tree become unremovable. That is the accumulation this capability exists to prevent, reached in a class of change that did nothing wrong.

The exemption SHALL be: where the session can propose no observation that can actually be made — including one it proposed and that turns out not to be performable — it says so plainly and names the class, and the operator waives the gate. The waiver SHALL be recorded in the change's `gate-log.md`, and it is what the record then rests on in place of a confirmed effect. It is a waiver stated in advance for a named class, not a gap discovered at the gate — the distinction `project-bootstrap` requires of every precondition this fragment states.

Saying so plainly is still owed. What the exemption removes is the stall, not the disclosure: a change whose effect nobody can observe is worth knowing about before it is archived as shipped.

Only once the effect is confirmed, **or the waiver recorded**, SHALL the record be closed: the change's specification record archived in a commit of its own, on a branch of its own, through a pull request of its own — the last of the change's pull requests, however many the work took. The record's subject is that the change shipped, so it cannot precede the shipping.

Where the deploy is not healthy, the fragment SHALL state that the change is not delivered and the record is not written, and that the remedy re-enters the sequence at its review gate rather than continuing past it — carrying its own pull request, as any work reaching the trunk does.

Where the deploy is healthy and the intended effect is absent, the fragment SHALL require the session to distinguish a defect in the change from the change having been the wrong change — which is a new proposal, not a correction — and SHALL state a terminal for each. A defect re-enters the sequence at its review gate. The wrong change does not, and its terminal SHALL be stated rather than left open.

**The wrong change is the confirmation gate's second waivable class**, named in advance on the same terms as the first: a change whose proposed observation was made, whose effect is absent, and which is **not to be corrected in place**. Being superseded by a new proposal is the typical case and SHALL NOT be a defining condition — a change judged wrong and reverted, or simply dropped, satisfies the class as fully, and a definition requiring a successor would leave it in neither class and back at the dead end this exemption exists to close.

The session says so plainly and names the class, the operator waives, the waiver is recorded in `gate-log.md`, and the record proceeds on it. **Where a successor is intended, the waiver SHALL name its change-queue entry or its proposal branch.** This class is the one whose defining fact is a decision rather than an observation, so what it leaves behind is the only trace of why a change was archived as shipped while its effect was confirmed absent — and the specification the archive step writes to the trunk then describes behaviour production does not have. A reader meeting that specification later is owed the pointer.

Without that terminal the path dead-ends. The record cannot be written, because the effect is unconfirmed. The first waivable class does not reach it, because an observation *was* proposed and made — and improvising an exemption at the gate is what stating exemptions in advance forbids. The abandonment route does not reach it either, because that record must assert the work on the change's branches is not wanted, and this work is merged, deployed and running. A compliant session would stop with a branch set and a working tree it can never remove, which is the accumulation this capability exists to prevent, reached down a path the fragment itself names.

The record is truthful on this route: the change shipped, and what it shipped did not do what was wanted. That is what the waiver records, and it is worth having on the trunk rather than lost with the session that discovered it.

**The deploy pipeline SHALL be the only path to production.** The fragment SHALL state that the command that deploys is never run locally against production, and that a change reaches production by merging and by nothing else. Local credentials for the production environment, where they exist at all, are for reading — a plan, a status, a log — and not for applying.

Without this, every gate above is optional. A session that can deploy from its own machine can reach production without a pull request, without continuous integration, and without the review that the pull request exists to obtain; the whole sequence becomes a convention rather than a constraint, and nothing reports the one time it was skipped.

The archive step SHALL be stated as a role — closing the change's specification record — with the specification tooling named beneath it as one binding, exactly as `project-bootstrap` requires of every obligation in this fragment and as the fragment already does for its review dispatches. The tooling SHALL NOT appear in the role sentence.

The predecessor of this requirement permitted the opposite, and could: it governed a fragment `project-bootstrap` does not govern. Consolidation moves the obligation onto the file it does, so the permission is dropped rather than inherited.

#### Scenario: Delivery does not begin against unverified work

- **WHEN** a session reaches the delivery sequence and the change's verification has not been run against the branch head, or was run and failed
- **THEN** delivery does not begin, and no pull request is opened

#### Scenario: The code-review loop does not run unbounded

- **WHEN** a session has applied a review's findings, made substantial fixes, and re-reviewed three times without the review clearing
- **THEN** it reports where the loop stands and what is outstanding, and asks before dispatching a fourth

#### Scenario: A merge and its deploy are confirmed rather than assumed

- **WHEN** the first pull request has been opened and continuous integration has run
- **THEN** the session waits for the operator's confirmation of the merge and of the deploy's health before treating either as done

#### Scenario: A healthy deploy is not confirmation the change worked

- **WHEN** a change's work is merged and the deploy it triggers reports healthy
- **THEN** the record is not yet written, and the session proposes how the change's intended effect can be observed in production — what to look at, what provokes it, and what result would mean it worked — before asking for confirmation

#### Scenario: A change with no observable effect reaches its record

- **WHEN** a session reaches the confirmation gate for a refactor, dependency bump or internal cleanup and can identify no way for its effect to be observed in production
- **THEN** it says so plainly and names the class, the operator waives the gate, the waiver is recorded in the change's `gate-log.md`, and the record proceeds on the waiver — rather than the change stalling with an unremovable branch and working tree

#### Scenario: The record follows the confirmed effect

- **WHEN** the change's intended effect is confirmed in production
- **THEN** the record is archived in a commit of its own, on a branch of its own, and merged through the last of the change's pull requests

#### Scenario: A remedial cycle adds a pull request rather than reusing one

- **WHEN** a change's deploy is unhealthy, or its effect is absent through a defect in it, and the fix is made
- **THEN** the fix reaches the trunk through a pull request of its own, is reviewed, merged and deployed on the same terms as the original work, and the record still waits for a confirmed effect

#### Scenario: A failed deploy does not produce a record

- **WHEN** the pull request carrying a change's work is merged and the deploy it triggers is not healthy
- **THEN** the change is not treated as delivered, no record is written, and the fix re-enters the sequence at its review gate

#### Scenario: Production is not reached from a local machine

- **WHEN** a session holds credentials that would let it deploy directly to production
- **THEN** it does not, and the change reaches production by merging the first pull request, because a locally reachable production makes every gate above optional

#### Scenario: A deployed change that does not do what it was for

- **WHEN** the deploy is healthy and the change's intended effect is not present in production
- **THEN** the session distinguishes a defect in the change from the change having been the wrong change, and does not re-enter the fix sequence by default

#### Scenario: The wrong change reaches its record rather than stalling

- **WHEN** a change's effect is absent and the session and operator agree the change was the wrong change, to be superseded by a new proposal rather than corrected
- **THEN** the operator waives the confirmation gate, the waiver is recorded in `gate-log.md` naming that class, and the record proceeds — rather than the change stalling with a branch set and working tree that no route can remove

### Requirement: A change's branches are cut from the trunk, and its post-merge commits have one home

Delivery is the one phase in which a change holds more than one branch: the record takes one of its own, and each remedial cycle takes another. The workflow fragment SHALL state where each is cut from and where the commits made after the work merges are made. An act whose execution context is undefined is resolved by whoever implements first, and this is the act with the most branches to be wrong about.

**The branch set a change creates is the branches carrying its own work: the work branch, each remedial cycle's branch, and the record's branch.** A proposal-only branch opened under the change-queue requirement is not in it — that branch belongs to the change it proposes, is created and left, and takes no pull request here. It is recorded as **that** change's first branch, in that change's `gate-log.md`, and writing that record is within the "nothing further" the change-queue requirement permits. Excluded from one set and recorded in no other, it would appear in no enumeration at all, which is the state the recording rule exists to prevent. The set SHALL be delimited rather than left to a universal, because the rules below oblige a record for each member and the teardown gate is stated over the whole set: included, a proposal-only branch would be enumerated at teardown and checked against a pull request it will never have.

**Every branch in that set, the record's included, SHALL be cut from the freshly fetched trunk.** This is the rule the branch-creation requirement already states for a session's first branch, applied unchanged; delivery introduces further branches and no exception.

The record's branch carries the operator confirmations, a waiver where one is given, and the archive commit. A remedial cycle carries its own gate records — its branch, its pull request, its review dispatch and verdict — on its own branch alongside the work they concern, exactly as the first cycle did. The fragment SHALL state that split rather than a rule over every post-merge commit: a cycle's records belong with the code they gate, and a rule sending every post-merge commit to the record's branch would put a fix's diff in the record's pull request — the defect this route was chosen to avoid.

Nothing is lost by cutting from the trunk rather than from the work branch's tip. Every gate record written before the merge is a commit on the work branch and reaches the trunk with it; every record written after the merge — the merge confirmation, the deploy's health, the effect or its waiver — is written once the record's branch exists and is made there. No interval exists in which a record sits on a branch the trunk does not have.

Cutting from the trunk is also the only form that survives every merge strategy. Cut from a work branch that was squash-merged or rebase-merged, the record's branch shares no commit with the trunk's version of that work, so the record's pull request re-presents the entire work diff — the defect for which re-pushing the record on the work branch was rejected, reappearing in the route that replaced it. And a trunk that advanced while the deploy ran is fetched rather than diverged from, so the archive step applies the change's deltas to the specifications as they now are.

**The record's branch becomes the session's working branch**, unlike the proposal-only branch the change-queue requirement permits, which is created and left. The one-branch rule the branch-creation requirement states governs the branch a session works on at any moment; a change accumulates branches over its life and a session still holds one at a time.

**Each branch SHALL be recorded in `gate-log.md` when it is cut — or, for the change's first branch, when the change's root is created — and each pull request when it is opened**, the pull request naming the branch it was opened from. The first branch is cut before the change exists, so before the file does; recording it at the moment the root appears is the earliest satisfiable form of the same obligation. The branch is recorded at the earlier moment because the record's branch exists from the merge confirmation onward and its pull request may not open for several sessions; a change abandoned in that window would otherwise hold a branch that appears in no enumeration. Delivery makes a change's branch set unbounded, and the teardown gate below is stated over that set; without a recorded enumeration the set is knowable only to the session that created it, which is what the recording obligations exist to prevent. The reason the file is named applies here unchanged.

#### Scenario: The merge confirmation is committed on the record's branch

- **WHEN** the operator confirms a merge and the session records it
- **THEN** the record's branch has been cut from the freshly fetched trunk and the confirmation is committed on it, so it reaches the trunk with the archive commit

#### Scenario: A record branch does not re-present the work's diff

- **WHEN** a change's work is squash-merged and the record's branch is then created
- **THEN** it is cut from the freshly fetched trunk, so its pull request carries the record alone and not the work diff a second time

#### Scenario: A later session can enumerate a change's branches

- **WHEN** a session reaches teardown for a change delivered through more than one pull request, none of which it opened
- **THEN** each pull request and the branch it was opened from are readable in `gate-log.md`, so the teardown gate can be checked over the whole set rather than over the one branch the session can see

### Requirement: A session's branch and working tree are removed only against an observable gate

This gate governs a working tree in which a session is doing a change's work, per the scope stated above. A working tree outside that scope is not held by it; the workflow fragment SHALL state that as an exclusion and SHALL NOT assert that something else removes it, since no capability in this repository obliges anyone to.

The fragment SHALL state the condition under which a session's branches and working tree are removed as an observable one: **the change's record has reached the trunk through its own pull request, every other pull request the change opened is merged**, nothing uncommitted remains in the working tree, and nothing unpushed remains.

The record's pull request SHALL be named as its own conjunct rather than left to the universal over pull requests. A change whose work has merged but whose record does not yet exist satisfies "every pull request is merged" — it has one and it merged — so a gate stated that way passes at `ship:merged`, and teardown removes the working tree and every branch before the deploy is confirmed, before the effect is observed, and before the record exists. It also removes the record's branch, which is where the remaining post-merge commits were owed. The delivery requirement states that teardown waits for the record; a gate that does not say so is one an agent satisfies by reading the clause rather than the sequence.

The universal is likewise not enough on its own for the opposite reason. A change abandoned before any pull request was opened satisfies "every one of them is merged" vacuously, and a gate passed by having done nothing would authorise deleting unmerged work — for exactly the class of change the second route below exists to serve, bypassing that route rather than using it. Requiring the record's pull request closes this too: a change that opened none has no record on the trunk.

**The merge clause SHALL be stated against the pull request's state and not against branch ancestry.** A squash merge and a rebase merge put a branch's changes on the trunk without making the branch an ancestor of it, so an ancestry test reports every branch of every change unmerged in such a project and teardown never happens — the accumulation this requirement exists to prevent, produced by the check meant to authorise removal. The forge's report that a pull request merged holds under every strategy, and a forge is among the assumptions the publication requirement obliges the fragment to state.

The gate SHALL admit a second route, because a merge is not the only way a change legitimately ends: an abandonment the operator recorded satisfies it as a merge does. Stated with a merge as the only route, the gate can never be passed by an abandoned change, and its working tree and branch accumulate — the outcome this requirement exists to prevent, reached in the one case it forecloses.

That route SHALL be as observable as the first, or it is not a second route but a hole. The fragment SHALL name where the record lives — in the abandoned change's `gate-log.md`, with every other gate record — and SHALL require it to state that the change is abandoned and that the work on **every branch the change created** is not wanted. It is committed on the branch the session holds; the record's subject is the whole set, so which member carries it does not change what it says. A session entering a working tree left by another session cannot see the exchange in which an operator said so; a record it can read is what separates this route from the inference the requirement forbids.

The fragment SHALL state which clauses the record displaces, rather than leaving "satisfies it as a merge does" to be read either way:

- It displaces **both merge conjuncts** — the record's own pull request and the universal over the change's other pull requests — and the unpushed clause. All three concern commits on the abandoned branches, and the record is the operator's decision that those commits are not wanted. Stated as one "merge clause", the narrow reading leaves the record conjunct standing, so an abandoned change could never pass the gate and its branches accumulate — the unremovability this route exists to remove.
- It does **not** displace the uncommitted clause. Uncommitted changes in the working tree are not what the operator recorded a decision about — they may be unrelated or accidental — so teardown still halts and reports them, and the operator extends the decision or does not.

The record SHALL be committed before the gate is evaluated. Written and left uncommitted, it trips the one clause it does not displace, so the act that authorises teardown blocks it — and the stated remedy of extending the decision would then discard the record the route rests on.

Left unstated, the narrow reading blocks an abandoned branch that was never pushed, which is the permanent unremovability this route exists to remove; the broad reading silently discards uncommitted work on the strength of a decision that did not mention it.

Teardown SHALL cover **every branch the change created** — the work branch, each remedial cycle's branch, and the record's branch — locally and on the remote, and the working tree. A change delivered through more than one pull request holds more than one branch, and a gate written in the singular leaves every branch after the first outside its coverage, accumulating on the remote exactly as this requirement exists to prevent.

Each branch is checked on its own pull request, enumerated from `gate-log.md` where the requirement above records each one as it is opened. The branches are cut from the trunk rather than from one another, so no branch's state can be inferred from another's, and the gate SHALL require each to be observed rather than derived. The fragment SHALL state from where the working tree's removal is performed, since the tree the gate authorises removing is ordinarily the one the session is running in; an act whose execution context is undefined is resolved by the first implementer's guess. It does not cover the shared-service namespace the session allocated: reclaiming that belongs to a separate proposed capability, named in this requirement rather than in the fragment, and stating half of it in the fragment would leave a rule whose safety depends on clauses the fragment does not carry.

#### Scenario: Teardown is refused while work is unmerged

- **WHEN** a session reaches teardown and one of the change's pull requests is not merged, or the working tree holds uncommitted work, or a branch holds unpushed work
- **THEN** teardown does not proceed, and the unmet part of the gate is reported

#### Scenario: A merged work pull request does not by itself satisfy the gate

- **WHEN** a session confirms that a change's work pull request merged, and the change's record has not yet reached the trunk
- **THEN** teardown does not proceed, because the gate requires the record's own pull request and not merely that every pull request opened so far has merged

#### Scenario: A squash-merged change is still removable

- **WHEN** a change's pull requests are merged in a project whose forge squashes them, so no branch the change created is an ancestor of the trunk
- **THEN** the gate is satisfied, because its merge clause reads each pull request's state rather than branch ancestry

#### Scenario: The abandonment record does not block the teardown it authorises

- **WHEN** a session records an abandonment and then evaluates the teardown gate in the same session
- **THEN** the record is already committed in `gate-log.md` on the branch the session holds, so it does not itself trip the uncommitted clause the record does not displace

#### Scenario: An abandoned change's working tree can be removed

- **WHEN** a change is abandoned rather than merged, and the operator's decision is recorded in the change's `gate-log.md` stating that the work on every branch the change created is not wanted
- **THEN** the teardown gate is satisfied by that record in place of the merge, rather than leaving the branch and working tree permanently unremovable because a merge that will never happen is the only stated route

#### Scenario: An abandoned branch that was never pushed is still removable

- **WHEN** teardown runs on an abandoned change and one of its branches holds commits that were never pushed
- **THEN** the record displaces the unpushed clause as well as the merge clause, because both concern commits the operator recorded as unwanted

#### Scenario: Abandonment does not authorise discarding uncommitted work

- **WHEN** teardown runs on an abandoned change and the working tree holds uncommitted changes
- **THEN** teardown halts and reports them, because the recorded decision covers the branch's commits and not changes it never mentioned

#### Scenario: A later session can read the abandonment rather than infer it

- **WHEN** a session enters a working tree whose change a previous session abandoned
- **THEN** it finds the decision in the change's artifacts and can check the gate from the repository's own state, rather than inferring abandonment or refusing teardown indefinitely

#### Scenario: Teardown follows the record's pull request, not the work's

- **WHEN** a change is delivered through the pull requests the delivery requirement states
- **THEN** every branch the change created and the working tree are removed once the last pull request — the one carrying the record — has merged, since the change is not delivered until its record is on the trunk

### Requirement: A second change surfacing in a session is recorded in the change queue

The workflow fragment SHALL state that a session works on one change, and SHALL state what happens when a second change is identified while the first is in progress.

Where the change in progress depends on the identified change, the fragment SHALL require that the dependency and the wait it implies are recorded in the artifacts of the change in progress, before anything else is done about it. It MAY then permit offering a proposal for the identified change on a branch of its own and nothing further, and recommending that the work continue in a separate session.

Where the change in progress does not depend on the identified change, the fragment SHALL require that it is recorded either as a proposal on a branch of its own or as an entry in the project's **change queue**.

Where a proposal-only branch is created by either path, the fragment SHALL state that it is created and left: it does not become the session's working branch and gets no working tree of its own here.

**The fragment SHALL name the change queue's path as `docs/change-queue.md`, and SHALL NOT name `docs/deferred-work.md` for this purpose.** The two are distinct artifacts with distinct lifecycles, and the fragment SHALL state the distinction rather than leave a project to discover it:

- a **change queue** entry names an identified change and what it depends on, and is deleted when that change is archived. The working order is the file's own ordering of its entries, so deleting one closes the gap and no entry carries a position that another entry's deletion would falsify;
- a **deferred-work** entry names something the project has deliberately not done, and is deleted when it stops being true.

One entry is swept on being shipped and the other on being fixed, so an entry filed in the wrong artifact is either deleted early or kept forever. A project may hold both files; the fragment directs identified changes to the queue only.

The fragment SHALL state what happens where the adopting project has no change queue: it is created. An option that silently reduces to no option in a project lacking a file the fragment never told it to create is not an option.

The path is fixed here rather than left to the fragment's author for the reason `.claude/worktrees/` is fixed above: a path stated only in a change's own artifacts is archived with them, and a requirement whose subject is then unnameable cannot be checked against the fragment afterwards.

The fragment SHALL reconcile the second route against its own scope rule, which obliges out-of-scope work noticed during a change to become a separate proposed change rather than being folded in. The reconciliation SHALL be stated against that obligation rather than against a quoted string, since both now live in one document that will be reworded. The seam is that a change-queue entry *is* that separate proposed change, recorded rather than opened, and the obligation both rules share is that the work leaves the change in progress.

The fragment SHALL state that recording is the obligation and branching is the option. It SHALL give the reason the change queue exists outside the change: a deferral recorded only inside a change becomes unfindable when that change is archived, so it is the change succeeding, not the session ending, that loses it.

#### Scenario: A blocking dependency survives the session ending

- **WHEN** a session identifies that its change cannot complete until another change is merged, and the session then ends
- **THEN** the dependency and the wait are readable in the change's own artifacts, and the next session can distinguish a blocked change from a merely unfinished one

#### Scenario: An unrelated improvement is recorded rather than implemented

- **WHEN** a session identifies work outside its change's scope that nothing in the current change depends on
- **THEN** it is recorded as a proposal on its own branch or as an entry in the change queue, and is not implemented in the session that found it

#### Scenario: An identified change is not filed as deferred work

- **WHEN** a session records an identified change in a project that holds both `docs/change-queue.md` and `docs/deferred-work.md`
- **THEN** the entry goes to the change queue, where it will be deleted when that change is archived, rather than to the deferred-work file, where nothing would delete it

#### Scenario: The scope rule and the queue are one obligation

- **WHEN** a session records out-of-scope work as a change-queue entry
- **THEN** it has satisfied the fragment's scope rule too, because the fragment states that such an entry is that rule's separate proposed change recorded rather than opened

#### Scenario: The change queue does not yet exist

- **WHEN** a project carrying these rules has no file at the named path
- **THEN** the fragment directs creating it, rather than leaving the independent path with one route where it stated two

#### Scenario: A proposal-only branch does not become the session's working branch

- **WHEN** a session creates a proposal-only branch for work it identified but will not do here
- **THEN** the branch is created and left, taking no working tree and not becoming the branch this session works on

#### Scenario: A deferral outlives the change that recorded it

- **WHEN** a change that recorded a deferral inside its own artifacts is archived
- **THEN** the fragment has already directed the deferral into the project's change queue, so archiving the change does not remove it from view

### Requirement: A gate that did not run does not pass, and the project names what runs it

The workflow fragment SHALL require that a check which did not run is never counted as a check that passed, and SHALL require the project to make that structural rather than a matter of a session noticing.

**A skipped check SHALL fail the run that contains it, wherever the project can make it.** A verification that cannot reach what it needs skips and reports success, so a suite whose tier silently skipped is indistinguishable from one that passed — and a pull request has already been merged claiming a tier that had skipped. Session discipline is not the remedy: the session reading the result is the party the result deceives. The workflow fragment SHALL require the project to configure its continuous integration so that a dependency the verification requires but cannot reach fails the run rather than skipping it.

The clause is scoped to that cause deliberately. A skip a test declares for a reason of its own — a platform it does not apply to, an optional dependency the project genuinely treats as optional — is a stated decision, not a gate that failed to run, and a rule failing the run on every skip would oblige an adopting project either to delete legitimate skips or to carry a rule it knowingly violates.

**A local gate that was never installed SHALL NOT be relied on as one.** Commit hooks and push hooks exist only in a clone where someone installed them, so their silence is not a pass. The fragment SHALL require that whatever a completion claim rests on has an authority that runs regardless of a clone's local setup, and that a claim resting only on a local hook says so.

**A secret is kept out of version control by the ignore file, not by vigilance at commit time.** The fragment already directs a session to check what it is committing; that check is the second line. The first is that files holding secrets match a pattern the ignore file already covers, so committing one takes an override rather than an oversight. Non-secret configuration may be committed and SHALL be separated from secrets by that pattern rather than by intention.

**The workflow fragment SHALL require the project to state its test command and its test-path glob**, in its own conventions, as values a reader can copy. The fragment's own test-authoring step dispatches an independent author that requires both as inputs; a fragment that mandates the dispatch and never asks the project to supply what the dispatch needs states a gate no project can pass without inventing the inputs itself. Where a project has no test layer, it states that instead, as the exemption the test-authoring rule already provides for.

`project-foundation` already routes both values into a named section of a project's conventions file. That section satisfies this clause rather than a second statement being owed; the clause exists because the workflow fragment is adoptable by a project that never ran foundation discovery, and it is stated as a demand the existing section meets rather than as a second place to write them.

#### Scenario: A tier that skipped does not report a pass

- **WHEN** a verification tier cannot reach a dependency it requires, in continuous integration
- **THEN** the run fails rather than skipping, so no pull request is merged on the strength of a tier that did not execute

#### Scenario: A claim resting on an uninstalled hook

- **WHEN** a session reports verification as passing on the strength of a commit or push hook
- **THEN** it establishes that the hook is installed in this clone, or says that the claim rests on a local gate whose presence it has not confirmed

#### Scenario: A secret takes an override to commit, not an oversight

- **WHEN** a file holding secrets is created in a project carrying these rules
- **THEN** its name matches a pattern the ignore file already covers, so committing it requires deliberately overriding the ignore rather than failing to notice it

#### Scenario: The test-authoring dispatch has the inputs it requires

- **WHEN** a session reaches the test-design gate
- **THEN** the project's own conventions state the test command and the test-path glob, so the dispatch supplies them rather than inventing them

### Requirement: The database binding fragment states the shared database as an affordance before an obligation

The binding fragment SHALL name the database and the container the project actually runs, where the workflow fragment states the same obligations service-neutrally. Abstraction is what the workflow fragment's length is bought by removing, and a binding exists to spend it back in one place.

**The fragment SHALL state first that a real database is running and that the project's integration tests run against it** — not against a double, an in-memory substitute, or a different engine that is easier to reach from a working tree. Only then SHALL it state what must be provisioned before a verification result means anything.

The ordering is normative, and the reason is that the defensive statement does not imply the permissive one. A fragment that only warns the database may be hard to reach leaves a session free to substitute something reachable, which violates nothing it says while proving the code works against something other than the database production uses.

The fragment SHALL require a session to check for the running container before concluding that the database, or the container runtime, is unavailable.

The fragment SHALL state that what is isolated is the database and not the server: sessions share the running server and each takes its own database within it, named after its working tree in whatever form the project's naming constraints impose. It SHALL state that a session works in neither the project's development database nor another session's.

The fragment SHALL state that migrating is not seeding, and that a session reads a failing test's assertion message before concluding a failure is pre-existing.

The fragment SHALL NOT restate an obligation the workflow fragment already states. Where the workflow fragment requires an end state, the binding fragment names the operations that reach it.

#### Scenario: A session does not substitute a reachable double for the real database

- **WHEN** a session finds the project's integration tier unreachable from a fresh working tree
- **THEN** it provisions a database of its own against the running server, rather than substituting a double, an in-memory store, or a different engine

#### Scenario: Absence is asserted only after looking

- **WHEN** a session is about to report that the database or the container runtime is unavailable
- **THEN** it has checked the running containers first, and reports what it found

#### Scenario: A skipped tier is not reported as a pass

- **WHEN** a session runs verification in a working tree it has not finished provisioning, and the tier skips and reports success
- **THEN** the session reports verification as not run, and why, rather than as passing

#### Scenario: Two sessions do not share one database

- **WHEN** two sessions verify concurrently against the project's database server
- **THEN** each has its own database within it, named after its working tree, and neither writes to the project's development database
