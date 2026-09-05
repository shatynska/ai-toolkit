## REMOVED Requirements

### Requirement: Session-scoped rules are separate fragments cut by applicability

**Reason**: The property this requirement bought — each fragment adoptable without the others — has no consumer and never had one. No project adopted any of the three, because nothing could install them: `rules/` has no loader, the `@` import path is machine-local, and the one tool that inlines a fragment reads a single hardcoded path. Meanwhile the property is what made them long, since every gate had to be checkable inside the fragment stating it and no fragment could name a sibling. The obligations are consolidated into `rules/development-workflow.md`, which the tool already installs.

**Migration**: Every obligation the three fragments carried is restated by the requirements of this capability, retargeted at the workflow fragment. `rules/worktree-isolation.md`, `rules/change-delivery.md` and `rules/deferred-work.md` are deleted. No project imports them, so no consuming project is affected; a reader looking for them finds their content in the workflow fragment's body.

### Requirement: Session-scoped fragments declare a kind and, while nothing inlines them, no version

**Reason**: The requirement withheld a `version` for as long as no tool inlined the fragments, and anticipated its own lifting — "Should that change, the `version` key becomes owed by the requirements already cited, without this one being amended." That change is this one. The workflow fragment is inlined by `scripts/project-init` today; the database binding fragment will be, by the tooling change already queued. In the interval between this change landing and that one, the binding fragment carries a version nothing yet inlines — a bounded and named interval, rather than the open-ended one the removed requirement was written against.

**Migration**: `toolkit-structure` fixes the frontmatter's form and `project-bootstrap` owns the condition under which a version increments. Both apply to the workflow fragment already. The database binding fragment declares `kind: standing-constraint` and a `version` — permitted rather than owed until something inlines it, since `toolkit-structure` requires a version only of an inlined fragment and forbids one nowhere. Its increment becomes owed, and owned, when the tooling change inlines it.

### Requirement: A working tree is torn down only against an observable gate

**Reason**: Two of its scenarios assert properties this change removes — that the gate is satisfiable in a project with no remote, and that it is checkable without a delivery fragment. Both exist because the isolation fragment had to stand alone in a project that might have neither. With one document and a stated profile, they are dead clauses that a reader must decide to ignore. The requirement is replaced rather than amended because its scenarios, not only its prose, encode the removed property.

**Migration**: Replaced by "A change's branch and working tree are removed only against an observable gate", which keeps both routes, the displacement analysis, the commit-the-record-first clause and the execution-context clause, and drops the conditionals for a project with no remote and for a delivery rule stated elsewhere.

### Requirement: A change is delivered through a pull request that carries its own record

**Reason**: Its central scenario asserts that the change's record ships inside the pull request carrying the work. Where merging to the trunk triggers a deploy — which every project this library is written for does — that writes "this change shipped" at the moment the work was merely merged, and writes it identically where the deploy that followed failed.

**Migration**: Replaced by "A change is delivered through at least two pull requests, the last carrying its record", which keeps the entry gate, the tooling-precondition clause and the confirmed-never-inferred merge, and adds the deploy, the production-confirmation gate between the merge and the record, and a remedial cycle that carries its own pull request.

### Requirement: A second change surfacing in a session is recorded, not carried

**Reason**: Two of its clauses no longer hold. It names `docs/deferred-work.md` as the destination for an identified change, and that file already exists in this repository and in `commerce-ops` holding something else — what the project deliberately has not done, deleted when it stops being true, rather than an identified change, deleted when that change is archived. And its reconciliation scenario is written for a project carrying the inlined workflow rules alongside a separate deferred-work fragment — a pairing consolidation removes, since the two obligations now sit in one document and the seam between them is internal rather than cross-file.

**Migration**: Replaced by "A second change surfacing in a session is recorded in the change queue", which keeps the one-change rule, the dependent and independent paths, the proposal-only-branch clause and the reason the artifact sits outside the change, and routes identified work to `docs/change-queue.md` with the two artifacts' deletion conditions stated.

### Requirement: One session works in one branch and one working tree

**Reason**: The requirement is keyed to the session, and this change keys every working-tree rule to the change instead — a change outlives the sessions that work on it, and a session-keyed invariant lets a change acquire another branch and another working tree whenever a new session picks it up. Its title states the superseded keying, and one of its scenarios asserts the containment behaviour this change moves out of the fragment: that a recursive tool walking the repository is scoped or excluded by the ignore file, which is a one-time setup obligation recorded for the capability that owns project setup rather than an obligation any session discharges. A `MODIFIED` delta cannot drop that scenario — the tooling refuses, since a modified block replaces the whole requirement — so the requirement is replaced, as three others in this change are and for the same reason: the scenarios, not only the prose, encode what is being dropped.

**Migration**: Replaced by "A change works in one branch and one working tree", which keeps the one-branch-one-tree invariant, the fixed working-tree path, the serial-session clause and the scoping of the rules, restates the invariant as the change's, and adds the return to the freshly fetched trunk after each merge and the periodic rebase between. The containment obligations travel to `docs/change-queue.md` as `seed-the-worktree-ignore-entry`.

## MODIFIED Requirements

### Requirement: A rule states an action and a defect appears only as its reason

**A rule SHALL state what to do, and reasoning SHALL appear only where it changes what a reader does.** The fragment is inlined into a consuming project's conventions file and read by every session there, so its length is paid for on every read — brevity is the reason for the obligations below, not itself an obligation whose satisfaction anyone can test.

Three kinds of text SHALL NOT appear in the fragment, because each is written for this library rather than for the project holding the file: an argument against an alternative the fragment does not adopt, a statement about what other project shapes would need, and a justification for the fragment's own structure. Where such reasoning is worth keeping, it belongs in the change that decided it.

**Where this rule and a requirement obliging the fragment to state a particular reason conflict, the obliged reason wins.** A requirement that names a reason has decided that the reason changes what a reader does; brevity governs what is left. Unstated, the conflict is resolved by whoever edits last, which is how six mandated statements were dropped in a single compression pass.

Where such reasoning is additionally published so a session can seek it out — a skill, say — that publication SHALL carry reasoning only: an instruction, a gate, an exemption, or an edge case whose answer differs SHALL stay in the fragment, because a separately published document is loaded when something judges it relevant and there is no guarantee that happens at the moment it is needed. The fragment SHALL remain sufficient on its own. This binds any such publication when one is written; none exists today.

Each session-derived rule in the workflow fragment, and each rule in the database binding fragment, SHALL be phrased as an action to take. A defect, incident, or current shortcoming MAY appear only as the reason a stated action matters, never as a standing entry of its own.

Each rule SHALL be phrased so that its durable half is the instruction and its perishable half is the consequence. A rule built around a defect goes stale when the defect is fixed and, until someone notices, contradicts the fix.

A rule SHALL NOT be omitted on the grounds that the defect motivating it is being fixed, where the instruction survives the fix. The instruction and the damage are separable, and only the damage expires.

#### Scenario: A rule outlives the defect that motivated it

- **WHEN** the defect a rule cites as its reason is subsequently fixed, or is enforced more strictly
- **THEN** the rule's instruction is unchanged and still correct, and only the consequence it names is out of date

#### Scenario: The fragment carries no argument written for the library

- **WHEN** a rule is written into the fragment
- **THEN** it states what to do and, where reasoning changes what a reader does, states it in as few words as carry it — and carries no argument against a rejected alternative, no account of what another project shape would need, and no justification for the fragment's own structure

#### Scenario: An incident does not become a standing entry

- **WHEN** an incident from a consuming project is used as evidence for a rule
- **THEN** it appears as the reason that rule's action matters, and no rule consists of the incident alone

### Requirement: A session reports where its change stands before acting

The workflow fragment SHALL require a session, on entering a working tree, to report the state of the change it finds there before taking any other action on the change: which change it is, what stage it has reached, how far through its task list it is, what has been committed, and whether its verification currently passes.

**It SHALL require the same report as the last thing said before the session stops.** Orientation and hand-off are one obligation seen from two ends; a session that reports on arrival and not on departure leaves the next one to reconstruct what it already knew.

**The report SHALL be a single row of fixed cells, in a fixed order, and SHALL NOT be a paragraph.** The cells are the change's name, its stage named from the vocabulary below, its task progress, and its committed state. The entering report SHALL carry one further cell, the verification result, because that is the half a session arriving does not know and a session leaving does.

The fixed row is required rather than recommended because the report's whole purpose is to be read by a session that was not present. Prose is re-interpreted at every hand-off; a row in a known shape is read at a glance, and a missing cell shows as a gap rather than passing as an omission nobody notices.

That report SHALL be derived from the repository where the repository holds the fact — the change's own artifacts, the commit log, the forge, and an actual run of the verification. Where a fact is in none of them, the fragment SHALL direct asking rather than assuming.

**The obligation SHALL NOT be stated as a prohibition on recalled conversation.** An earlier form did, and it was true only while a ledger recorded every gate. With that removed, an operator's confirmation of a merge or a deploy is in no artifact, so a session that may not recall and has nothing to read is left with no route at all. Asking is the route, and it is stated.

The fragment SHALL state how this composes with provisioning, because the two do not compose on their own. The stage and the committed state are readable from the repository immediately. A verification result is not: a working tree that has not been provisioned produces a run that skips and reports success, so an orientation report assembled before provisioning states that verification passes on exactly the evidence the provisioning requirement below says is worthless. The fragment SHALL therefore require, at the provisioning rule and not at the report, that verification be reported as *not run, and why* until provisioning is complete. Stating it in both places puts a sentence about provisioning inside the description of a table cell, where the reason cannot fit and the rule is already stated a page earlier.

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

The obligations this capability governs SHALL be published in the two places named below, and in no further place a session must read alongside them to act correctly:

- `rules/development-workflow.md` — the workflow fragment, which states every obligation service-neutrally alongside the spec-driven gates it already carries, and which `scripts/project-init` inlines into a consuming project's conventions file;
- `rules/development-workflow-database.md` — the binding fragment, which binds the workflow fragment's provisioning and namespace obligations to a containerized relational database.

The workflow fragment SHALL state a role and name its binding beneath it, as it already does for the agents and the working-tree location it binds to Claude Code. The binding fragment SHALL NOT restate an obligation the workflow fragment states; it names the service, the naming form and the operations that reach the stated end state.

**The fragment SHALL name its unit of work before stating any rule about it.** The unit is a change, and every rule below is a rule about a change's life; a document that never says so leaves a reader to infer it from the rules themselves.

**It SHALL state what falls outside that unit and what happens to it.** Work too small to be a change skips `plan` — there is nothing to specify — and does not skip `ship`, since nothing reaches production except by merging. Unstated, the reader has two readings and neither is written down: that trivial work carries the whole process, or that it escapes the delivery rules too.

The qualifier SHALL sit in the opening rather than inside a rule. It governs whether the document applies at all, and a scope condition met halfway through has already been read as unconditional by anyone who stopped earlier.

**The workflow fragment SHALL assume a remote, pull requests, continuous integration, and that merging to the trunk deploys, and SHALL state no conditional for their absence.** Pull requests imply the forge whose merged-state report the teardown gate reads; naming it separately in the assumptions states twice what the gate states once. Every project these rules are written for has all of them. A conditional for a shape no consumer has is paid for by every reader of every project that does have one, and it is the class of text that made the previous publication expensive.

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

### Requirement: A change's stage is named from a fixed vocabulary

The report of where a change stands SHALL name the stage from a fixed vocabulary rather than describing it in prose. A prose description is re-read and re-interpreted by every session that resumes the work; a name from a closed set is read once.

**A stage SHALL name a state, never an act.** An act names what someone did or will do; a state names what is now true, which is what a report is for. The acts are the transitions between states, and the fragment SHALL state them, since the state names derive from them:

```
plan:   explore · draft · review · fix · approve · commit · derive tests
build:  apply · verify · review · fix
ship:   open pr · merge · deploy · confirm · archive
```

A state SHALL be `<family>:<transition>ing` while that transition runs and `<family>:<transition>ed` once it has happened.

**The transitions are the closed set; the states derive from them, and the fragment SHALL NOT enumerate every state.** An enumeration alongside a rule that generates the same names is a second source that drifts from the first, and it costs the fragment a paragraph on every read to say what one sentence already says.

The fragment SHALL state the transitions, the derivation rule, and enough examples to fix the pattern. It SHALL name the states the rule does not generate cleanly — `plan:tests-derived` and `ship:pr-open`, where the derivation reorders the words — and the two off-path names available in any family, `blocked:<what>` and `abandoned`.

Where a transition name matches a command the same session drives — `apply`, `archive`, `verify`, `review` — the state derived from it SHALL keep that word, so the operation remains recoverable from the stage.

**The `confirm` transition SHALL be stated as completing on either the operator's confirmation or a recorded waiver**, so `ship:confirmed` is true of a waived change rather than a name it lacks. A waiver is one of the two ways the gate is passed, not a way around it — the delivery requirement closes the record on either — and a transition stated as completing on only one of them leaves a session that has just recorded a waiver with no true stage between `ship:deployed` and `ship:archiving`, at the point in the sequence where the next session most needs to know where it stands. This is a statement about when the transition completes, not a licence to report a state that has not been reached.

**The family prefix SHALL always be written, and the vocabulary SHALL say so.** `plan:reviewing` and `build:reviewing` dispatch different reviewers — one reads the plan and refuses diffs — and the bare word names neither.

Both families SHALL share one review loop — `reviewing → fixing → reviewing` — since applying what a review returned is one act in two families, and stating it twice under two words would present two settings of one mechanism as two mechanisms.

The vocabulary SHALL NOT reuse one word for writing tests and running them: the `plan` transition producing tests from the change's specification deltas and the `build` transition running them against the implementation SHALL carry different words, so the states deriving from them cannot collapse into one. `plan:tests-derived` and `build:verifying` are given here to fix that distinction, not as names the fragment must write out — which state names it writes is governed by the enumeration prohibition above.

`plan:exploring` SHALL name a change with no proposal yet, whose auxiliary artifacts — a handoff — may exist.

**No rule SHALL require that every stage be derivable from the repository, and no ledger SHALL be mandated to make one so.** The stage is reported for the operator's information; a stage reported imprecisely costs a sentence of correction. An artifact recording every gate so that a resuming session could name the stage exactly would be paid for on every change to buy a precision nothing depends on. What a later session must be able to check is covered by the requirement below, which is about decisions rather than about stages.

**The commit rules SHALL state what happens to a commit made while applying, because otherwise they contradict themselves there.** They direct running the verification relevant to what changed before committing; the tests derived before the implementation fail by design until the implementation is complete. So for the whole of `build:applying` the rule requires a check that cannot pass, and a project whose hooks run it cannot commit at all.

The fragment SHALL name the bypass — `--no-verify` — rather than describing one, and SHALL say that the failure is expected rather than a defect. A session that must work the bypass out for itself has been left to guess whether it is breaking a rule, at every commit of the longest stage.

The fragment SHALL state that the bypass suspends the pre-commit check and not the gate: verification still runs before any completion claim. A bypass stated without its bound is read as permission to skip the check it stands in for.

#### Scenario: A commit made while applying is not blocked by tests written to fail

- **WHEN** a session commits partway through implementing, and the derived tests do not yet pass
- **THEN** it bypasses the hooks that run them, and the verification gate before any completion claim still applies

#### Scenario: A resuming session names the stage without interpreting prose

- **WHEN** a session enters a working tree holding a change another session left
- **THEN** it reads the stage from the change's artifacts, the commit log and the forge and names it from the vocabulary, rather than reconstructing a description

#### Scenario: Writing tests and running tests are not one word

- **WHEN** a report names a stage involving tests
- **THEN** `plan:tests-derived` names tests being derived from the specification deltas and `build:verifying` names tests being run against the implementation, and neither name is used for the other

#### Scenario: The vocabulary is not enumerated beside the rule that generates it

- **WHEN** the fragment states the stage vocabulary
- **THEN** it states the transitions, the derivation rule, examples, the two states whose derivation reorders and the off-path names, and does not list every derived state

#### Scenario: An imprecise stage is not treated as a defect worth an artifact

- **WHEN** a session reports a stage that turns out to be one step off
- **THEN** the correction is a sentence, and no rule requires a ledger written on every change so that the case cannot arise

### Requirement: A production-confirmation waiver is recorded

**A production-confirmation waiver SHALL be recorded in the change's own artifacts**, and it is the only record this requirement adds beyond the artifacts a change already carries.

The change's record is archived on the strength of the waiver, and the specification that archive writes to the trunk then describes behavior production does not have. The waiver is the only trace of why.

No further record SHALL be required, and the requirement SHALL say so, because the obvious candidates each look load-bearing and are not:

- **A review's verdict.** The rules already require the approved plan to be committed before tests are derived from it, so a committed plan is the marker that a verdict cleared it. A separate record states the same fact twice, and a session could write a false one as easily as it could commit an unapproved plan. What it would buy is the occasional re-dispatched review, which returns the same verdict.
- **An operator's confirmation** of a merge or a deploy. It gates nothing a later session cannot ask about again.
- **A dispatch in flight.** It matters only where a session ends mid-review.
- **A pull request.** The forge reports it.
- **An abandonment.** Required already, by the teardown gate below, as the condition of its own second route.

The residual cost of requiring none of these is a conditional pass whose `[MINOR]` fixes a later session cannot see are outstanding. That is bounded by those fixes being minor, and it is smaller than a record written on every change forever.

#### Scenario: A waived change carries the reason to the trunk

- **WHEN** a change's production-confirmation gate is waived and its record archived
- **THEN** the waiver is recorded in the change's artifacts, so a reader meeting the archived specification can find why it describes behavior production does not have

#### Scenario: A verdict is not recorded, and the commit stands for it

- **WHEN** a session resumes a change whose plan is committed and whose tests are derived
- **THEN** it implements, taking the commit as the marker that a verdict permitted proceeding, rather than looking for a verdict record or re-dispatching the review

#### Scenario: A confirmation nobody recorded is simply asked again

- **WHEN** a session ends after the operator confirmed a merge, and the next session needs to know
- **THEN** it asks, rather than the rules having required a record for it

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

The exemption SHALL be: where the session can propose no observation that can actually be made — including one it proposed and that turns out not to be performable — it says so plainly and names the class, and the operator waives the gate. The waiver SHALL be recorded in the change's own artifacts, and it is what the record then rests on in place of a confirmed effect. It is a waiver stated in advance for a named class, not a gap discovered at the gate — the distinction `project-bootstrap` requires of every precondition this fragment states.

Saying so plainly is still owed. What the exemption removes is the stall, not the disclosure: a change whose effect nobody can observe is worth knowing about before it is archived as shipped.

Only once the effect is confirmed, **or the waiver recorded**, SHALL the record be closed: the change's branch brought back to the freshly fetched trunk, its specification record committed there, and a pull request opened for it — the last of the change's pull requests, however many the work took. The record's subject is that the change shipped, so it cannot precede the shipping.

Where the deploy is not healthy, the fragment SHALL state that the change is not delivered and the record is not written, and that the remedy re-enters the sequence at its review gate rather than continuing past it — carrying its own pull request, as any work reaching the trunk does.

Where the deploy is healthy and the intended effect is absent, the fragment SHALL require the session to distinguish a defect in the change from the change having been the wrong change — which is a new proposal, not a correction — and SHALL state a terminal for each. A defect re-enters the sequence at its review gate. The wrong change does not, and its terminal SHALL be stated rather than left open.

**The wrong change is the confirmation gate's second waivable class**, named in advance on the same terms as the first: a change whose proposed observation was made, whose effect is absent, and which is **not to be corrected in place**. Being superseded by a new proposal is the typical case and SHALL NOT be a defining condition — a change judged wrong and reverted, or simply dropped, satisfies the class as fully, and a definition requiring a successor would leave it in neither class and back at the dead end this exemption exists to close.

The session says so plainly and names the class, the operator waives, the waiver is recorded in the change's own artifacts, and the record proceeds on it. **Where a successor is intended, the waiver SHALL name its change-queue entry or the branch it was opened on.** This class is the one whose defining fact is a decision rather than an observation, so what it leaves behind is the only trace of why a change was archived as shipped while its effect was confirmed absent — and the specification the archive step writes to the trunk then describes behaviour production does not have. A reader meeting that specification later is owed the pointer.

Without that terminal the path dead-ends. The record cannot be written, because the effect is unconfirmed. The first waivable class does not reach it, because an observation *was* proposed and made — and improvising an exemption at the gate is what stating exemptions in advance forbids. The abandonment route does not reach it either, because that record must assert the work on the change's branch is not wanted, and this work is merged, deployed and running. A compliant session would stop with a branch and a working tree it can never remove, which is the accumulation this capability exists to prevent, reached down a path the fragment itself names.

The record is truthful on this route: the change shipped, and what it shipped did not do what was wanted. That is what the waiver records, and it is worth having on the trunk rather than lost with the session that discovered it.

**The deploy pipeline SHALL be the only path to production.** The fragment SHALL state that the command that deploys is never run locally against production, and that a change reaches production by merging and by nothing else. Local credentials for the production environment, where they exist at all, are for reading — a plan, a status, a log — and not for applying.

Without this, every gate above is optional. A session that can deploy from its own machine can reach production without a pull request, without continuous integration, and without the review that the pull request exists to obtain; the whole sequence becomes a convention rather than a constraint, and nothing reports the one time it was skipped.

The archive step SHALL be stated as a role — closing the change's specification record — and SHALL name no command.

The fragment names agents in its bindings and no command-line tool anywhere: it does not say which command applies a change, or verifies one, or opens a pull request. Naming one at the archive step alone would present the project's specification tooling as though the workflow turned on that one invocation, when every other step leaves the tool to the project. The tooling is named among the fragment's assumptions instead, which is where a project reads what these rules presuppose.

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
- **THEN** it says so plainly and names the class, the operator waives the gate, the waiver is recorded in the change's own artifacts, and the record proceeds on the waiver — rather than the change stalling with an unremovable branch and working tree

#### Scenario: The record follows the confirmed effect

- **WHEN** the change's intended effect is confirmed in production
- **THEN** the change's one branch is brought back to the freshly fetched trunk, the record is archived there in a commit of its own, and it is merged through the last of the change's pull requests

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
- **THEN** the operator waives the confirmation gate, the waiver is recorded in the change's own artifacts naming that class, and the record proceeds — rather than the change stalling with a branch and working tree that no route can remove

### Requirement: A change works in one branch and one working tree

**Every working-tree rule SHALL be keyed to the change**, not to the session or to working trees in general: a change's branch, a change's working tree, the change's record. So phrased, the rules bind nothing that is not a change's, and a working tree tooling creates for a single act — a cold-run check of an agent under authoring, for example — falls outside them without an exclusion being written.

An earlier form keyed the rules to a session's working tree and needed such an exclusion, since a cold-run tree is also a session's. It also needed a clause saying that contents do not decide the question, because a working tree created from a committed ref carries whatever that commit held, a change's own artifacts included. Keying to the change removes both.

The fragment SHALL NOT carry the exclusion. A scope statement defending against a reading the text no longer invites is text a reader must understand before discovering it is inert, and the case that motivated it — `agent-authoring`'s mandated cold-run working tree — exists in this library and not in the projects the fragment is written for.

**The fragment SHALL state the invariant as one change, one branch, one working tree**, not as one session's. A change outlives the sessions that work on it — which is what the orientation report above exists for — so binding the branch and the working tree to the session says a change may acquire another of each whenever a new session picks it up.

The fragment SHALL state that several sessions may work on one change, one after another and never concurrently, and that a session resuming a change enters the working tree that change already has. Two concurrent sessions on one change would share a working tree, which the containment reason below forbids.

**A change SHALL keep that one branch from proposal to record.** Delivery merges it more than once — the work, then the record — and the fragment SHALL direct bringing it back to the freshly fetched trunk after each merge before continuing on it.

The fragment SHALL also direct fetching the trunk periodically and rebasing onto it while the change is in progress, not only when the branch is cut. A change that spans several sessions diverges from a trunk other changes are merging into, and a divergence first met at the pull request is one nobody chose the moment to deal with.

**Fetching, rebasing and merging SHALL be scoped separately, and the fragment SHALL give a route for each part of the change's life rather than stopping at one.** Fetching is not destructive and continues throughout. Before the branch is pushed, the trunk is brought in by rebasing. After, it is brought in by merging, since a rebase then needs a force push over a branch under review where a merge does not.

Stated as a single instruction that stops at the push, the rule leaves a session with no way to stay current for the whole of `ship` — which is where a change waits longest and the trunk moves most. An incomplete route is worse than a stated one: a session that needs the trunk and has been told only what not to do will force-push.

Reusing the branch is stated rather than left open because the alternative a session would otherwise reach for is a second branch, and the reasoning against it is not obvious: a branch left at its pre-merge tip re-presents the whole work diff in the record's pull request under a squash or rebase merge, and a trunk that advanced while the deploy ran is diverged from rather than fetched. Returning to the trunk answers both, and one branch per change makes the teardown gate a check on one branch rather than on a set no later session can enumerate.

The obligation that a session carries only one change at a time belongs to the change-queue requirement below and is not restated here.

It SHALL name the location of a change's working tree as a fixed path within the repository — `.worktrees/`, one directory per working tree — rather than describing it as a path the project chooses, since the containment obligations below are checks against a path and a path left to choice makes them uncheckable.

The path SHALL be harness-neutral. Where a harness creates working trees at a path of its own and will not enter one elsewhere, that path SHALL be named beneath the rule as that harness's binding, and the containment obligations SHALL cover both roots. Naming a harness's directory in the rule itself would put one tool inside an obligation the fragment states tool-neutrally.

**The containment obligations that location carries SHALL NOT be stated in the fragment.** Naming the working-tree root in the repository's ignore file, and scoping every recursive tool that does not read that file so it cannot descend into one, are discharged once when a project is set up and once when a tool is added — never by a session working a change. They belong to the capability that owns project setup, per the requirement below, and are recorded there.

Naming them here would put two setup acts in a document read on every change, to prevent sibling trees filling `git status`, `git add -A` committing one as an embedded repository, and one session's run including another's source tree. Each is worth preventing; none is prevented by a session reading a rule.

#### Scenario: A working tree carrying no change is not held by these rules

- **WHEN** tooling creates a working tree that holds no change and no branch destined for the trunk — a cold-run check, say — and removes it when done
- **THEN** the one-tree rule and the teardown gate do not bind it, because the fragment scopes its rules to a change's working tree and this is not one

#### Scenario: A long-running change does not first meet the trunk at its pull request

- **WHEN** a change spans several sessions while other changes merge to the trunk
- **THEN** the fragment has directed fetching and rebasing onto the trunk periodically, so divergence is met while the work is in hand rather than at the pull request

#### Scenario: Two sessions do not share a working tree

- **WHEN** a second session begins work on the same repository while a first is in progress
- **THEN** it works in its own working tree on its own branch, rather than sharing the working tree, index or checked-out branch of the first

### Requirement: A change's branch and working tree are removed only against an observable gate

This gate governs a working tree in which a session is doing a change's work, per the scope stated above. Because every working-tree rule is keyed to the change, a working tree that is not a change's falls outside this gate without an exclusion being written, and the requirement above forbids writing one.

The fragment SHALL state the condition under which a change's branch and working tree are removed as an observable one: **the change's record has reached the trunk through its own pull request, every other pull request the change opened is merged**, nothing uncommitted remains in the working tree, and nothing unpushed remains.

The record's pull request SHALL be named as its own conjunct rather than left to the universal over pull requests. A change whose work has merged but whose record does not yet exist satisfies "every pull request is merged" — it has one and it merged — so a gate stated that way passes at `ship:merged`, and teardown removes the working tree and every branch before the deploy is confirmed, before the effect is observed, and before the record exists. It also removes the record's branch, which is where the remaining post-merge commits were owed. The delivery requirement states that teardown waits for the record; a gate that does not say so is one an agent satisfies by reading the clause rather than the sequence.

The universal is likewise not enough on its own for the opposite reason. A change abandoned before any pull request was opened satisfies "every one of them is merged" vacuously, and a gate passed by having done nothing would authorise deleting unmerged work — for exactly the class of change the second route below exists to serve, bypassing that route rather than using it. Requiring the record's pull request closes this too: a change that opened none has no record on the trunk.

**The merge clause SHALL be stated against the pull request's state and not against branch ancestry.** A squash merge and a rebase merge put a branch's changes on the trunk without making the branch an ancestor of it, so an ancestry test reports every branch of every change unmerged in such a project and teardown never happens — the accumulation this requirement exists to prevent, produced by the check meant to authorise removal. The forge's report that a pull request merged holds under every strategy, and a forge is implied by the pull requests the publication requirement obliges the fragment to assume.

The gate SHALL admit a second route, because a merge is not the only way a change legitimately ends: an abandonment the operator recorded satisfies it as a merge does. Stated with a merge as the only route, the gate can never be passed by an abandoned change, and its working tree and branch accumulate — the outcome this requirement exists to prevent, reached in the one case it forecloses.

That route SHALL be as observable as the first, or it is not a second route but a hole. The fragment SHALL name where the record lives — in the abandoned change's own artifacts — and SHALL require it to state that the change is abandoned and that the work on its branch is not wanted. A session entering a working tree left by another session cannot see the exchange in which an operator said so; a record it can read is what separates this route from the inference the requirement forbids.

The fragment SHALL state which clauses the record displaces, rather than leaving "satisfies it as a merge does" to be read either way:

- It displaces **both merge conjuncts** — the record's own pull request and the universal over the change's other pull requests — and the unpushed clause. All three concern commits on the abandoned branch, and the record is the operator's decision that those commits are not wanted. Stated as one "merge clause", the narrow reading leaves the record conjunct standing, so an abandoned change could never pass the gate and its branches accumulate — the unremovability this route exists to remove.
- It does **not** displace the uncommitted clause. Uncommitted changes in the working tree are not what the operator recorded a decision about — they may be unrelated or accidental — so teardown still halts and reports them, and the operator extends the decision or does not.

The record SHALL be committed before the gate is evaluated. Written and left uncommitted, it trips the one clause it does not displace, so the act that authorises teardown blocks it — and the stated remedy of extending the decision would then discard the record the route rests on.

Left unstated, the narrow reading blocks an abandoned branch that was never pushed, which is the permanent unremovability this route exists to remove; the broad reading silently discards uncommitted work on the strength of a decision that did not mention it.

Teardown SHALL cover the change's branch, locally and on the remote, and the working tree. Because a change keeps one branch, the gate checks one branch against the set of pull requests opened from it, and no enumeration of branches is owed. The fragment SHALL state from where the working tree's removal is performed, since the tree the gate authorises removing is ordinarily the one the session is running in; an act whose execution context is undefined is resolved by the first implementer's guess. It does not cover the shared-service namespace the session allocated: reclaiming that belongs to a separate proposed capability, named in this requirement rather than in the fragment, and stating half of it in the fragment would leave a rule whose safety depends on clauses the fragment does not carry.

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
- **THEN** the record is already committed in the change's own artifacts on the branch the session holds, so it does not itself trip the uncommitted clause the record does not displace

#### Scenario: An abandoned change's working tree can be removed

- **WHEN** a change is abandoned rather than merged, and the operator's decision is recorded in the change's own artifacts stating that the work on its branch is not wanted
- **THEN** the teardown gate is satisfied by that record in place of the merge, rather than leaving the branch and working tree permanently unremovable because a merge that will never happen is the only stated route

#### Scenario: An abandoned branch that was never pushed is still removable

- **WHEN** teardown runs on an abandoned change whose branch holds commits that were never pushed
- **THEN** the record displaces the unpushed clause as well as the merge clause, because both concern commits the operator recorded as unwanted

#### Scenario: Abandonment does not authorise discarding uncommitted work

- **WHEN** teardown runs on an abandoned change and the working tree holds uncommitted changes
- **THEN** teardown halts and reports them, because the recorded decision covers the branch's commits and not changes it never mentioned

#### Scenario: A later session can read the abandonment rather than infer it

- **WHEN** a session enters a working tree whose change a previous session abandoned
- **THEN** it finds the decision in the change's artifacts and can check the gate from the repository's own state, rather than inferring abandonment or refusing teardown indefinitely

#### Scenario: Teardown follows the record's pull request, not the work's

- **WHEN** a change is delivered through the pull requests the delivery requirement states
- **THEN** the change's branch and working tree are removed once the last pull request — the one carrying the record — has merged, since the change is not delivered until its record is on the trunk

### Requirement: A second change surfacing in a session is recorded in the change queue

The workflow fragment SHALL state that a session works on one change, and SHALL state what happens when a second change is identified while the first is in progress.

Where the change in progress depends on the identified change, the fragment SHALL require that the dependency and the wait it implies are recorded in the artifacts of the change in progress, before anything else is done about it. It MAY then permit opening the identified change on a branch of its own and nothing further, and recommending that the work continue in a separate session.

**An identified change SHALL be opened with a `handoff.md` and no proposal.** A proposal is the artifact the workflow reviews before anything is built. Written in passing by a session that will not do the work, it draws that review before it has earned it — and a review round spent on a proposal nobody has thought through is a round spent, not a round passed.

`handoff.md` SHALL carry what the originating session knows and the next will not: why the change was identified, what the originating work established that bears on it, and what it must not undo. The session that takes the change up writes its proposal.

`handoff.md` SHALL sit at the identified change's root, where the change's own artifacts sit.

The name SHALL NOT be reserved to this use. A change that already has a proposal MAY carry a `handoff.md` for something else — a survey handed from one session to another, say — so what marks an *identified* change is the handoff standing where a proposal is not, rather than the filename alone.

**The fragment SHALL direct proposing a commit on that branch as soon as it is opened**, and SHALL state what happens where that commit is declined: report that the handoff is unsaved and stop, as the plan-commit rule does, rather than continuing and leaving it to be lost. The session that opened it is by definition not returning to it, so no later commit will carry the handoff and an uncommitted one is lost with the session. It is proposed rather than made, per the fragment's commit rule.

The path SHALL be fixed here, at the identified change's root, for the reason `docs/change-queue.md` and `.worktrees/` are fixed: a location stated only in a change's own artifacts is archived with them.

Where the change in progress does not depend on the identified change, the fragment SHALL require that it is either opened on a branch of its own, carrying the handoff the clauses above state, or recorded as an entry in the project's **change queue**.

Where such a branch is created by either path, the fragment SHALL state that it is created and left: it does not become the session's working branch and gets no working tree of its own here. The branch carries the identified change's handoff and no proposal, so it is not named for a proposal — the term this requirement's predecessor used, and the one this change replaces.

**The fragment SHALL name the change queue's path as `docs/change-queue.md`, and SHALL NOT name `docs/deferred-work.md` for this purpose.** The two are distinct artifacts with distinct lifecycles, and the fragment SHALL state the distinction rather than leave a project to discover it:

- a **change queue** entry names an identified change and what it depends on, and is deleted when that change is archived. The working order is the file's own ordering of its entries, so deleting one closes the gap and no entry carries a position that another entry's deletion would falsify;
- a **deferred-work** entry names something the project has deliberately not done, and is deleted when it stops being true.

One entry is swept on being shipped and the other on being fixed, so an entry filed in the wrong artifact is either deleted early or kept forever. A project may hold both files; the fragment directs identified changes to the queue only.

The fragment SHALL state what happens where the adopting project has no change queue: it is created. An option that silently reduces to no option in a project lacking a file the fragment never told it to create is not an option.

The path is fixed here rather than left to the fragment's author for the reason `.worktrees/` is fixed above: a path stated only in a change's own artifacts is archived with them, and a requirement whose subject is then unnameable cannot be checked against the fragment afterwards.

The fragment SHALL reconcile the second route against its own scope rule, which obliges out-of-scope work noticed during a change to become a separate proposed change rather than being folded in. The reconciliation SHALL be stated against that obligation rather than against a quoted string, since both now live in one document that will be reworded. The seam is that a change-queue entry *is* that separate proposed change, recorded rather than opened, and the obligation both rules share is that the work leaves the change in progress.

The fragment SHALL state that recording is the obligation and branching is the option. It SHALL give the reason the change queue exists outside the change: a deferral recorded only inside a change becomes unfindable when that change is archived, so it is the change succeeding, not the session ending, that loses it.

#### Scenario: A blocking dependency survives the session ending

- **WHEN** a session identifies that its change cannot complete until another change is merged, and the session then ends
- **THEN** the dependency and the wait are readable in the change's own artifacts, and the next session can distinguish a blocked change from a merely unfinished one

#### Scenario: An unrelated improvement is recorded rather than implemented

- **WHEN** a session identifies work outside its change's scope that nothing in the current change depends on
- **THEN** it is opened on a branch of its own carrying a handoff, or recorded as an entry in the change queue, and is not implemented in the session that found it

#### Scenario: An identified change is not filed as deferred work

- **WHEN** a session records an identified change in a project that holds both `docs/change-queue.md` and `docs/deferred-work.md`
- **THEN** the entry goes to the change queue, where it will be deleted when that change is archived, rather than to the deferred-work file, where nothing would delete it

#### Scenario: The scope rule and the queue are one obligation

- **WHEN** a session records out-of-scope work as a change-queue entry
- **THEN** it has satisfied the fragment's scope rule too, because the fragment states that such an entry is that rule's separate proposed change recorded rather than opened

#### Scenario: The change queue does not yet exist

- **WHEN** a project carrying these rules has no file at the named path
- **THEN** the fragment directs creating it, rather than leaving the independent path with one route where it stated two

#### Scenario: An identified change is opened without a proposal

- **WHEN** a session opens a change it has identified but will not work on
- **THEN** the change carries a `handoff.md` naming why it was identified, what bears on it and what it must not undo, and no `proposal.md` — which the session that takes it up writes

#### Scenario: A handoff is not left uncommitted on a branch the session leaves

- **WHEN** a session opens an identified change on a branch of its own and then continues with its own change
- **THEN** it has proposed a commit on that branch already, because no later commit of its own will carry the handoff

#### Scenario: An opened-and-left branch does not become the session's working branch

- **WHEN** a session opens a branch for work it identified but will not do here
- **THEN** the branch is created and left, taking no working tree and not becoming the branch this session works on

#### Scenario: A deferral outlives the change that recorded it

- **WHEN** a change that recorded a deferral inside its own artifacts is archived
- **THEN** the fragment has already directed the deferral into the project's change queue, so archiving the change does not remove it from view

### Requirement: A one-time setup obligation does not belong in the fragment

The fragment is read by every session in an adopting project, so it SHALL carry only obligations a session acts on. An obligation discharged once when a project is set up — configuring continuous integration, choosing an ignore pattern, writing a value into the project's conventions — SHALL NOT appear in it, however sound the obligation is.

Four such rules were drawn from two consuming projects and placed in the fragment before this was stated: continuous integration failing rather than skipping on a dependency it cannot reach, a commit or push hook not being an authority a completion claim may rest on, secrets excluded by the ignore file rather than by vigilance, and the project stating its test command and test-path glob. Each is worth keeping and none belongs here. Where such an obligation is found while working on the fragment, it SHALL be recorded for the capability that owns project setup rather than added.

Two of the four were also already covered. `project-foundation` obliges a project to write its test command and test-path glob into a named section of its conventions, so the fragment restating it gave one obligation two owners. And the fragment's provisioning rule already states that verification which cannot reach what it needs skips and reports success — the principle the skipped-check rule was carrying, at the point a session meets it.

#### Scenario: A setup obligation found while writing the fragment is recorded, not added

- **WHEN** an obligation is identified that a project discharges once at setup rather than a session discharging per change
- **THEN** it is recorded for the capability that owns project setup, and the fragment does not carry it

#### Scenario: The skipped-check principle is stated once

- **WHEN** a session reads a green verification result it has not provisioned for
- **THEN** the provisioning rule has already told it that such a run skips and reports success, and no second rule states the same thing elsewhere in the fragment

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
- **THEN** the binding fragment has stated the database the tier needs as a step to be reached before a result from it means anything, rather than leaving the skip to be noticed, rather than as passing

#### Scenario: Two sessions do not share one database

- **WHEN** two sessions verify concurrently against the project's database server
- **THEN** each has its own database within it, named after its working tree, and neither writes to the project's development database
