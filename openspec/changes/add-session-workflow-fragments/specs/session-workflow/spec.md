## Purpose

Defines what this library's session-scoped rule fragments must say: how a session isolates its work from other sessions running in parallel against the same repository and the same shared services, how a completed change is delivered, and how knowledge that outlives a session is recorded rather than lost with it. It governs fragment content only; `toolkit-structure` owns a fragment's form and `project-bootstrap` owns the workflow fragment that a bootstrapping tool inlines, neither of which this capability touches.

## ADDED Requirements

### Requirement: Session-scoped rules are separate fragments cut by applicability

The obligations governing parallel sessions SHALL be published as separate `rules/` fragments, one per axis of applicability, rather than as a single fragment or as fragments divided by phase of work. The set is:

- `rules/worktree-isolation.md` — isolating a session's working state;
- `rules/change-delivery.md` — delivering a completed change;
- `rules/deferred-work.md` — recording work that outlives the session.

These three are the session-scoped fragments this capability governs. Requirements below that address "the isolation fragment", "the delivery fragment" or "the deferred-work fragment" address the file named here.

Each fragment SHALL be adoptable without the others. No session-scoped fragment SHALL name another session-scoped fragment, and no session-scoped fragment's rules SHALL depend on a sibling session-scoped fragment being present in the adopting project. This constrains references among the three named above and does not restrict a reference to a fragment outside that set.

Where two fragments describe adjacent steps, each SHALL state its own gate as an observable condition it can check by itself, rather than as the completion of a step stated in the other. A gate expressed as "after the other fragment's step" is unsatisfiable in a project that adopted only one of them, which defeats the separation.

A division by phase of work is specifically excluded. Setting up a working tree and tearing it down are one invariant seen from two ends; delivering through a pull request is a different axis from either. A phase-based division separates the two halves of the invariant and welds delivery to teardown, so that no project can adopt one axis without the other.

Restatement of shared context across fragments SHALL NOT be treated as duplication to be eliminated. Independence is the property being bought and a bounded amount of repetition is its price.

#### Scenario: A project adopts isolation without delivery

- **WHEN** a project with no remote adopts only the working-tree isolation fragment
- **THEN** every gate that fragment states is checkable within it, including the condition under which a working tree may be torn down, and no rule refers to a delivery step the project has not adopted

#### Scenario: A project adopts delivery without isolation

- **WHEN** a project that runs sessions serially adopts only the delivery fragment
- **THEN** the fragment's rules name no working tree and no branch-per-session obligation, and are satisfiable from whatever branch the project works on

#### Scenario: Setup and teardown are not separated

- **WHEN** the fragments are divided
- **THEN** creating a session's working tree and tearing it down are stated in the same fragment, so a project cannot adopt creation without the gate that ends it

### Requirement: A rule states an action and a defect appears only as its reason

Each rule in a session-scoped fragment SHALL be phrased as an action to take. A defect, incident, or current shortcoming MAY appear only as the reason a stated action matters, never as a standing entry of its own.

Each rule SHALL be phrased so that its durable half is the instruction and its perishable half is the consequence. A rule built around a defect goes stale when the defect is fixed and, until someone notices, contradicts the fix.

A rule SHALL NOT be omitted on the grounds that the defect motivating it is being fixed, where the instruction survives the fix. The instruction and the damage are separable, and only the damage expires.

#### Scenario: A rule outlives the defect that motivated it

- **WHEN** the defect a rule cites as its reason is subsequently fixed, or is enforced more strictly
- **THEN** the rule's instruction is unchanged and still correct, and only the consequence it names is out of date

#### Scenario: An incident does not become a standing entry

- **WHEN** an incident from a consuming project is used as evidence for a rule
- **THEN** it appears as the reason that rule's action matters, and no rule consists of the incident alone

### Requirement: A session reports where its change stands before acting

The isolation fragment SHALL require a session, on entering a working tree, to report the state of the change it finds there before taking any other action on the change: what stage the change has reached, whether its verification currently passes, and what has been committed.

That report SHALL be derived from the repository — the change's own artifacts, the commit log, and, except as the composition clause below provides, an actual run of the verification — and SHALL NOT be assembled from recalled conversation. A session entering a working tree is resuming work some other session left there, and the working tree is the only party that knows how far it got.

The fragment SHALL state how this rule composes with provisioning, because the two do not compose on their own. The stage and the committed state are readable from the repository immediately. A verification result is not: a working tree that has not been provisioned produces a run that skips and reports success, so an orientation report assembled before provisioning states that verification passes on exactly the evidence the provisioning requirement below says is worthless. The fragment SHALL therefore require that the verification half of the report come either from a run made after provisioning is complete, or be reported as *not run, and why* — never from a run made against an unprovisioned tree.

Nothing here licenses skipping the report. Orientation still precedes the work; what it may not do is present an unprovisioned tree's green as a result.

#### Scenario: A session resumes a working tree left by another session

- **WHEN** a session begins in a working tree holding a change it did not start
- **THEN** it reports the change's stage, its verification result and its committed state before continuing the work

#### Scenario: An unprovisioned working tree's green is not reported as a result

- **WHEN** a session enters a newly created working tree that has not been provisioned, and the project's verification would skip rather than fail
- **THEN** the orientation report gives the change's stage and committed state, and reports verification as not run and why, or reports the result of a run made after provisioning — never the skipped run's success

#### Scenario: The report is derived rather than recalled

- **WHEN** the session has earlier conversation describing the change's state
- **THEN** the report is still derived from the repository and a run of the verification, because the conversation records what was true when it was written and the repository records what is true now

### Requirement: One session works in one branch and one working tree

The isolation fragment SHALL state what its rules govern before stating them: a working tree in which a session is doing a change's work. A working tree whose lifetime is bounded by the single act of tooling that created it, and which carries no branch destined for the trunk — a cold-run check of an agent under authoring, for example — is outside them.

The discriminator is the branch and the lifetime, not the contents. A working tree created from a committed ref carries whatever that commit held, a change's own artifacts included, so "holds no change" would exclude nothing and would leave the exemplar named here inside the rules it is named to be outside of.

Without that scope the rules bind every working tree there is, including ones that can satisfy neither the one-tree rule nor either route of the teardown gate below, because they hold no change in whose artifacts an abandonment could be recorded. This repository's own `agent-authoring` capability already mandates such a working tree, so the collision is present rather than hypothetical, and it is the same two-standing-constraints-on-one-act defect the deferred-work requirement below spends a paragraph curing.

The isolation fragment SHALL require each session to work in a working tree of its own, on a branch of its own — the obligation that a session carries only one change at a time belongs to the deferred-work requirement below, and is not restated here — created from the trunk — freshly fetched from the remote where the project has one.

The fetch clause is conditioned for the same reason the teardown gate's clauses are. An unconditional fetch is a remote presupposition in the fragment's *first* rule, which would make it unsatisfiable at creation in a project that adopts it precisely because it runs sessions in parallel without one.

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

The isolation fragment SHALL state that a newly created working tree carries tracked files only — no ignored configuration, no installed dependencies, no build artifacts, and no share of any external state the project's verification uses — and that provisioning it is a precondition of relying on any verification result obtained in it.

The reason SHALL be stated as the false pass, not as convenience: an unprovisioned working tree does not fail loudly. Verification that cannot reach what it needs skips, the gate reports success, and the result is indistinguishable from a run that passed.

It SHALL state that provisioning is complete when the end state of every step the project's own conventions name holds, not when the first one does. The completeness clause is phrased as a state for the same reason the rest of the rule is — see below; it is the clause most at risk of being written in act language, which would put "has been performed" three sentences before a requirement forbidding exactly that. A partially provisioned environment fails in ways that read as defects in the change under test.

Where the project's verification writes to a shared external service, provisioning SHALL bring the session's namespace in it to the project's known initial state, whether or not a namespace already exists under the name this session derives. The clause is conditioned on such a service existing, as the external-state requirement's parallel clause is: an unconditioned presupposition leaves a project without one reading a normative clause that has no referent. Because a namespace outlives the working tree that named it and this fragment states no release, a later working tree taking the same deterministic name inherits whatever the previous one left there — so the session's verification runs against a dead session's data, and its failures read as defects in the change under test. The obligation is an end state, not a sequence of commands: what reaches that state is the project's binding, as with every other provisioning step.

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

The isolation fragment SHALL require that where a project's verification writes to a shared external service, each session takes its own namespace within that service rather than sharing one.

The namespace SHALL be named deterministically from the session's working tree, so that which session holds which namespace is readable rather than guessed.

The fragment SHALL prescribe no concrete name; the form is whatever the project's own naming constraints impose.

The fragment SHALL state the obligation generally and leave the service, the naming form and the provisioning operations to the adopting project's conventions.

Reclaiming a namespace once its working tree is gone is **not** stated by this fragment; it belongs to a separate, proposed capability for namespace reclamation, because the properties a name must carry to be safely reclaimable are properties of an algorithm rather than of a convention. It is named in this requirement as proposed rather than as existing, so that a reader who cannot find it can tell an unwritten capability from a deleted one. This fragment therefore allocates and does not release, and SHALL say so rather than leave a reader to infer that the omission was an oversight. It SHALL state the consequence inline rather than by reference: a project adopting this fragment accumulates namespaces and needs a sweep of its own until something reclaims them.

#### Scenario: Two sessions verify concurrently against one service

- **WHEN** two sessions run a verification that writes to the same shared service
- **THEN** each writes within its own namespace, and neither observes or destroys the other's data

#### Scenario: The project imposes its own naming form

- **WHEN** the adopting project's tooling constrains what a namespace may be called
- **THEN** the deterministic name derived from the working tree is expressed in that form, and the fragment's rule is satisfied rather than contradicted

### Requirement: A working tree is torn down only against an observable gate

This gate governs a working tree in which a session is doing a change's work, per the scope stated above. A working tree outside that scope is not held by this gate; the fragment SHALL state that as an exclusion and SHALL NOT assert that something else removes it, since no capability in this repository obliges anyone to.

The isolation fragment SHALL state the condition under which a session's branch and working tree are removed as an observable one: the branch is merged into the trunk, nothing uncommitted remains in the working tree, and — where the project has a remote — nothing unpushed remains.

Every clause of the gate that presupposes a remote SHALL be conditioned on the project having one. A project with no remote is one of the shapes this fragment is meant to be adoptable in; an unconditional remote clause is either unsatisfiable there, so teardown never happens and the accumulation this fragment exists to prevent occurs anyway, or it is dead text an agent must decide to ignore.

The gate SHALL admit a second route, because a merge is not the only way a change legitimately ends: an abandonment the operator recorded satisfies it as a merge does. Stated with a merge as the only route, the gate can never be passed by an abandoned change, and its working tree and branch accumulate — the outcome this requirement exists to prevent, reached in the one case it forecloses.

That route SHALL be as observable as the first, or it is not a second route but a hole. The fragment SHALL name where the record lives — in the abandoned change's own artifacts — and SHALL require it to state that the change is abandoned and that the work on its branch is not wanted. (This requirement notes the parallel with how the deferred-work fragment places a blocking dependency, and for the same reason; the isolation fragment states the location alone and names no sibling.) A session entering a working tree left by another session cannot see the exchange in which an operator said so; a record it can read is what separates this route from the inference the requirement forbids.

The fragment SHALL state which clauses the record displaces, rather than leaving "satisfies it as a merge does" to be read either way:

- It displaces the merge clause and, where the project has a remote, the unpushed clause. Both concern commits on the abandoned branch, and the record is the operator's decision that those commits are not wanted.
- It does **not** displace the uncommitted clause. Uncommitted changes in the working tree are not what the operator recorded a decision about — they may be unrelated or accidental — so teardown still halts and reports them, and the operator extends the decision or does not.

The record SHALL be committed on the abandoned branch before the gate is evaluated. Written and left uncommitted, it trips the one clause it does not displace, so the act that authorises teardown blocks it — and the stated remedy of extending the decision would then discard the record the route rests on.

Left unstated, the narrow reading blocks an abandoned branch that was never pushed, which is the permanent unremovability this route exists to remove; the broad reading silently discards uncommitted work on the strength of a decision that did not mention it.

The gate SHALL NOT be stated as the completion of a step described in another fragment. Where a delivery fragment is also adopted, its confirmed merge is what satisfies this gate; where it is not, the gate is satisfied by however that project merges — stated in this requirement rather than in the fragment, which names no sibling.

Teardown SHALL cover the branch locally, the branch on the remote where one exists, and the working tree. The fragment SHALL state from where the working tree's removal is performed, since the tree the gate authorises removing is ordinarily the one the session is running in; an act whose execution context is undefined is resolved by the first implementer's guess. It does not cover the shared-service namespace the session allocated: reclaiming that belongs to a separate proposed capability, named in this requirement rather than in the fragment, and stating half of it here would leave a rule whose safety depends on clauses this fragment does not carry.

#### Scenario: Teardown is refused while work is unmerged

- **WHEN** a session reaches teardown and its branch is not merged, or the working tree holds uncommitted work, or the project has a remote and the branch holds unpushed work
- **THEN** teardown does not proceed, and the unmet part of the gate is reported

#### Scenario: The abandonment record does not block the teardown it authorises

- **WHEN** a session records an abandonment and then evaluates the teardown gate in the same session
- **THEN** the record is already committed on the abandoned branch, so it does not itself trip the uncommitted clause the record does not displace

#### Scenario: An abandoned change's working tree can be removed

- **WHEN** a change is abandoned rather than merged, and the operator's decision is recorded in the change's own artifacts stating that the work on its branch is not wanted
- **THEN** the teardown gate is satisfied by that record in place of the merge, rather than leaving the branch and working tree permanently unremovable because a merge that will never happen is the only stated route

#### Scenario: An abandoned branch that was never pushed is still removable

- **WHEN** teardown runs on an abandoned change in a project with a remote, and the branch holds commits that were never pushed
- **THEN** the record displaces the unpushed clause as well as the merge clause, because both concern commits the operator recorded as unwanted

#### Scenario: Abandonment does not authorise discarding uncommitted work

- **WHEN** teardown runs on an abandoned change and the working tree holds uncommitted changes
- **THEN** teardown halts and reports them, because the recorded decision covers the branch's commits and not changes it never mentioned

#### Scenario: A later session can read the abandonment rather than infer it

- **WHEN** a session enters a working tree whose change a previous session abandoned
- **THEN** it finds the decision in the change's artifacts and can check the gate from the repository's own state, rather than inferring abandonment or refusing teardown indefinitely

#### Scenario: The gate is satisfiable in a project with no remote

- **WHEN** a session in a project that has no remote reaches teardown with its branch merged into the trunk and nothing uncommitted
- **THEN** the gate is satisfied, because its remote clauses are conditioned on a remote existing rather than stated unconditionally

#### Scenario: The gate is checkable without a delivery fragment

- **WHEN** the isolation fragment is adopted in a project that has not adopted the delivery fragment
- **THEN** the teardown gate is still fully checkable from the repository's own state

### Requirement: A change is delivered through a pull request that carries its own record

The delivery fragment SHALL state that a completed change reaches the trunk through a pull request, and that the change's specification record is closed on the branch as the last commit before the merge, so that the record is inside the pull request reviewing it rather than written to the trunk outside any review.

The fragment SHALL state an entry gate it can check by itself: delivery begins only where the change's verification has run and passed against the branch head. The fragment is adoptable alone, so a sequence that opens with the archive commit and states no precondition sanctions archiving and pushing work that nothing verified.

The fragment MAY name the specification tooling directly rather than stating a tool-neutral obligation and binding the tool beneath it. Where it does, that tooling SHALL be stated as a precondition of adopting the fragment, alongside the remote its other clauses presuppose — otherwise the narrowing is recorded only in a change's own artifacts and cannot be checked against the fragment once they are archived.

The fragment SHALL require the operator's confirmation that the merge happened. A session SHALL NOT infer a merge, and SHALL NOT treat a change as delivered before that confirmation.

#### Scenario: Delivery does not begin against unverified work

- **WHEN** a session reaches the delivery sequence and the change's verification has not been run against the branch head, or was run and failed
- **THEN** delivery does not begin, and no archive commit is made

#### Scenario: The change's record ships inside the pull request

- **WHEN** a change is ready to deliver
- **THEN** its specification record is closed in a commit on the branch before the pull request is opened or updated, and not committed to the trunk separately

#### Scenario: A merge is confirmed rather than assumed

- **WHEN** a pull request has been opened and verification has run
- **THEN** the session waits for the operator's confirmation of the merge before treating the change as delivered or acting on anything conditioned on it

### Requirement: A second change surfacing in a session is recorded, not carried

The deferred-work fragment SHALL state that a session works on one change, and SHALL state what happens when a second change is identified while the first is in progress.

Where the change in progress depends on the identified change, the fragment SHALL require that the dependency and the wait it implies are recorded in the artifacts of the change in progress, before anything else is done about it. It MAY then permit offering a proposal for the identified change on a branch of its own and nothing further, and recommending that the work continue in a separate session.

Where the change in progress does not depend on the identified change, the fragment SHALL require that it is recorded either as a proposal on a branch of its own or as an entry in the project's deferred-work file.

Where a proposal-only branch is created by either path, the fragment SHALL state that it is created and left: it does not become the session's working branch and gets no working tree of its own here. Without that, a session in a project that also keeps one branch and one working tree per session reads a permitted route as one its other rules forbid, and the two cannot be reconciled by cross-reference because neither fragment may name the other.

The fragment SHALL name the deferred-work file's path as `docs/deferred-work.md`, and SHALL state what happens where the adopting project has no such file: it is created. An option that silently reduces to no option in a project lacking a file the fragment never told it to create is not an option.

The path is fixed here rather than left to the fragment's author for the reason `.claude/worktrees/` is fixed above: a path stated only in a change's own artifacts is archived with them, and a requirement whose subject is then unnameable cannot be checked against the fragment afterwards.

The fragment SHALL reconcile that second route against `rules/development-workflow.md`, which obliges out-of-scope work noticed during a change to become a separate proposed change rather than being folded in, and which a project bootstrapped by this library carries as an inlined managed block. The reconciliation SHALL be stated against that obligation rather than against a quoted string: the workflow fragment is versioned and expected to change, and a requirement pinned to its current wording is falsified by a rewording that leaves the obligation intact. The fragment SHALL state the seam explicitly: a deferred-work entry *is* that separate proposed change, recorded rather than opened, and the obligation both rules share is that the work leaves the change in progress. Without the seam stated, a bootstrapped project holds two standing constraints on one act, one permitting what the other requires, and a session cannot satisfy both.

This is the one reference a session-scoped fragment makes outside its own set, and it is permitted because `rules/development-workflow.md` is not a session-scoped fragment.

The fragment SHALL state that recording is the obligation and branching is the option. It SHALL give the reason a deferred-work file exists outside the change: a deferral recorded only inside a change becomes unfindable when that change is archived, so it is the change succeeding, not the session ending, that loses it.

#### Scenario: A blocking dependency survives the session ending

- **WHEN** a session identifies that its change cannot complete until another change is merged, and the session then ends
- **THEN** the dependency and the wait are readable in the change's own artifacts, and the next session can distinguish a blocked change from a merely unfinished one

#### Scenario: An unrelated improvement is recorded rather than implemented

- **WHEN** a session identifies work outside its change's scope that nothing in the current change depends on
- **THEN** it is recorded as a proposal on its own branch or as an entry in the deferred-work file, and is not implemented in the session that found it

#### Scenario: A project carrying both fragments has one rule to follow, not two

- **WHEN** a session in a project carrying both the inlined workflow rules and the deferred-work fragment records out-of-scope work as a deferred-work entry
- **THEN** it has satisfied both, because the fragment states that such an entry is the workflow rules' separate proposed change recorded rather than opened

#### Scenario: The deferred-work file does not yet exist

- **WHEN** a project adopting the fragment has no deferred-work file at the named path
- **THEN** the fragment directs creating it, rather than leaving the independent path with one route where it stated two

#### Scenario: A proposal-only branch does not become the session's working branch

- **WHEN** a session creates a proposal-only branch for work it identified but will not do here
- **THEN** the branch is created and left, taking no working tree and not becoming the branch this session works on, so a project keeping one branch and one working tree per session is not made to break that rule to follow this one

#### Scenario: A deferral outlives the change that recorded it

- **WHEN** a change that recorded a deferral inside its own artifacts is archived
- **THEN** the fragment's rules have already directed the deferral into the project's deferred-work file, so archiving the change does not remove the deferral from view

### Requirement: Session-scoped fragments declare a kind and, while nothing inlines them, no version

Each session-scoped fragment SHALL declare `kind: standing-constraint` in its frontmatter, and SHALL NOT declare a `version` for as long as no tool inlines it.

`toolkit-structure` requires a `version` of a fragment that is inlined into a consuming project, and `project-bootstrap` owns the condition under which it increments. A version on a fragment nothing inlines is therefore a number no obligation requires anyone to increment, and an unincremented version reads as a claim about currency that nothing maintains.

This requirement governs the fragment's own frontmatter, which is what this capability owns. It states no obligation on what any tool may inline: that question belongs to `project-bootstrap`, and duplicating it here would give one obligation two owners. As a matter of fact rather than of obligation, no tool inlines these fragments today; they reach a project by the `@` import and hand-copying paths `toolkit-structure` already documents. Should that change, the `version` key becomes owed by the requirements already cited, without this one being amended.

#### Scenario: A fragment carries no version claim

- **WHEN** a session-scoped fragment's frontmatter is read while no tool inlines it
- **THEN** it declares its kind and no version, so nothing presents a currency claim that no requirement obliges anyone to maintain

#### Scenario: A fragment is adopted without tooling

- **WHEN** a project adopts a session-scoped fragment
- **THEN** it does so by importing or copying it, along one of the paths `toolkit-structure` documents
