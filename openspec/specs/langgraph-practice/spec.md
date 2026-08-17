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

The skill SHALL distinguish **three** outcomes for a conditional edge's destination, verified live rather than assumed from either the unconditional or the two-way qualified form either read as sufficient:

- **No destinations declared** (a bare conditional edge — no `path_map`, no `Literal`-annotated return type): a returned value matching no node is **not raised as an exception at all**. It is logged by LangGraph's own logger at `WARNING` level (`"...wrote to unknown channel...ignoring it"`) and the graph silently does not proceed via that edge — `invoke()` returns normally. A test asserting only on the final state or the return value sees nothing wrong; this is a *quieter* trap than a raised exception, not merely a deferred one.
- **Destinations declared** (an explicit `path_map`, or a `Literal`-annotated return type) **and the function returns a value absent from them**: this raises — a `KeyError` — but only at graph *execution*, not at `compile()`. With a dict `path_map` the returned value and the destination are not even the same string: the function returns a *key*, the map supplies the *node*, and `compile()` validates only the map's own declared values, never what the function might return at runtime.
- **A declared destination itself names a node that does not exist** — a `path_map` value, or a `Literal` member — is caught at `compile()`, which validates the declared set against the graph's nodes.

The skill SHALL state plainly that supplying a `path_map` does **not** make a returned-value typo safe: it changes a silent no-op into a raised `KeyError`, which is a real improvement for a test to catch, but it is not the compile-time protection the *declared* case provides, and the two SHALL NOT be conflated.

The skill SHALL state that a cyclic graph requires an explicit recursion-limit awareness, and SHALL name agent-to-agent handoff loops (a routes to b, b routes back to a, indefinitely) as a concrete case of a cycle that reaches the default limit in a multi-agent graph.

#### Scenario: A routing function's typo is not caught at compile time

- **WHEN** a conditional edge's routing function can return a value that matches no node, **whether or not** the graph was given a `path_map` or a `Literal`-annotated destination set
- **THEN** the skill SHALL state that no case catches it at `compile()`, and SHALL NOT present a `path_map` as protection against it — only as the difference between a silent no-op and a raised `KeyError`, both at execution

#### Scenario: An undeclared destination is a silent no-op, not a raised error

- **WHEN** a conditional edge has no `path_map` and no `Literal`-annotated return type, and the routing function returns a value matching no node
- **THEN** the skill SHALL state that no exception is raised — LangGraph logs a warning and the graph does not proceed via that edge — which is quieter than a raised error and easier to miss in a test that only checks the return value

#### Scenario: A declared destination naming no node is caught at compile time

- **WHEN** an explicit `path_map` value, or a `Literal` return-annotation member, names a node that does not exist in the graph
- **THEN** the skill SHALL state that `compile()` validates the declared destinations and raises there — a different check from what the routing function returns

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

The always-resident floor SHALL additionally state the **test-level ladder** a graph presents, distinguishing four things a test can observe rather than three:

- **A node's behavior** — testable by calling the node as a plain function with a state dict; no graph is involved.
- **A routing decision** — testable without a compiled graph, by calling whatever makes the decision. Where the edge is conditional, that is the path function: in the common case a plain callable taking state and returning a destination key, though it may also return a list of destinations where the edge fans out, and may be async or take a config argument. Where routing is a **node return** — a node returning `Command(goto=...)`, which this skill covers as a mechanism combining a state update and a routing decision — there is no path function, and the decision is observed by calling the node and asserting on the returned `Command`'s destination. The floor SHALL cover both, because a ladder naming only the path function sends a reader testing a `Command`-routed supervisor to the compiled graph, which is the escalation this ladder exists to prevent.
- **That a routing decision reaches the intended node** — testable only through the compiled graph, verified against the graph's actual behavior: a returned value matching no node is a **silent no-op** (logged, not raised) when nothing is declared, and a raised `KeyError` at execution when a `path_map`/`Literal` is declared but the return isn't among its values; `compile()` catches only a *declared* destination naming a missing node. The floor SHALL state which of the three applies rather than collapsing them, and SHALL NOT present a `path_map` as compile-time protection against a returned-value typo.
- **Behavior spanning turns** — testable only with a checkpointer.

The floor SHALL NOT state that routing as such requires the compiled graph: conflating the decision with the wiring pushes a test to a heavier level than the behavior needs. Which level to choose is the library testing skill's rule and SHALL be cross-referenced rather than restated here; this requirement states only what each level in a graph can observe. Depth on how to construct each — in particular how to stub a model that emits tool calls — SHALL be carried in a reference rather than in the floor.

#### Scenario: A streaming-mode choice is deliberate

- **WHEN** a graph's output is consumed by something that expects a specific shape (for example, incremental tokens for a chat UI)
- **THEN** the skill SHALL require the streaming mode be chosen for that shape rather than left at a default

#### Scenario: Invoke-only testing is flagged as incomplete

- **WHEN** a graph is tested only through `.invoke()` but is also exposed through `.stream()` in production
- **THEN** the skill SHALL state that this does not establish the streaming path is correct

#### Scenario: A routing decision is separated from the wiring it depends on

- **WHEN** a conditional edge's routing decision is what needs covering
- **THEN** the floor SHALL state that the path function is callable directly and is the smallest thing that observes the decision, and that the compiled graph is needed only to establish the returned key reaches the intended node

#### Scenario: Calling the node does not exercise a conditional edge

- **WHEN** the behavior under test is which branch a **conditional edge** selects
- **THEN** the floor SHALL state that calling the node itself does not exercise the edge, since that routing decision lives in the path function rather than in the node

#### Scenario: A Command-routed decision is observed at the node

- **WHEN** routing is expressed as a node returning `Command(goto=...)` rather than as a conditional edge
- **THEN** the floor SHALL state that the node itself is the smallest thing that observes the decision, and SHALL NOT direct the reader to a compiled graph for it

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

The skill SHALL ship as a split structure: a `SKILL.md` carrying, at minimum, the scope statement, state/reducer, conditional-edge/routing, recursion-limit, streaming-mode, and testing guidance, and consuming-project deference as the always-resident floor, and `references/` files carrying checkpointer/persistence depth, multi-agent/tool-calling depth, and **testing depth** (model stubbing, per-level test construction, and checkpointer-backed state across turns), loaded on demand rather than resident on every trigger.

`SKILL.md` SHALL close with a pointer naming each reference file — `references/checkpointing.md`, `references/multi-agent-tool-calling.md`, and `references/testing.md` — so the on-demand material is reachable from the floor rather than left for the reader to discover unprompted. Naming them in this requirement's body rather than only in a scenario is deliberate: the scenario below generalises to "each `references/` file" now that there are three, and the file-level precision the previous wording carried would otherwise be lost.

#### Scenario: Deep multi-agent material is not paid for on every trigger

- **WHEN** the skill is triggered by a question that does not concern multi-agent handoff or tool-calling
- **THEN** the multi-agent/tool-calling reference content SHALL NOT be part of what loads by default

#### Scenario: Deep checkpointing material is not paid for on every trigger

- **WHEN** the skill is triggered by a question that does not concern checkpointer choice, thread IDs, or subgraph state-passing
- **THEN** the checkpointing reference content SHALL NOT be part of what loads by default

#### Scenario: Deep testing material is not paid for on every trigger

- **WHEN** the skill is triggered by a question that does not concern writing or reviewing tests
- **THEN** the testing reference content SHALL NOT be part of what loads by default

#### Scenario: The floor points to where the depth lives

- **WHEN** `SKILL.md`'s content is checked
- **THEN** it SHALL end with a section pointing to each `references/` file, naming what each covers

### Requirement: LangGraph Testing Depth Covers Model Stubbing and Per-Level Construction

The skill SHALL carry LangGraph-specific testing depth, covering at minimum:

- **Stubbing a model**, including the case that actually matters: a fake returning plain text is trivial, while a fake that emits **tool calls** — so a conditional edge routes into a tool node and the graph's tool-calling path is exercised — is the fiddly part and the reason this material exists. The skill SHALL name the mechanism by which a stubbed response carries tool calls, and SHALL state that a stub returning only text cannot exercise a tool-calling branch at all.
- **Constructing a test at each level**, matching the ladder the floor states rather than a shorter one: a node as a plain function called with a state dict; a **routing decision** by calling whatever makes it — the conditional edge's path function where the edge is conditional, or the node itself where routing is a `Command(goto=...)` node return, asserting on the returned `Command`'s destination; that the decision **reaches the intended node** through the compiled graph; and behavior across turns with a checkpointer and a stable thread ID. The reference SHALL NOT present the compiled graph as the way to test a routing decision — that is the level above the smallest one that can observe it, and the floor forbids the framing.
- **Checkpointer-backed state across turns**, including that an in-process checkpointer is what makes a multi-turn test deterministic and self-contained, and the thread-ID hygiene a multi-turn test depends on.

The skill SHALL state that a real model call in a test is nondeterministic, costs money per run, and is therefore unsuited to a test exercised on every change — while leaving whether a project keeps a separate real-model suite to that project's own conventions.

Every API claim in this material — the stub type used, how tool calls are attached to a stubbed response, the checkpointer's constructor — SHALL be verified against the released package before it is written, and the verified version recorded. Where a live check is not possible, this capability's existing verification requirement permits the claim to be sourced from current documentation instead, provided the reliance on documentation rather than a live check is recorded **both in the authoring record, as that existing requirement locates it, and at the point of the claim in the reference itself** — stated identically to the `python-practice` delta, so a blocked install does not stop one reference while permitting the other.

#### Scenario: Stubbing a tool-calling model is answered concretely

- **WHEN** a test must exercise a graph's tool-calling path without invoking a real model
- **THEN** the skill SHALL state how a stubbed response carries tool calls, rather than only stating that a model should be stubbed

#### Scenario: A text-only stub is identified as insufficient for a tool-calling branch

- **WHEN** a stub returns only text and the graph routes on whether the model requested a tool
- **THEN** the skill SHALL state that this cannot exercise the tool-calling branch

#### Scenario: General testing discipline is cross-referenced, not restated

- **WHEN** the testing reference would state what a baseline establishes, what a failure state establishes, or how assertion provenance is classified
- **THEN** it SHALL point to the library's testing skill rather than restating that material
