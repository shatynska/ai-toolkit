## Purpose

Defines the floor-level Python LangGraph authoring practice this library ships: the state, control-flow, persistence, and multi-agent/tool-calling behaviors that read as correct but aren't, held to the same verify-before-writing discipline as this library's other domain skills.

## Requirements

### Requirement: Scope Is Python LangGraph, Held General Across Use Cases

The skill SHALL state its subject as the Python `langgraph` package specifically, and SHALL NOT extend its guidance to the JS/TS `@langchain/langgraph` SDK.

The skill SHALL state its guidance in terms that hold for any LangGraph graph, regardless of whether the graph is single-agent or multi-agent. It SHALL NOT narrow its core state, control-flow, or persistence guidance to a multi-agent scenario, even where a multi-agent, tool-calling project is the motivating use case for a section receiving deeper treatment.

#### Scenario: A JS/TS LangGraph question is out of scope

- **WHEN** a question concerns `@langchain/langgraph` (JS/TS) syntax or behavior
- **THEN** the skill SHALL NOT present itself as authoritative for that SDK, having scoped itself to the Python package

#### Scenario: Core guidance does not vary with agent count

- **WHEN** the same state-schema, reducer, conditional-edge, or recursion-limit question arises in a single-agent graph and in a multi-agent graph
- **THEN** the skill SHALL give the same answer in both, without a branch conditioned on agent count

### Requirement: State Schema and Reducer Semantics Are Recorded

The skill SHALL state that a state field without an explicit reducer is overwritten on each node's return rather than merged or accumulated, and that this is silent — no error, no warning — when a node's intent was accumulation.

The skill SHALL record the reducer idiom for accumulating fields (an `Annotated` type paired with a merge function, such as `add_messages` for message lists) as the mechanism that makes accumulation explicit rather than assumed.

#### Scenario: An unannotated field silently overwrites

- **WHEN** a node returns a partial state update for a field with no reducer annotation
- **THEN** the skill SHALL state that the field is replaced, not merged, and that this holds even where the previous value was itself accumulated over several prior nodes

### Requirement: Conditional-Edge Routing and Recursion Limits Are Covered

The skill SHALL state that a conditional-edge routing function returning a string with no matching node name fails at graph *execution* time, not at graph *definition* time — the graph compiles successfully regardless.

The skill SHALL state that a cyclic graph requires an explicit recursion-limit awareness, and SHALL name agent-to-agent handoff loops (a routes to b, b routes back to a, indefinitely) as a concrete case of a cycle that reaches the default limit in a multi-agent graph.

#### Scenario: A routing function's typo is not caught at compile time

- **WHEN** a conditional edge's routing function can return a node name that does not exist in the graph
- **THEN** the skill SHALL state that this is only discovered when that branch executes, not when the graph is built

#### Scenario: A handoff loop is named as a recursion-limit case

- **WHEN** two or more agents can route to each other
- **THEN** the skill SHALL state that an unbounded handoff cycle will hit the recursion limit, and name the handoff loop explicitly rather than leaving recursion limits as an abstract warning

### Requirement: Checkpointer Choice and Persistence Are Covered

The skill SHALL state that `MemorySaver` (or an equivalent in-process, non-persistent checkpointer) behaves identically to a persistent checkpointer in every local run and loses all state on process restart, and SHALL require this trade-off be surfaced before `MemorySaver` is used in anything other than local development or a test.

The skill SHALL state the thread-ID hygiene requirement for checkpointed state: a thread ID scheme that does not uniquely separate one user's or one session's state from another's leaks state across them.

The skill SHALL cover subgraph state-passing: a parent graph and a subgraph exchange state through their respective schemas, and a mismatch between the two silently drops or fails to pass through fields whose names or types don't line up.

#### Scenario: MemorySaver's restart behavior is stated, not left implicit

- **WHEN** a graph is being set up with a checkpointer and the choice is `MemorySaver` or an equivalent
- **THEN** the skill SHALL state that this choice does not survive a process restart, before that choice is made for anything beyond local development or testing

#### Scenario: Thread IDs are not left to collide

- **WHEN** a graph is checkpointed across multiple users or sessions
- **THEN** the skill SHALL require a thread-ID scheme that keeps their state from being read into or overwriting each other

### Requirement: Streaming-Mode and Testing Distinctions Are Covered

The skill SHALL state that LangGraph's streaming modes (`values`, `updates`, `messages`, and any other mode the invoking API exposes) return meaningfully different shapes, and that choosing the wrong one for a given consumer (for example, a UI expecting incremental token output) is a common mismatch.

The skill SHALL state that `.invoke()` and `.stream()` can diverge in observed behavior, and that a test written against one does not by itself establish correctness of the other.

#### Scenario: A streaming-mode choice is deliberate

- **WHEN** a graph's output is consumed by something that expects a specific shape (for example, incremental tokens for a chat UI)
- **THEN** the skill SHALL require the streaming mode be chosen for that shape rather than left at a default

#### Scenario: Invoke-only testing is flagged as incomplete

- **WHEN** a graph is tested only through `.invoke()` but is also exposed through `.stream()` in production
- **THEN** the skill SHALL state that this does not establish the streaming path is correct

### Requirement: Multi-Agent Handoff and Tool-Calling Patterns Are Covered in Depth

The skill SHALL cover, in its multi-agent and tool-calling material: the distinction between a supervisor pattern (a central router directing agents) and a swarm/direct-handoff pattern (agents routing to each other directly); the `Command` object as a mechanism for combining a state update and a routing decision in a single node return; the prebuilt `ToolNode` and `tools_condition` routing helpers for tool-calling graphs; the requirement that a single AI message issuing multiple tool calls receive a matching `ToolMessage` for each; and that a failed or malformed tool call be handled explicitly rather than left to propagate as an unhandled exception.

The skill SHALL cover approval-gated tool calls: using `interrupt()` to pause graph execution before a sensitive tool call fires, pending human approval, as distinct in mechanism and in intent from any confirmation gate this library's own assets impose on the assistant's actions.

#### Scenario: A handoff pattern is named, not assumed

- **WHEN** a multi-agent graph is being designed
- **THEN** the skill SHALL distinguish the supervisor and swarm/direct-handoff shapes rather than presenting one as the only pattern

#### Scenario: Parallel tool calls each get a response

- **WHEN** a single AI message contains more than one tool call
- **THEN** the skill SHALL require a `ToolMessage` response for each tool call, matched by its call ID

#### Scenario: interrupt() is distinguished from this library's own hitl convention

- **WHEN** the skill covers `interrupt()`-gated tool approval
- **THEN** it SHALL state that this is a property of the authored graph pausing for human input, not an instance of this library's own assistant-side confirmation-gate convention

### Requirement: API Claims Are Verified Against the Released Package

Claims this skill makes about `langgraph`'s current API surface — including the reducer annotation idiom, the `Command` object, `ToolNode`/`tools_condition`, and `interrupt()` — SHALL be verified against the current released `langgraph` package during authoring rather than written from assumption.

Where a live environment with `langgraph` installed is unavailable during authoring, the skill's claims SHALL be sourced from the package's own current published documentation, and the authoring record SHALL state that the claim rests on documentation rather than a live check.

#### Scenario: An API claim traces to a verified source

- **WHEN** the skill states how a specific LangGraph construct behaves
- **THEN** that claim SHALL have been checked against an installed `langgraph` package or its current published documentation during authoring, not carried from unverified prior familiarity

### Requirement: Consuming Project Conventions Take Precedence

The skill SHALL declare itself a floor rather than an authority: a consuming project's `AGENTS.md`, `CLAUDE.md`, and existing code override it wherever they conflict, matching the deference convention `bash-practice` and `terraform-practice` already state.

It SHALL instruct that those be read before LangGraph work begins in an unfamiliar repository, and SHALL require that a conflict between its own guidance and a project convention be reported rather than silently resolved.

Where a question turns on a project decision — which checkpointer backend is used, the project's state-schema conventions, or its deployment target (LangGraph Platform, self-hosted, or otherwise) — and the project records no convention at all, the skill SHALL state that the answer is project-specific and ask, rather than supplying one from assumption.

#### Scenario: Project convention wins a conflict

- **WHEN** a consuming project's recorded convention or established code contradicts a preference stated in the skill
- **THEN** the project's convention SHALL be followed and the conflict reported rather than silently resolved

#### Scenario: Absent conventions produce a question, not an invention

- **WHEN** a project-specific question arises — checkpointer backend, state-schema conventions, or deployment target — in a repository that records no conventions
- **THEN** the skill SHALL state that the answer is project-specific and ask, rather than supplying one from assumption

### Requirement: Structure Separates the Always-Resident Floor from On-Demand Depth

The skill SHALL ship as a split structure: a `SKILL.md` carrying, at minimum, the scope statement, state/reducer, conditional-edge/routing, recursion-limit, streaming-mode, and testing guidance, and consuming-project deference as the always-resident floor, and `references/` files carrying checkpointer/persistence depth and multi-agent/tool-calling depth, loaded on demand rather than resident on every trigger.

`SKILL.md` SHALL close with a pointer naming both reference files, so the on-demand material is reachable from the floor rather than left for the reader to discover unprompted.

#### Scenario: Deep multi-agent material is not paid for on every trigger

- **WHEN** the skill is triggered by a question that does not concern multi-agent handoff or tool-calling
- **THEN** the multi-agent/tool-calling reference content SHALL NOT be part of what loads by default

#### Scenario: Deep checkpointing material is not paid for on every trigger

- **WHEN** the skill is triggered by a question that does not concern checkpointer choice, thread IDs, or subgraph state-passing
- **THEN** the checkpointing reference content SHALL NOT be part of what loads by default

#### Scenario: The floor points to where the depth lives

- **WHEN** `SKILL.md`'s content is checked
- **THEN** it SHALL end with a section pointing to both `references/checkpointing.md` and `references/multi-agent-tool-calling.md`, naming what each covers
