## MODIFIED Requirements

### Requirement: Conditional-Edge Routing and Recursion Limits Are Covered

The skill SHALL state that a conditional-edge routing function **returning** a value with no matching node surfaces at graph *execution* time rather than at graph *definition* time — and SHALL state this as holding **regardless of whether a `path_map` is supplied**, because the returned value is resolved when the branch runs.

The skill SHALL distinguish that from what `compile()` *does* check, drawing the line on the **declared-versus-returned** axis rather than on the presence of a `path_map`: where destinations are declared at definition time — the values of an explicit `path_map`, or the members of a `Literal` return annotation — `compile()` validates those declared destinations against the graph's nodes and raises there if one names no node. That check covers what was declared, not what the function returns. With a dict `path_map` the two are not even the same string: the function returns a *key* and the map supplies the *node*, so a typo in the returned key is untouched by anything `compile()` validated.

Stating the compile-time check as though supplying a `path_map` catches routing typos is worse than stating the execution-time claim unconditionally, because it invites a reader to add a `path_map` expecting protection it does not provide.

The skill SHALL state that a cyclic graph requires an explicit recursion-limit awareness, and SHALL name agent-to-agent handoff loops (a routes to b, b routes back to a, indefinitely) as a concrete case of a cycle that reaches the default limit in a multi-agent graph.

#### Scenario: A routing function's typo is not caught at compile time

- **WHEN** a conditional edge's routing function can return a value that matches no node, **whether or not** the graph was given a `path_map` or a `Literal`-annotated destination set
- **THEN** the skill SHALL state that this is only discovered when that branch executes, and SHALL NOT present a `path_map` as protection against it

#### Scenario: A declared destination naming no node is caught at compile time

- **WHEN** an explicit `path_map` value, or a `Literal` return-annotation member, names a node that does not exist in the graph
- **THEN** the skill SHALL state that `compile()` validates the declared destinations and raises there — a different check from what the routing function returns

#### Scenario: A handoff loop is named as a recursion-limit case

- **WHEN** two or more agents can route to each other
- **THEN** the skill SHALL state that an unbounded handoff cycle will hit the recursion limit, and name the handoff loop explicitly rather than leaving recursion limits as an abstract warning

### Requirement: Streaming-Mode and Testing Distinctions Are Covered

The skill SHALL state that LangGraph's streaming modes (`values`, `updates`, `messages`, and any other mode the invoking API exposes) return meaningfully different shapes, and that choosing the wrong one for a given consumer (for example, a UI expecting incremental token output) is a common mismatch.

The skill SHALL state that `.invoke()` and `.stream()` can diverge in observed behavior, and that a test written against one does not by itself establish correctness of the other.

The always-resident floor SHALL additionally state the **test-level ladder** a graph presents, distinguishing four things a test can observe rather than three:

- **A node's behavior** — testable by calling the node as a plain function with a state dict; no graph is involved.
- **A routing decision** — testable without a compiled graph, by calling whatever makes the decision. Where the edge is conditional, that is the path function: in the common case a plain callable taking state and returning a destination key, though it may also return a list of destinations where the edge fans out, and may be async or take a config argument. Where routing is a **node return** — a node returning `Command(goto=...)`, which this skill covers as a mechanism combining a state update and a routing decision — there is no path function, and the decision is observed by calling the node and asserting on the returned `Command`'s destination. The floor SHALL cover both, because a ladder naming only the path function sends a reader testing a `Command`-routed supervisor to the compiled graph, which is the escalation this ladder exists to prevent.
- **That a routing decision reaches the intended node** — testable only through the compiled graph, because what the routing function *returns* is resolved when the branch runs, so a returned value matching no node surfaces at execution whether or not a `path_map` was supplied. `compile()` checks a different thing: the destinations *declared* to it — `path_map` values, or `Literal` annotation members, which a bare `-> str` is not — against the graph's nodes. The floor SHALL keep those two apart rather than presenting a `path_map` as protection against a returned-value typo.
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

## ADDED Requirements

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
