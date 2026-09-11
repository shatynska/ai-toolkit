## Decision 1: A third situation, not a widening of the second

The obvious alternative is to leave two situations and amend the second — "the target already exists" — to say that a pass establishes nothing where the target is a committed file. It was rejected, for two reasons.

The second situation's whole content is that a pass *is* informative: *"a pass is the expected result and establishes that the code currently behaves as asserted."* A committed artifact inverts that sentence rather than qualifying it. Folding it in would leave one situation carrying two opposite readings of its defining event, and the requirement's own scenario — *"A reader can tell which rules are in force"* — is what such a fold breaks.

And the remedy differs. In the second situation nothing further is owed: the code exists, the test ran against it, the pass is the result. In the third the check has to be run over material the test controls, or the assertion is unfalsifiable. That is a distinct obligation, and an obligation attaches to a situation rather than to a footnote inside one.

The line is **whether the assertion executes the behaviour it asserts** — not what kind of thing the target is, not whether the target was loaded, and not who committed it or when.

Two earlier drafts of this decision drew it elsewhere. The first drew it on the target's kind: a file cannot behave, so a file is the third situation. That is wrong on a class the evidence itself contains. `infrastructure`'s binding check asserts that the entry point its conventions file names is committed and runnable — the target is a shell script, which certainly can behave, and the assertion never runs it. Under a kind-based line that check falls outside the situation whose obligation it plainly needs. A Terraform file, a Dockerfile and the source of any program read rather than called are all in the same position.

Executing **the behaviour the assertion asserts** is the property that does the work — not merely executing, or loading, the target. Where the assertion exercises that behaviour, a pass reports it and is evidence. Where it does not, the target's presence is the only thing the pass reports, and the presence was never in question. That keeps the second situation where it belongs: code that already exists is committed, and sits in the second situation because the check calls it.

The second drew it on execution of the target, which is nearly right and fails on one case: a test importing a module only to read a constant out of it does execute the target — the module body runs on import — while discriminating on nothing but the symbol's presence, exactly as a read of the same value out of a configuration file would. Under the coarser wording it would fall in the second situation and owe no fixture, which is the outcome this change exists to prevent.

**The situations read one test at one moment; they do not partition tests.** A static check whose file does not exist yet is in the first situation while that holds — its failure establishes the file's absence and nothing about the assertions — and in the third once the file is present. An earlier draft foreclosed this by asserting that nothing about such a target can be absent, which is false of the very example this decision rests on: the binding check asserts that an entry point *is committed and runnable*, and its red state is the file's absence. Arbitrating the transition is cheaper than denying the case, and it costs the decision nothing.

## Decision 2: The ceiling lives in the classification requirement

Three homes were considered for the bound on a discriminator's size.

A requirement of its own was rejected as untethered: a rule saying "do not write too many tests" states a preference and is unreviewable, which is the failure the count rule was written against in the first place.

The failure-states requirement was rejected because it is about reading a result, not about authoring.

*Asserted Behavior Is Separated into Specified, Derived, and Deliberately Untested* is the right home because it already owns the machinery. An extra discriminating case is either specified — it traces to a stated requirement — or derived, which the skill already requires to be labelled and already describes as *"the test author quietly designing behavior."* So the ceiling is not a new prohibition. It is the existing classification, applied to a body of tests nobody currently classifies because the whole layer reads as methodology rather than as assertion.

That also makes it reviewable, which a size rule is not: an author who cannot say what a case falsifies has written a derived assertion and must label it.

## Decision 3: This goes in `testing`, not in a skill of its own

`commerce-ops` faced an adjacent question and answered it the other way, and the reasoning is worth stating because it does not transfer.

Its `move-the-harness-rules-to-a-skill` moved twenty standing rules out of `AGENTS.md` into a project skill. Its stated reason is entirely about loading cost: *"`AGENTS.md` is loaded into every session, whole … Every session pays for those 20 rules whether or not it will write a test this turn."* That is an argument about always-loaded versus on-demand. `testing` is already a skill, already on-demand, so the cost that precedent removes is already absent here, and the precedent is silent on granularity.

`create-skill`'s own default settles it: *"Default to a single flat `SKILL.md`. Split only when the document stops being readable in one pass."* This change adds under a thousand words of normative material to a 172-line document, and its disambiguation criterion — breadth is about phrasings of the same job, disambiguation is about the job itself — would have to find a job here that is not "write a test". There is none: the third situation is reached by an ordinary test-writing request against an ordinary suite.

`create-skill` states a loading budget alongside that criterion — the body under roughly five thousand words. `skills/testing/SKILL.md` is 3,053 words today, and the delta has grown across review rounds, so no point estimate of the result would stay true. What holds is the bound: the delta obliges under a thousand words of normative material against a budget of five thousand, so a rendered body lands somewhere near four thousand and the budget is not the constraint that decides this. The margin is real but no longer large, and the situations section roughly triples in length, so `create-skill`'s other criterion — readable in one pass — is the one worth re-checking against the rendered file rather than against this estimate. Task 4.10 does that. Stated as a bound and a re-measurement rather than as a figure, because Decision 3 turns on the size question and a number nobody re-counted is what a later reader falsifies. **Task 4.10 carries the measurement, and it falsified two claims in this paragraph**: the "under a thousand words" bound was breached at 1,261, and "roughly triples" was wrong by 2× — the situations section grew 6.5×, which is why it now carries `###` subsections. The conclusion stands; these two sentences do not, and the pointer is here so an archived reader is not left with a falsified premise and no route to its correction.

A sibling skill would also cost a three-way trigger disambiguation where two-way is verified today. `testing`'s trigger fixtures carry a displacement probe precisely because overlap with the language skills is intended and displacement is not; a third asset would need its own probe against both.

## Decision 4: The obligation is scoped to authorship and discharged in the authoring pass

Two questions the round-2 draft left open, both of which turn a stated rule into an unperformable one if answered wrongly.

**Scope.** Conditioning the obligation on a check being green, with no temporal qualifier, makes every already-green static check in every consuming project non-conformant the moment the rule lands. That is a retrofit mandate, and it raises test volume in the name of bounding it — the change working against its own second purpose. The obligation therefore attaches to a check **as authored or modified**, and a check predating the rule is read as carrying an undischarged obligation rather than as a violation. This is stated in the delta rather than left to this file's *What this deliberately does not bind* section, whose quantity, fixture-location and trimming clauses do not reach a green check with no discriminator at all. That section's fifth clause, *A suite that predates the rule*, does reach it — but it **describes** the case, where the delta **binds** it, and a description carries no obligation for an implementer to render.

**Discharge.** An earlier draft said the fixture is owed "once the check is green". Nothing re-dispatches a test author at that moment: `change-test-writer` runs before implementation, and its repeat-pass rule triggers on revised specs or an early stop. The manifest requires no entry for a discriminator that was not written — its contents are an "at minimum" list, so nothing there would carry the debt either. So the obligation would fall due after the only pass these capabilities govern had ended, owed by nobody and invisible in the record.

The resolution is a property of the fixture rather than a new workflow step: **a discriminator supplies its own material, so it does not depend on the target's state.** It can be written beside a check that is still red, in the same pass, by the same author — nothing about a red check prevents it. The obligation therefore lives where the pass lives, and needs no new artifact to carry it: the floor's existing recording-surface rule already says the classification and its reasons are recorded where the project records such things.

**What an earlier draft of this change added here, and why it is gone.** Six review rounds carried a parallel amendment to `change-test-authoring`'s manifest — an entry for what a discriminator falsifies, one for a check left without a discriminator, a carry-forward across a repeat pass, and a home for a discriminator that could not be run. It produced six of the nine blocking findings in the last three rounds, and the last of them exposed why: the carry-forward needs an input the agent's dispatch contract makes optional and forbids it to go looking for, so the clause was either unperformable or reached two further requirements to become performable. Deferring it whole is what lets this change state the floor obligation and stop. `docs/change-queue.md` carries it with the review's findings attached — including the two that cost the most to establish: that any such manifest exception must key on the **check's state** rather than on how the pass produced it, since a green check discriminating on nothing is the case that announces itself least; and that the unrunnable-discriminator record does not belong inside the baseline entry.

## The evidence, and its limits

The third situation is observed in `infrastructure` in three independent derivations: the paired discriminator classes in `.github/tests`, a module docstring there stating the unfalsifiability outright — *"The class above would pass identically against a check that read nothing"* — and the `add-a-staging-environment` change's `test-plan.md`, which works the reading out from first principles: *"a guard passing on its first run is the expected result rather than the 'passed before any implementation existed' alarm, because its target is not absent."* The pattern is not hypothetical and is not one author's habit.

A second instance is **this repository's own `tests/cases/`**, which an earlier draft of this paragraph wrongly reported as absent. Those cases do exercise `scripts/` by running them, but several also read committed library files statically, and ten have re-derived the vacuity problem in their own words without any of this vocabulary: `workflow-fragment-stage-vocabulary.sh` records that "a whole-file scan passes even if the block is deleted outright, which is the one thing this case exists to catch", and `review-verdict-vocabulary.sh` fails outright rather than scanning an absent directory, "the scans below would pass vacuously". That is the third situation and the fixture obligation's motive, reached independently inside the tree this change edits.

`commerce-ops` was not examined for a static-read suite and is not claimed either way.

So: two repositories, and more derivations than either of the two earlier drafts of this paragraph counted. That is enough to state the situation and not enough to claim it is universal — the requirement is written to be falsifiable by a project that has such a suite and finds the third situation does not describe it.

The volume figures are `infrastructure`'s alone and are not claimed as typical. What they establish is that the count rule admits this outcome, not that it produces it everywhere.

## What this deliberately does not bind

**How many discriminating cases a check is owed.** The rule states what a discriminator is for and requires an unfalsifiable extra to be labelled derived. It does not give a number, because the number varies with how many independent ways a check can be made to pass wrongly, and a stated number would be the unreviewable size rule Decision 2 rejected.

**Where a project puts its fixture builders.** The other half of the volume problem, deliberately out of scope per the proposal, and it interacts with the agent's additive-only guarantee in a way this change does not have to resolve.

**Whether an existing over-sized discriminator is trimmed.** Nothing here obliges a project to revisit tests already written, and `An Existing Test Is Never Weakened or Deleted to Reach Green` is untouched: a discriminator removed because it was judged excessive is removed under a project's own decision, not under this rule.

**Who owes a discriminator for shared read-machinery authored fresh.** The scope rule decides when editing existing machinery brings a *delegating check* into scope. It says nothing about machinery written new, because that is fixture-builder territory and *Shared test arrangement* above is deferred whole. Named so the silence reads as deferral rather than oversight.

**A suite that predates the rule.** Decision 4 scopes the obligation to a check as authored or modified. Such a suite is not brought into conformance by this change and is not in breach of it; its checks carry an undischarged obligation, which is a description rather than a demand.
