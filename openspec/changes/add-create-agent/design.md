## Context

`add-create-skill` produced `create-skill` and deferred agents, on the stated grounds that `plugin-dev` already documents the agent format. This change reverses that deferral, and the reason is what the reversal turned up when the published guidance was checked against shipped practice.

Three sources describe the agent format, and they disagree:

| Claim | `validate-agent.sh` | `agent-development/SKILL.md` | Corpus (31 shipped agents) |
|---|---|---|---|
| `model` | required — hard error | required | **8 omit it, all load** |
| `color` | required — hard error | required | **12 omit it, all load** |
| trigger form | warns without `<example>` | prose summary + body section | **26 of 31 use prose** |
| description opener | warns without `use this agent when` | templates it in four places | **10 of 31 use it** |
| `effort` | not mentioned | not mentioned | **7 use it** |
| `tools` syntax | YAML array | YAML array | array **and** bare comma list |
| scoped grants | not mentioned | not mentioned | `Agent(…)`, `Workflow(…)` in `claude-security` |

The corpus is the 31 agents at `<plugin>/agents/*.md` across the official
marketplace. It excludes three nested inside a skill's own directory
(`skill-creator/skills/skill-creator/agents/`), which are not top-level plugin
agents; counting those gives 34 / 11 / 15. An earlier draft of this table paired
the 34-file numerators with the 31-file denominator — the conclusions are
unaffected, since 8 of 31 omitting `model` and loading falsifies "required" just
as 11 of 34 does.

The two documents ship inside the same plugin. The SKILL.md was revised toward prose trigger summaries; the validator was not, and `agent-creator.md` — the flagship agent of that same plugin — still carries three `<example>` blocks. There is no single source to point at, which rules out the approach `create-skill` took with the Agent Skills schema (cite one shipped validator, record it as a dated snapshot).

The second fact driving this design is structural. A skill's body is read by an agent that already holds the conversation; an agent's body *is* a system prompt run in a fresh context, with no history, no inherited working directory, and only granted tools. `create-skill`'s entire apparatus verifies one thing — that the description causes the asset to load. For an agent that is necessary and not sufficient. An agent can trigger perfectly and still fail because its body assumes context that a dispatched subprocess never receives, and nothing anywhere currently tests that.

## Goals / Non-Goals

**Goals:**

- Give `agents/` an authoring standard grounded in reconciled evidence rather than in one document that practice contradicts.
- Test the axis skills do not have: whether a system prompt survives a cold dispatch.
- Make the "is this the right artifact" question the first obligation, not a footnote.
- Inherit from `create-skill` wherever the mechanism is genuinely the same, and say so rather than restating it.

**Non-Goals:**

- Adding an agent to `agents/`. This change adds the standard only.
- Forking or correcting `validate-agent.sh`.
- Auditing agents that already exist.
- A rule-authoring standard.

## Decisions

### D1: `create-agent` is a skill, not an agent

The asset that authors agents is itself a `SKILL.md` in `skills/create-agent/`.

Authoring is an interactive workflow with three human gates. An agent runs in a fresh context and returns one report; it is the wrong shape for a three-round conversation about naming, structure, and a draft. More usefully, this is the standard's own routing gate applied to itself — the work belongs in the caller's context, so it is a skill. An `create-agent` implemented as an agent would fail its own D2 gate.

### D2: The routing gate is the first obligation, and it routes both ways

```
        ┌──────────────────────────────────────────────┐
        │  Does this work need its OWN execution       │
        │  context — fresh, isolated, reporting back?  │
        └────────────┬─────────────────┬───────────────┘
                     │ no              │ yes
        ┌────────────▼──────────┐      ▼
        │ skill    → create-skill│   author the agent
        │ command  → by name     │
        │ rule     → rules/      │
        └────────────────────────┘
```

`create-skill` already routes outward — *"work that needs its own context or isolation → a subagent"* — at a destination that does not exist. This change supplies it and closes the loop, so the two skills form a two-way router rather than two generators that happen to sit beside each other.

Recommending a different artifact and stopping is a complete, successful outcome. A meaningful share of invocations should end that way; an agent is the most expensive asset in the library to get wrong, because a badly scoped one burns a whole subprocess and returns a report its dispatcher may trust.

*Consequence, accepted:* the gate may route to `rules/`, which has no authoring standard to receive the referral. A referral to "write three lines in a rule fragment" needs no workflow behind it.

### D3: The frontmatter contract is reconciled, not copied

`create-skill` cites one validator and dates it. That is unavailable here, so the contract is stated as a reconciliation across all three sources, recording where each claim came from and where they conflict:

- **Required:** `name`, `description`. These are the only fields all three sources and the corpus agree on.
- **Optional:** `model`, `color`, `tools`, `effort`, `metadata.tags`.
- **Recommended anyway:** declare `model` and `color` even though the loader does not require them, so that `validate-agent.sh` — which errors without them — passes on agents this standard produces. The standard notes plainly that this is validator compatibility, not a loader constraint.

The last point is the pragmatic resolution of the conflict. Documenting the disagreement and then producing agents that fail the official validator would be a standard that generates friction on every use.

The value matters as much as the field. `model: inherit` is in the validator's own accepted set, so the compatibility measure costs nothing: declaring `opus` or `sonnet` to silence a check the standard already calls a tool defect would pin a model on every project that installs this library. `inherit` satisfies the validator and decides nothing.

*Alternative considered:* declare `validate-agent.sh` wrong and omit `model`/`color`. Rejected — being right about the loader is worth less than passing the tool people will run.

**`effort` is the field with no source at all.** Seven agents use it, both published documents are silent on it, and the validator does not look for it — so the corpus is the only evidence there is, and it shows two values (`xhigh` in six `claude-security` agents, `medium` in one). That is not an enumeration, and writing one would be inventing the authority this whole decision refuses to invent elsewhere. The contract records the observed values, records that the accepted set is unverified, and leaves it there. This matters because the Shape checkpoint asks the author to confirm `effort`: a checkpoint that asks about a field the contract never explains is a question with no way to answer it well.

**Which of `name` and the file name wins is not actually known.** The requirement that they match is right regardless, but the reason offered for it was overstated. All 31 corpus agents have them identical, so the corpus is evidence for neither, and the `agents/README.txt` experiment — a `.gitkeep.md` placeholder loading as `ai-toolkit:.gitkeep` — had no `name` field, so it establishes the file name as a *fallback* and nothing about precedence. The rule stands on the ambiguity itself: require agreement, and the question never has to be answered. It is cheap to answer anyway, so task 1.6's throwaway agent now carries a deliberate mismatch and records which name it is invoked by.

**`metadata.tags` is the fourth source's field.** The three published sources say nothing about it and no agent in the corpus declares `metadata` at all — but `AGENTS.md` makes tags the only classification an asset carries, and `toolkit-structure` extends that to every asset type. A contract reconciled from external sources alone would silently drop the one field this repository requires, and the checkpoints would then confirm tags at Intent that the contract never sanctions. So the contract carries it, with the vocabulary rule `skill-authoring` already applies to skills.

The corpus gives no evidence either way that the agent loader tolerates a `metadata` block, and unlike the skill schema there is no validation script enumerating permitted keys. That is settled by observation (task 1.9) rather than assumed, on the same `--plugin-dir` load tasks 1.6 and 1.7 already need. If it turns out an agent carrying `metadata` fails to load or to validate, the finding is recorded and tags are ruled out for agents — which is a coherent outcome, and the reason the question is answered before the standard is written rather than after.

**The validator's other constraints are part of the contract too.** An earlier draft recorded only which fields the script treats as required, which left the "one warning by design" claim below resting on conditions it never stated. The script also hard-errors on a `name` outside `^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$` or outside 3–50 characters — the agent counterpart of the constraints `create-skill` carries in its own frontmatter table — and warns on a `color` outside `blue|cyan|green|yellow|magenta|red` and on a system prompt over 10,000 characters. The last is reachable: D5's five required elements plus a `## When to invoke` section is not a short body. All of these are recorded in the contract, because a standard whose stated output is "clean but for one known warning" has to name every condition that claim depends on.

So an agent produced to this standard emits one warning — the missing `<example>` blocks D4 rules out — provided its colour comes from the validator's set and its body stays under that length. That is documented in the skill as expected, so a user running the validator finds the answer where they are looking rather than filing it as a defect, and does not instead find two surplus warnings and conclude the standard is wrong.

### D4: Prose trigger summaries, not `<example>` blocks

The description carries a prose summary of 2–4 trigger scenarios and points at a `## When to invoke` section in the body for worked detail.

Three reasons, in order of weight: the corpus is 26 of 31 this way; `agent-development/SKILL.md` is the newer of the two conflicting documents and prescribes it; and the description is always resident in context, so three XML-tagged worked examples is a permanent cost paid for detail that belongs in the body, which loads only on dispatch.

**The `Use this agent when…` opener is permitted.** All three sources call for it — the validator warns without it, `agent-development/SKILL.md` templates it, 10 of 31 shipped agents open that way — and inheriting `create-skill`'s third-person rule unexamined would have excluded it. It should not. That rule exists to catch `Use this skill when *you want to*…`: second person aimed at the user, which makes a description read as instructions to a human instead of as a dispatch signal. `Use this agent when [conditions]` addresses the dispatcher and names conditions; it is not that failure mode. Permitting it also clears one of the two warnings D3 would otherwise leave standing.

Everything else about descriptions is inherited from `create-skill` unchanged — written against under-triggering, adjacent phrasings named, disambiguated library-wide.

### D5: The system prompt standard, and the dispatch contract

The body is a system prompt in second person. Beyond the conventional template that `agent-development/SKILL.md` supplies (responsibilities, process, output format, edge cases), the standard requires the elements a fresh-context subprocess actually needs:

1. **A dispatch contract** — an explicit statement of what the dispatcher must supply. `claude-security/agents/explore.md` opens with one (*"the codebase to map lives at the absolute path your dispatch gives you… never assume the current working directory is the repository"*); the official template has nothing like it.
2. **Absolute-path discipline** — cwd is not inherited.
3. **An untrusted-input stance** — everything the agent reads is data, not instructions.
4. **A declared output format** — the only channel back to the dispatcher.
5. **A stopping condition.**

The dispatch contract is the load-bearing addition, because it converts a vague quality goal into something testable: D7 supplies the agent only what the contract names, so an agent that then asks for more has an incomplete contract. Element 1 also has no analogue in `create-skill` at all — a skill inherits the conversation and never has to state its inputs.

### D6: Two checks, ordered, with the cheap one gating the expensive one

```
  Draft approved
       │
       ▼
  TRIGGER CHECK      cheap · description only · binary
  "does it fire?"    isolated evaluator, no file needed
       │ pass
       ▼
  COLD-RUN CHECK     expensive · needs the whole body · graded
  "does it work      one simulated dispatch into a fresh context
   alone?"
       │ pass
       ▼
  reported complete
```

The trigger check is inherited from `create-skill` intact. Ordering is explicit because the instinct is to run both together, and there is no value in cold-running an agent whose description guarantees it is never dispatched.

### D7: How the cold-run check actually runs

**What the live half runs against.** An earlier draft asserted that the agent under authoring cannot be dispatched at all — the installed plugin is served from the marketplace cache, so a newly written file in this repository's `agents/` is not registered — and hardened that into a requirement forbidding real dispatch. The premise was about install mode, not capability. `claude --plugin-dir <path>` loads this repository as a plugin without installing it, and `claude --agents <json>` registers definitions directly; both run headless under `-p`. `toolkit-structure` already blesses the first as the development path, and the bootstrap change used exactly it to observe a throwaway asset load.

So the live half prefers a real dispatch and falls back to simulation:

> **Real dispatch** — load the repository with `claude -p --plugin-dir <repo>` and dispatch the drafted agent by name with one representative payload containing only what the dispatch contract names. Where that path does not register the agent or cannot surface its report, `claude --agents <json>` is tried before the form is declared unavailable.
>
> **Simulation (fallback)** — spawn a subagent whose entire instruction set is the drafted body verbatim, plus the same payload, and nothing from the authoring conversation.

*Both registration paths are tried, not just the first.* This decision names two mechanisms that load a definition without installing it, and an earlier draft then tested one. Falling back to simulation because `--plugin-dir` did not work, without having tried `--agents`, would retire the preferred form on partial evidence — and the fallback's limits are exactly the ones this decision spends its length trying to avoid.

The preference is not cosmetic: a real dispatch enforces the `tools` grant and honours `model` and `effort`, which a simulation cannot. Task 1.6 establishes empirically whether an uncommitted `agents/<name>.md` is dispatchable this way before the requirement is written; if it is not, the fallback is the whole check and the requirement says so.

**Dispatchability is not sufficient — the report has to come back.** Three of the four live criteria (declared format, contract completeness, lane) are judgments about what the agent *returned*, and only the tool grant is a judgment about the harness. Under `claude -p` what reaches the operator is the top-level session's output, which is the dispatcher's account of the subagent's work, not the subagent's report. Criteria applied to that account grade the dispatcher: an agent returning malformed output can pass because the dispatcher tidied it, and one returning exactly its declared format can fail because the dispatcher summarised it. So task 1.6 establishes two things, not one — that the drafted agent is dispatchable by name, and that its own report is recoverable verbatim (`--output-format stream-json` carrying subagent messages, or a dispatch instructed to relay the report unaltered). A form that registers the agent but cannot surface its report counts as unavailable, and the check falls back to simulation, where the Agent tool returns the subagent's report directly.

Simulation reproduces what matters — fresh context, no history — but has two blind spots. It grants all tools, so it cannot catch an agent reaching for a tool it was not granted; that class is covered statically instead, by reconciling every tool the body instructs the agent to use against the `tools` field. And it delivers the body as a *prompt* rather than as a system prompt, which is a weaker position in the instruction hierarchy — so the criterion likeliest to pass spuriously under simulation is the untrusted-input stance, whose whole point is that data must not outrank the body.

The static half is therefore mandatory whenever the live half is simulated. It is mandatory beside a real dispatch too — not because the grant goes unenforced there, but because enforcement only bites on the branch one representative task happens to exercise, so a body instructing the agent to edit a file it was never granted passes a read-only run. Redundancy that costs one pass over the body is not worth making conditional.

```
COLD-RUN CHECK
├── static : body's tool demands ⊆ tools field   (both forms)
└── live   : one cold run, contract-only payload
             ├─ real dispatch  : --plugin-dir, tools enforced   ← preferred
             └─ simulation     : body verbatim as prompt        ← fallback
             ├─ produced the declared output format?
             ├─ needed context the contract did not supply —
             │  asked for it, blocked on it, or assumed it?
             ├─ concluded on its own, or hit the harness budget?
             └─ stayed inside its declared lane?
```

**Two criteria have to be stated as something observable, or they test nothing.** Both live forms are non-interactive: a dispatched subagent has no channel on which to ask anyone anything. An earlier draft wrote the contract-completeness criterion as *"asked for context the contract did not supply"*, which is an event that by construction cannot occur — so the criterion D5 calls the load-bearing addition would have been unfalsifiable, and the failure it exists to catch is the one likeliest to occur: an agent that quietly invents a path, assumes a working directory, or refers to a discussion it never had, then returns a plausible report. The criterion is therefore evidence of unsupplied context *in the returned report*, in any of three forms — the agent asked, the agent declared itself blocked, or the agent proceeded on an assumption not derivable from the payload. Only the third is common, and only the third was missing.

Termination has the same problem in a milder form. An agent with no stopping condition does not visibly run forever; it is cut off by the harness's turn or time budget and returns a truncated report, which reads like a short answer unless the criterion says otherwise. So the question is not "did it stop" but *why* it stopped: a run that concluded because its body told it to passes, and a run that stopped because the harness stopped it fails as a missing stopping condition.

**Pass criteria are bound to declared properties** — the format the body declares, the inputs the contract names, the lane the body sets. This is what keeps a graded check from becoming taste. The check never asks whether the output was *good*; it asks whether the agent did what its own body said it would.

Failures map to revisions, the way `create-skill` maps positive-fail → widen and negative-fail → narrow:

| Failure | Revision |
|---|---|
| Assumed conversation ("as discussed above"), or any input invented rather than supplied | dispatch contract is incomplete |
| Assumed cwd, relative paths | add absolute-path discipline |
| Output drifted from declaration | output format underspecified |
| Reached for an ungranted tool | widen `tools` **or** narrow the body |
| Stopped because the harness budget ran out, not because the body said to | add a stopping condition |
| Followed instructions found in a file | add the untrusted-input stance |

**Isolation.** When the drafted agent holds `Write`, `Edit`, or `Bash`, the live half runs in a git worktree, so a cold run's path-directed writes land beside the repository it was authored in rather than in it. The mechanism differs by form and the two should not be conflated: `isolation: "worktree"` is the Agent tool's parameter and applies to the simulation fallback, while a real dispatch needs the worktree created first and `claude -p --plugin-dir` run against it.

**A worktree does not contain the drafted agent, and that breaks the preferred form outright.** `git worktree add` checks out a committed ref. The agent under authoring was written minutes ago and is untracked — task 1.6 is built on exactly that, since what it establishes is that an *uncommitted* definition is dispatchable. So the worktree the isolation requirement creates is a checkout in which `agents/<name>.md` does not exist: point `--plugin-dir` at it and the agent is never registered, and the dispatch fails with nothing to dispatch. Point `--plugin-dir` at the authoring checkout instead and the run is no longer launched against the isolated tree at all, which is what the next paragraph is about. The two branches of this decision were written separately — "prefer a real dispatch" and "isolate write-capable agents" — and each is sound alone; composed, the preferred form of a mandatory check is unexecutable in precisely the case where isolation is required, and D11 then excuses the composition from every test in this change, so nobody would have found it until the first write-capable agent was authored.

The fix is mechanical and belongs in the requirement rather than in a reader's improvisation: create the worktree, **copy the drafted `agents/<name>.md` into it** (with any file the body references), and run `claude -p --plugin-dir <worktree>` from inside it. The copy is what makes the worktree a plugin root containing the agent, and it is the step an earlier draft left to be inferred from "created first". The simulation fallback needs none of this — it carries the body verbatim in the prompt, so the file's absence from the worktree is immaterial — which is why the gap is specific to the branch this decision prefers. Task 1.10 verifies the composition on the same throwaway agent and the same `--plugin-dir` load tasks 1.6, 1.7 and 1.9 already need, which is cheap enough that leaving it untested is not a trade-off, only an omission.

A worktree alone does not deliver that, though. D5 requires absolute-path discipline, which pushes the payload toward naming the repository the agent was authored in — and a payload carrying that path defeats the isolation completely, since the agent simply writes to the original checkout from inside its worktree. So every path in the payload is rewritten to the worktree root before the run, and a payload naming a *writable* path outside it aborts the run rather than proceeding. The mechanism only works if the payload is made to point at it.

The abort binds writable paths, not every path the payload carries, and the distinction is load-bearing. A write-capable agent may legitimately need to *read* something outside the worktree — a plugin cache, a home-directory config, a sibling checkout — and aborting on that would make the check unsatisfiable for the agent rather than protective of the repository. What the worktree contains is writes; the rule that enforces it should have the same scope.

**The payload is only half of it — the run's working directory is the other.** Rewriting every writable path in the payload closes the isolation against a body that *does* honour absolute-path discipline. Against one that does not, it closes nothing: a body saying "write your report to `notes/review.md`" never touches the payload path at all, and resolves that relative path against wherever the process was launched. Launch from the authoring checkout and the write lands there — and it lands *before* the check gets to report the missing discipline, so the defect element 2 of D5 exists to catch is the one defect that escapes the mechanism meant to contain it. So the run is started with its working directory set to the worktree root and is given no additional writable directory naming the authoring checkout. The forms differ again: the Agent tool's `isolation: "worktree"` already puts the simulation's cwd at the isolated root, while a real dispatch has to be started from inside the worktree explicitly. An earlier draft closed the payload half and stopped, which reads as complete until the payload turns out not to be the channel the failing case uses.

**What the worktree actually contains is narrower than "the run cannot mutate the repository".** A worktree redirects paths; it is not a sandbox. An agent granted `Bash` can address any path the process can reach, and the isolation requirement takes a `Bash` grant as its own trigger — so the very grant that makes isolation mandatory is the grant that can walk out of it. "Given no additional writable directory naming the authoring checkout" is also a description of intent rather than of a harness feature: what the harness offers is the working directory the run starts in, the additional directories it is handed, and the permission mode it runs under. So the claim is stated as what it is — path-directed writes land inside the worktree — and the residual is named beside the network case it resembles: for a shell-capable agent, containment rests on the permission mode the run is launched under, not on the worktree. Overstating this would be the same defect as a stored `outcome: pass` in D12 — an assurance that reads stronger than the thing it describes.

### D8: The cold-run check is mandatory, with a floor of one task

Not conditional on the agent being "non-trivial."

Axis two is the entire reason to author an agent rather than a skill; skipping the check ships an unverified system prompt and leaves the change with nothing it did not already have. Cost is bounded by fixing the floor at *one* representative task, mirroring how `create-skill` fixes its trigger check at two prompts and calls it a floor rather than a measurement.

*Alternative considered:* mandatory static half, conditional live half. Rejected — "non-trivial" is a judgment made under time pressure by the person who wants to be finished, which is the same dynamic that makes heavy workflows get bypassed. A fixed cheap gate is harder to rationalize away than a conditional one.

*Scope of re-runs:* a description edit invalidates the trigger check only; a body edit invalidates the cold-run check. Editing both re-runs both.

### D9: Adding an asset invalidates its neighbours' recorded checks

`create-skill`'s evaluator holds the `name` and `description` of every *skill*. The harness does not decide that way — it selects across skills and agents in one dispatch decision — so the evaluator is widened to hold both asset types.

The widening is forward-looking, and the design should not overclaim it. This change adds no agent (`agents/` stays empty by its own non-goal), so the route it actually exercises is `create-skill` ↔ `create-agent` — two *skills*. Nothing here tests cross-type selection, because there is no agent to compete. What the widening buys is that the first agent added to the library lands in a check that can see it, rather than in one that was silently scoped to the wrong asset type.

Both capabilities state the evaluator the same way. `agent-authoring`'s trigger check names the same composition rather than leaving it unspecified — two capabilities specifying one check differently is the drift this repository's conventions exist to prevent.

**The widening needs a stated stopping point, because its own argument does not have one.** The reason to hold agents as well as skills is that the evaluator should match the decision the harness actually makes. That decision also spans every installed plugin — and the collision there is sharper than the one inside the library: `plugin-dev`'s `agent-development` skill triggers on "create an agent", "add an agent", "write a subagent", and `plugin-dev/agents/agent-creator.md` is an agent whose job is authoring agents. Followed to its end, the argument widens the evaluator to whatever happens to be installed, which is machine-local state this repository does not control and cannot re-run a check against; `skill-authoring` already commits to the opposite in *Library-scoped checks are meaningful*. So the boundary is the library, and both capabilities now say so rather than leaving it as an unexamined edge of the widening. What carries the weight instead is disambiguation: `create-agent`'s description states that it authors into *this repository's* `agents/`, which is a distinction that holds whatever else is installed. The residual risk — a trigger check passing here and misfiring in a project that installs `plugin-dev` — is accepted and named, not closed.

**The same premise widens two more requirements, and stopping at one would be arbitrary.** `skill-authoring` also requires a description to be distinguishable from "every other *skill*" and tags to be drawn from the vocabulary across `skills/`. Both rest on exactly the claim this decision corrects — that the library a skill competes in is the set of skills — and `agent-authoring` states both library-wide. Left unwidened, a skill could satisfy its own standard and then fail a trigger check against an agent it was never required to disambiguate from, with no requirement pointing at the fix; and the tag rule would sit narrower than `AGENTS.md`, which already scopes the vocabulary check to the repository. The edit is two words in each, so the only reason to leave them was not noticing.

It follows that a recorded check is only valid against the library that existed when it ran. `create-skill`'s recorded negative prompt is *"write me a subagent that reviews my commit messages"*, which correctly fired nothing — and must now fire `create-agent`. So this change re-runs and updates it. The general rule is promoted into `skill-authoring`: adding an asset invalidates the recorded checks of the assets it competes with.

**The re-run has to test the final text.** `create-skill`'s description ends *"it is not the authoring standard for agents (agents/) or rules (rules/) — see AGENTS.md for those"* — a referral this change falsifies, since `AGENTS.md` will point at `create-agent` rather than carry a standard. That sentence is not incidental: the description is the field the evaluator reads, so leaving it stale ships the dangling referral in the one surface that does the routing, while `AGENTS.md` — a file no dispatch decision consults — gets the fix. The edit is nearly free, because it invalidates a trigger check this change already re-runs. It lands before task 5.1 so the re-run evaluates what will actually ship.

### D10: Structure — bundled, with `SKILL.md` as the spine

`create-skill` fits one flat document at ~240 lines. `create-agent` carries strictly more: a three-source reconciliation table, two `tools` syntaxes plus scoped grants, a five-element system prompt standard, three checkpoints, and a two-stage verification with its own diagnostic mapping. That does not stay readable in one pass.

Planned split, following the convention `create-skill` adopted from `plugin-dev/skills/skill-development`:

- `SKILL.md` — routing gate, checkpoints, description standard, the system prompt standard's five elements, validation, and both checks in summary.
- `references/frontmatter-contract.md` — the dated three-source reconciliation, `tools` syntaxes, scoped grants.
- `references/cold-run-check.md` — the full procedure, diagnostic mapping, worktree handling.

*Threshold, not a commitment:* if the body comes in comfortably readable as one document, it collapses to flat. Splitting a short skill costs a reader two file opens for nothing, and `create-skill`'s own rule is flat-until-it-hurts.

### D11: `create-agent` is authored to `create-skill`'s standard

It gets an Intent/Shape/Draft pass and a trigger check like any other skill in the library. It does **not** get a cold-run check — it is a skill, and skills load into an existing context. The asymmetry is the point of the change stated in one line.

*Consequence to close:* the cold-run check is this change's central contribution, it is mandatory and graded, and D11 means nothing in the change ever executes it. Shipping a procedure that has never run once leaves two things unknown that are cheap to settle — whether a subagent honours a body delivered as a prompt, and whether the declared-property criteria are actually decidable by a reader who did not write the body.

So the procedure is dry-run once against `claude-security/agents/explore.md` (task 4.6). It opens with an explicit dispatch contract — *"the codebase to map lives at the absolute path your dispatch gives you… never assume the current working directory is the repository"* — so it exercises the pass criteria rather than only the mechanics. Cost is one dispatch, and no agent is added to `agents/` — the non-goal holds.

*It is not read-only by the rule this design uses, and the dry run has to honour that.* An earlier draft chose the target on the grounds that "that agent is read-only, so no isolation is needed", reading its body, which confines Bash to `ls`, `cat`, `git log` and the like. But its grant is `tools: Read, Glob, Grep, Bash`, and D7's isolation rule triggers on write, edit, **or shell** capability — keyed to the grant precisely because a body's self-restriction is a claim the harness does not enforce, which is the same distinction the read-only-agent scenario draws under tool grants. Substituting the body for the grant here would have made the change's single execution of its own procedure a non-conforming one, and it would have reported "executable as written" about a branch it never took. So the dry run creates the worktree and runs from it. The cost is one `git worktree add`, and it buys back part of what the next paragraph gives up: a read-only target cannot show that the isolation *contains* anything, but it can show that the mechanism composes — worktree, cwd, `--plugin-dir` — which is the half that was silently broken.

*The target has to be made dispatchable first.* `claude-security` sits in the marketplace clone but is not installed, so `explore` is not registered in an ordinary session. Task 4.6 names `--plugin-dir` against that plugin's directory, because the dry run's value over task 1.6 is that it exercises the *preferred* branch on a real agent — and a run that quietly falls back to simulation would test the fallback twice and the thing in question not at all. If the fallback is used anyway, that is recorded as the finding rather than passed over.

*What the dry run deliberately does not settle:* whether the isolation actually **contains** a write. The target has no write tools, so nothing it does can test whether a rewritten payload and a worktree-rooted cwd keep a write out of the authoring checkout; the only way to test that is to cold-run a write-capable agent, which means authoring one against this change's own non-goal. That half ships untested and is named here rather than left to be discovered.

What no longer ships untested is whether the mechanism *composes* — that a worktree carrying a copied-in definition registers under `--plugin-dir` and dispatches. Task 1.10 settles it on a throwaway agent and task 4.6 exercises it again on a real one. An earlier draft folded both halves into one unknown and wrote off the composition along with the containment, which is how a mechanism that does not work at all came to be filed as a mechanism that merely was not exercised.

*If the dry run fails,* the finding revises the procedure rather than being filed as a note. Task 4.7 exists for that, and the revision reaches both surfaces — the skill body and the `agent-authoring` delta — because the delta is what gets synced.

**Dry-run result (2026-07-28): the procedure passed, with one deviation
worth recording.** `claude-security` is not a git repository in this
environment — `git worktree add` cannot target it directly, which the
requirement's literal wording (written for *this repository's own*
git-tracked agents) does not anticipate for a borrowed third-party target.
The isolation intent was honoured anyway by substituting a plain directory
copy of the plugin, dispatching from inside it with `--plugin-dir` pointed
at the copy and no writable path back to the original marketplace clone or
to this repository. That is a deviation in mechanism, not in outcome, and
it is specific to dry-running a foreign agent — task 1.10 already confirmed
the literal `git worktree` mechanism works for this repository's own
uncommitted agents, which is the actual case this standard governs.

Every other question the dry run was run to settle came back positive:

- **Executable as written**: yes, on the real-dispatch branch — `explore`
  registered as `claude-security:explore` under `--plugin-dir` and was
  dispatched by name with a payload naming only what its dispatch contract
  requires (`SCAN_ROOT`). No fallback to simulation was needed.
- **Report recoverable, not just the dispatcher's account**: yes — the
  agent's exact report came back both as the relayed final result and
  independently via `task_notification.summary`, matching each other
  verbatim.
- **Pass criteria decidable by a reader who didn't write the body**: yes.
  Output format matched the body's own stated shape ("concisely, with
  file:line evidence"); every path in the report was absolute and rooted at
  the supplied `SCAN_ROOT`, with no invented path or assumed cwd; the agent
  concluded on its own with a complete answer rather than being cut off;
  and the static half (tool demands against the `tools` field) matched
  with no mismatch.
- **One criterion this task didn't exercise**: the untrusted-input stance.
  The scanned content contained no text addressed to the agent as an
  instruction, so nothing here tested whether the agent would have
  resisted it — a limit of this particular task, not of the check.

Composition confirmed via the deviation above, not via the literal
mechanism. Containment for a write remains untested by this target, per
the paragraph below, unchanged by this result.

### D12: fixtures are recorded; outcomes are not

The record exists to make re-verification mechanical after the library changes. That is a claim about *inputs*, and following it strictly rules out storing anything else.

**What is recorded:** the trigger check's positive and negative prompts, the expected routing for each, and the cold-run payload. These are fixtures — the inputs a later check re-runs against, so a change six months out re-verifies against the same prompts instead of inventing new ones and calling the difference a regression.

**What is not:** the outcome and the date it ran. D8 already scopes a body edit as invalidating the cold-run check, which means a stored `outcome: pass` is only ever valid against a body that no longer exists. A stale pass is not weak evidence — it is misleading evidence, because it reads as assurance to anyone who does not reconstruct the edit history. Storing nothing is strictly more honest. There is also no consumer: `toolkit-structure` forbids this repository from carrying tooling of its own, so no CI will ever read a stored result. The only reader is a future authoring session, and it needs the inputs.

**Where, for an agent:** a companion file at `agents/<agent-name>.checks.yaml`. Only `.md` files are read as agent definitions — dotfiles included, which is why `agents/README.txt` is a `.txt` — so a `.yaml` sibling is invisible to discovery. It is the extension that does the work, not the depth: discovery does walk subdirectories, and folds them into the invocation name. Frontmatter is the wrong home even namespaced under `metadata`, because it is parsed at every load, for a record no consumer wants. *Shipping is not the reason, and an earlier draft gave it as one:* a `.yaml` file inside `agents/` ships to every consuming project exactly as frontmatter does. The distinction that survives is that it is never read into a context. A separate file is inert bytes on disk and bounds the growth problem by construction rather than managing it.

**Where, for a skill:** in `SKILL.md`, as now, stripped to fixtures. A skill's body loads on demand into an existing context, so the cost that justifies moving the agent's record out does not exist, and inventing a `skills/<name>/checks.yaml` convention would buy symmetry and nothing else. The principle unifies across asset types; the location follows the cost.

*Gap this closes:* `skill-authoring` requires trigger outcomes to be *reported*, never *recorded* — `create-skill`'s `## Recorded trigger check` is a practice with no requirement behind it. D9's new invalidation rule refers to "recorded checks" that nothing mandates recording. So `skill-authoring` gains the fixtures requirement, and the rule stops dangling.

*Report and record are different obligations, and the spec has to say so.* Once the fixtures requirement lands, `skill-authoring` contains both "both prompts and their outcomes SHALL be reported" and "the outcome … SHALL NOT be recorded", and the distinction between them lives only here — in a `design.md` that gets archived. A later reader hits what looks like a contradiction and resolves it in whichever direction they read first. Reporting is what the authoring session says to the person who asked; recording is what persists in the file after the session ends. The first is evidence at the moment the claim is made, the second is a claim that outlives the thing it describes. The fixtures requirement states this in one clause rather than leaving it to be inferred.

*Which edit invalidates which check, for a skill too.* The invalidation table is stated in `agent-authoring` — description edit → trigger check, body edit → cold-run check — but a skill has only the first surface, and this change relies on that rule for a skill in the very act of editing `create-skill`'s description (task 3.8) and re-running its check (task 5.1). A rule the change exercises on skills should be stated in the capability that governs skills, so `skill-authoring`'s fixtures requirement carries the description-edit half.

*Ordering, corrected:* the fixtures a companion file carries include the cold-run payload and the routing each trigger prompt actually took — outputs of checks that run *after* the file is written. So the file's existence cannot be a post-write validation item, as an earlier draft had it; a workflow following its own stated order would fail validation on a conforming agent, and the obvious workaround is a stub fixtures file, which empties the record of the meaning D12 gives it. It is a condition of reporting the agent complete instead. Post-write validation covers what is knowable at write time; the fixtures file is written when the inputs it records exist.

*No new `toolkit-structure` constraint is needed, but one false sentence in it is.* An earlier draft held that the capability sanctions non-`.md` files in `agents/` only for the placeholder and would have to be extended first. It says no such thing: it constrains where *assets* are placed and requires that a directory placeholder not be discoverable as one. A companion file is not an asset and contravenes nothing. Writing a dependency on future work into a spec that is about to be synced would leave `agent-authoring` permanently declaring itself unusable, and the first person to author an agent would have to stop and write another change to clear a precondition that was never real. So no permission is added, and the rule is stated positively in `agent-authoring`.

That reading is right about the requirement and misses its rationale. The clause reads *"Since every file directly inside `agents/` is read as an agent definition, a placeholder there SHALL take a form discovery ignores"* — and the premise is false. Only `.md` files are read; `agents/README.txt` records the experiment that established it (a `.gitkeep.md` placeholder loaded as an agent named `ai-toolkit:.gitkeep`, which is why the extension rather than the leading dot is what matters). Taken literally the sentence asserts that no form discovery ignores exists inside `agents/`, which makes the requirement it introduces unsatisfiable and leaves the `.txt` placeholder standing on a rule that denies it. It is also the exact fact this decision leans on: two synced capabilities would state opposite things about agent discovery, and the one a reader consults about *placement* is the one that is wrong.

So `toolkit-structure` carries a `MODIFIED` block narrowing that clause to `.md` files, plus one scenario recording that a non-`.md` file beside an agent is neither discovered nor a parse failure. This is not the scope creep the earlier draft was right to refuse — nothing is permitted that was not already permitted, and no new obligation appears. A statement of fact that the repository has already falsified in its own placeholder is corrected. The distinction worth keeping is that adding a permission would have been a dependency; correcting a false premise is a defect fix, and leaving it would ship the contradiction inside the change that depends on it.

*The obligation stays where it belongs.* A draft of that block extended the clause's `SHALL` from "a placeholder" to "a placeholder or companion file" — which is a new obligation, however small, and would have made this change's own non-goal false and task 3.7's confirmation ("adds no constraint and relaxes none") unsatisfiable by the text it was confirming. The companion-file rule is stated once, in `agent-authoring`, which is the capability that has a companion file to govern. `toolkit-structure` corrects its premise and records the fact; it does not acquire a rule about an asset type it does not describe.

## Risks / Trade-offs

- **The simulation is not a dispatch** → It reproduces fresh context and absent history, which is where the failures are, but not tool enforcement, not `model`/`effort` selection, not real dispatch machinery. D7 now prefers a real dispatch precisely to avoid this, and reaches for simulation only as a fallback; where the fallback is used, the static half covers the tool gap and the rest is named as a floor in the skill body rather than papered over.
- **A simulated body is a prompt, not a system prompt** → It sits lower in the instruction hierarchy than the position it will actually occupy, so the untrusted-input criterion is the one likeliest to pass under simulation and fail in production. Named in D7 as a limit of the fallback, and one more reason the real dispatch is preferred.
- **Sources have already drifted, and will again** → Three sources that disagree today will disagree differently later. Mitigated by recording the reconciliation as a dated snapshot naming all three, so a stale contract reads as stale rather than as authority — the same device that caught `create-skill`'s wrong assumption about `version`.
- **A graded check invites taste** → Bound to declared properties (D7). The check never judges output quality, only whether the agent honoured its own declarations. Residual subjectivity is accepted as the price of testing axis two at all.
- **`create-agent` and `create-skill` compete for the same triggers** → They are the two most confusable descriptions in the library, and "write me a subagent that…" is genuinely ambiguous between *author one* and *act as one*. The shared evaluator in D9 is the test, and both recorded checks are re-run in this change rather than only the new one.
- **`create-agent` also competes with assets outside the library, and the check cannot see them** → `plugin-dev` ships both a skill and an agent for authoring agents. The evaluator is deliberately library-scoped (D9), so a trigger check can pass here and misfire in a project that installs `plugin-dev`. Mitigated only by disambiguation — the description states that this skill authors into *this repository's* `agents/` — and accepted otherwise, because the alternative is a check whose result depends on which plugins happen to be installed on the machine that ran it.
- **A cold run can have side effects** → Worktree isolation for write-capable agents, with the drafted definition copied in so the preferred form can run at all. What the worktree contains is path-directed writes. An agent granted network or external-service tools reaches past it, and so does a `Bash` grant — the same grant that makes isolation mandatory; the skill flags both as cases for reviewing the payload and the permission mode before running rather than pretending isolation is total.
- **Two checks may be two too many** → `create-skill` already carries checkpoint-fatigue risk; this adds a second post-write check on a more expensive asset. Mitigated by the one-task floor and by the cheap check gating the expensive one. If `create-agent` starts getting bypassed, D8 is the decision to revisit first.
- **Recommending `model` and `color` encodes a tool bug** → If `validate-agent.sh` is later fixed to match the loader, the recommendation becomes vestigial. Cheap to carry and cheap to drop; it is recorded as validator compatibility precisely so a future reader knows why it exists.

## Migration Plan

No migration; this adds a new asset and edits two existing files. Rollback is deleting `skills/create-agent/`, removing the `AGENTS.md` pointer line, and reverting the `create-skill` edits (route destination, evaluator wording, recorded check).

## Open Questions

None blocking. Three resolved in passing, recorded so they are not reopened:

- *Should the cold-run check be recorded the way the trigger check is?* Its **fixture** is, its **result** is not (D12). The rationale — making re-verification mechanical rather than improvised — is a claim about inputs, and never argued for storing outcomes.
- *Does a description-only edit force a cold re-run?* No (D8). The two checks target different surfaces and invalidate independently.
- *Does `create-skill`'s own recorded section change shape?* Yes. This change already rewrites it (tasks 5.1–5.4), and D12's principle is asset-type-agnostic, so leaving outcomes in would ship a standard the same commit violates one file over. It becomes a fixtures section, keeping the expected routing for the negative prompt — now `create-agent` rather than nothing — which is what turns D2's two-way route into a standing regression test instead of a claim.

- *Does `toolkit-structure` need to sanction companion files in `agents/`?* No — it already permits them, and nothing in this change waits on a permission (D12). But it does carry a `MODIFIED` block correcting the clause that claims every file in `agents/` is read as an agent definition, which is false, unsatisfiable as written, and contradicts the fact the companion file depends on. Permission unchanged; premise corrected.

Four carried into the tasks as empirical questions rather than answered here — whether a real dispatch can surface the drafted agent's own report (task 1.6, D7), whether an agent declaring `metadata.tags` loads (task 1.9, D3), whether a worktree carrying a copied-in definition registers under `--plugin-dir` (task 1.10, D7), and which of the frontmatter `name` and the file name wins when they differ (task 1.6, D3). The first three decide wording the standard cannot honestly fix in advance; the last decides only how the flat-file rule is justified, since the rule requires agreement either way, and it rides along on a load the others already need.

### D13: An empirical finding revises the delta, not just the skill

The four tasks that settle harness behaviour (1.6, 1.7, 1.9 and 1.10) and the dry run (4.6) can each falsify something the spec deltas already state. The deltas are written ahead of them and hedged where the outcome is genuinely open — *"SHALL be used when available"*, *"SHALL be established by observation"* — but hedging is not the same as reconciling, and two of the findings can contradict the text outright. If 1.9 shows an agent carrying `metadata` fails to load, `agent-authoring` still says tags MAY be declared while the skill it governs says they may not. If 4.6 shows the cold-run procedure is not executable as written, the requirement is synced anyway, because task 4.6's only verb was *record*.

Findings were routed into the skill body (tasks 2.5, 2.13) and nowhere else, so the delta — the thing task 6.4 actually syncs — could ship contradicting the evidence gathered in the same change. That is the failure this change exists to correct, one file over: guidance that disagrees with observed practice.

So two tasks close the loop. Task 4.7 revises the procedure, in both the skill and the delta, if the dry run finds it unexecutable or its criteria undecidable. Task 6.0 reconciles the deltas against 1.6, 1.7, 1.9, 1.10 and 4.6 immediately before the sync, so a clause an empirical task falsified is corrected rather than carried into `openspec/specs/`.

*The reconciliation covers all three deltas, not only `agent-authoring`.* An earlier draft scoped 6.0 to that one file, which leaves a finding able to falsify a clause nothing then corrects: the `toolkit-structure` delta asserts as fact that a non-`.md` file beside an agent is neither discovered nor a parse failure, and task 1.7 tests that for `.yaml` specifically. If 1.7 came back the other way, `agent-authoring` would lose its companion file and `toolkit-structure` would be synced still asserting the fact the companion file was built on. The narrow scope was an oversight about which delta an empirical task can reach, not a decision.

*One of the deferred questions is already answered by inspection.* Task 1.9 asked whether an agent declaring `metadata.tags` both loads and passes `validate-agent.sh`. The validator half needs no experiment: the script greps for `name`, `description`, `model`, `color`, and `tools` individually and never enumerates permitted keys, so any additional key passes it trivially — unlike the skill schema, where `quick_validate.py` rejects unknown top-level fields and is what made the equivalent question worth running for `create-skill`. Only the loader half is genuinely open, and 1.9 is narrowed to it.
