## Context

The library ships four skills (`bash`, `create-agent`, `create-skill`, `terraform`, `n8n-workflow-review`) and one agent (`openspec-change-reviewer`). `bash` and `terraform` are the domain-asset precedents: general floors that state authoring discipline for a language or tool, deferring to a consuming project's own conventions on conflict. See proposal.md for the motivation and scope; this document covers how the skill is shaped.

`bash` is the closer structural precedent of the two — general-purpose scope rather than tool-specific, a traps-first body over tutorial content, ShellCheck as a necessary-but-not-sufficient completion check verified live during authoring. Much of that shape transfers directly: purpose-neutral scope, a traps-first body, and a live-verification discipline for API/tool claims. Where this change diverges from `bash`'s precedent, the divergence is deliberate and recorded below, for the same reason `add-bash-skill`'s design.md gave: the precedent is strong enough that a later reader would otherwise read a difference as an oversight.

## Goals / Non-Goals

**Goals:**
- Ship LangGraph guidance that changes agent behavior rather than restating what a competent model already supplies about the framework's basic shape (what a node or edge is, how `StateGraph` is instantiated).
- Concentrate content on behaviors where a reasonable reading of LangGraph code still yields the wrong answer — silent overwrite instead of accumulation, a routing typo caught only at runtime, a checkpointer choice that degrades invisibly.
- Hold API-surface claims to a live-verification standard, since LangGraph's API has moved fast enough that recent replacements (`interrupt()`, `Command`) risk being described from stale familiarity.
- Compose with a consuming project's own conventions rather than competing with them, matching `bash-practice` and `terraform-practice`.

**Non-Goals:**
- Teaching LangGraph to a human. A skill loads into an agent's context; it is not documentation the user reads. Same non-goal `bash` and `terraform` carry.
- The JS/TS `@langchain/langgraph` SDK. A future companion skill for that SDK is not ruled out, but this change does not scope for it, and this skill's description states the Python boundary explicitly so it doesn't quietly become a JS reference by accretion.
- General agent-framework advice not specific to LangGraph (comparisons to other orchestration frameworks, when to pick LangGraph over an alternative).
- A runtime confirmation protocol of this skill's own. `interrupt()`-gated tool approval is covered as LangGraph subject matter — how to build a graph that pauses for human approval — not as an instance of this library's own `hitl` convention (see Decision 2).
- A project's own state-schema conventions, checkpointer backend choice, or deployment target, which belong in that project's `AGENTS.md`.

## Decisions

**1. Split structure, diverging from the `bash`/`terraform` flat-file precedent.**
Both existing domain skills are flat files. `bash`'s design projected its ten-section body at roughly 1,850 words, comfortably under the ~5,000-word budget, and explicitly named `references/` as an escape hatch it didn't need. LangGraph's domain surface is wider at the depth this change wants: state/reducers, conditional edges, recursion limits, checkpointer choice, thread-ID hygiene, subgraph state-passing, streaming modes, testing, supervisor/swarm handoff patterns, `Command`, `ToolNode`/`tools_condition`, parallel tool calls, tool-call error handling, and `interrupt()`-gated approval — fourteen distinct topics against `bash`'s ten, with the multi-agent/tool-calling material wanted in more depth than a single flat section would hold.

Splitting keeps `SKILL.md` as the always-resident floor (state/reducers, edges, recursion, streaming, testing — the material relevant regardless of what triggered the skill) and moves checkpointer depth and multi-agent/tool-calling depth into `references/`, loaded only when the triggering question reaches them. The alternative — one flat file at full depth — was rejected as likely to exceed the readable-in-one-pass ceiling `create-skill`'s "Choosing structure" section sets, and as paying the multi-agent/tool-calling load on every trigger even for a single-agent question, which the *Structure Separates the Always-Resident Floor from On-Demand Depth* requirement is written against.

**2. `interrupt()` is LangGraph subject matter, not an instance of this library's `hitl` tag.**
`interrupt()` pauses the *graph being authored* for human input — a feature of the target code. This library's `hitl` tag, carried by `create-skill`, `create-agent`, and `terraform`, means the *assistant* pauses to confirm before its own risky action (writing a skill file, running `terraform apply`). The two share a name and nothing else: one is a runtime primitive in someone else's state machine, the other is a constraint on this assistant's own behavior.

Applying `hitl` to `langgraph` would misclassify it by vocabulary collision rather than by what the tag actually tracks elsewhere in the library, the same kind of drift `AGENTS.md` warns synonym tags produce. So the skill covers `interrupt()` as ordinary subject matter — how to build a graph that pauses for approval — and does not carry the `hitl` tag. The `langgraph-practice` spec states this distinction directly (*interrupt() is distinguished from this library's own hitl convention*) rather than leaving it to be inferred from tag absence alone, mirroring how `add-bash-skill`'s design recorded its own declined-tag reasoning rather than leaving a silent omission.

**3. Scope holds across agent count; multi-agent/tool-calling is depth, not a boundary.**
The motivating project is multi-agent and tool-calling, and an `langgraph-multi-agent` or similarly narrowed skill was implicitly available as a smaller alternative. Rejected for the same reason `bash` rejected an `infra-bash` scoping: state-schema and reducer semantics, conditional-edge routing, and recursion limits hold identically whether a graph has one node-cluster acting as a single agent or several coordinating agents. Narrowing the skill to multi-agent would forgo the single-agent audience for a domain asset meant to load "everywhere the plugin does" (per proposal.md's Impact section) at no benefit to the multi-agent content itself, which is served just as well by being the more-developed section of a general skill.

**4. Name `langgraph`; one new tag `langgraph`; no `allowed-tools`.**
The bare package name is what a user types and matches the `bash`/`terraform` precedent of naming the skill after the tool itself rather than a paraphrase (`shell-scripting`, `infrastructure-as-code` were both rejected in those precedents on the same grounds). No `allowed-tools`: this skill is not a wrapper around a single external command the way a hypothetical CLI-wrapping skill would be — it's open-ended authoring guidance, and `create-skill`'s standard reserves `allowed-tools` for the narrower case.

**5. API claims verified live, or explicitly sourced from documentation when a live check isn't possible.**
`bash`'s change verified its ShellCheck claims against a live-installed version, with a documentation-sourced fallback recorded as provisional when installation was initially blocked. The same discipline applies here, and the stakes are arguably higher: `interrupt()` and `Command` are both relatively recent replacements for older LangGraph patterns (older code used `interrupt_before`/`interrupt_after` compile-time flags and plain return-value routing before these were introduced), so a claim written from general familiarity risks describing a superseded API. The `langgraph-practice` spec's *API Claims Are Verified Against the Released Package* requirement makes this an explicit, checkable obligation rather than an assumed diligence.

## Risks / Trade-offs

- **LangGraph's API moves fast enough that verified claims can still date.** Even a live-verified claim at authoring time can be superseded by a later `langgraph` release. → *Mitigation*: accepted as the same residual risk `bash-practice` carries for ShellCheck's version-dependent behavior — the spec requires the *version verified against* be recorded in the authoring record (mirroring `bash`'s "verified against ShellCheck 0.9.0 on 2026-07-31" statement), so staleness is detectable rather than silent, even though the requirement doesn't force a resync on every upstream release.
- **The split-file structure adds a load-boundary the flat-file precedent doesn't have.** A question that touches both the floor and a reference topic requires the skill to actually follow its own pointer into `references/`, which a flat file doesn't need to do. → *Mitigation*: `SKILL.md`'s outline explicitly closes with "Where to go deeper," naming both reference files, so the pointer is structural rather than left to be inferred.
- **Trigger competition is unproven, not just low-risk.** Nothing in the current library touches agent-orchestration frameworks, so the *a priori* risk is low, but this is a determination to make during tasks (re-reading every recorded fixture against the final description), not a conclusion this design document is entitled to assert. → *Mitigation*: carried as an explicit tasks.md checkpoint, following `add-bash-skill` task 6.1's pattern rather than being waved through here.
- **Declining a JS/TS companion skill leaves that SDK's users with no library asset**, and `@langchain/langgraph` diverges from the Python package in ways this skill's Python-specific claims (e.g., `Annotated` reducers, a Python-specific idiom) would actively mislead if misapplied. → *Mitigation*: the description states the Python boundary explicitly, so the skill declines to trigger rather than triggering and giving wrong guidance; a JS-scoped companion is left as a future change if warranted, not folded in here.

## Open Questions

(none — the scope, tag, structure, and naming questions raised during exploration were resolved above rather than deferred.)

## Harvest candidates

Recorded per the close-out task, for a future edit to `skills/langgraph/` rather than added to this change — neither is load-bearing for the delta spec's minimum content, and adding either now would be padding beyond what the spec requires.

- **`langgraph.prebuilt` ships a `create_react_agent` prebuilt single-agent loop**, and its own docstring points to `langchain.agents.create_agent` as a newer top-level replacement. Neither is covered in the shipped skill, which stays scoped to floor discipline for hand-built graphs (state/reducers, routing, recursion, checkpointing) rather than the prebuilt fast-path. Worth adding if a future edit wants to cover "when to reach for a prebuilt agent loop instead of hand-assembling a graph" as its own topic.
- **`BaseCheckpointSaver` exposes thread-management primitives beyond `get`/`put`** — `delete_thread`, `copy_thread` — verified present during task 3.1's live introspection but not covered in `references/checkpointing.md`, which sticks to choice, thread-ID hygiene, and subgraph state-passing. Worth adding if a future edit wants a concrete example of managing checkpointed state after the fact (e.g., deleting a stale thread), since this is a more specific mechanism than the general thread-ID hygiene guidance already given.
