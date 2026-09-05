---
name: langgraph
description: >
  This skill should be used when the user is writing, reviewing, or debugging
  a LangGraph application in Python — "write a langgraph agent", "build a
  multi-agent system with langgraph", "add a node to my graph", "why is my
  graph stuck in a loop", "MemorySaver or Postgres checkpointer", "handle a
  failed tool call", "review my graph.py" — or any task touching StateGraph,
  node/edge definitions, checkpointers, or interrupt()/tool-calling. It
  covers floor-level Python discipline: state/reducer design,
  conditional-edge routing, recursion limits, checkpointer/persistence
  choice, streaming modes, testing at each level, subgraphs, and — in depth
  — multi-agent handoff and tool-calling error handling. It is specific to
  the Python langgraph package, not JS/TS @langchain/langgraph or general
  agent-framework advice. Not about authoring library assets, OpenSpec work,
  Terraform, or n8n workflows. A project's own checkpointer backend, schema
  conventions, and deployment target take precedence in that project's
  AGENTS.md.
metadata:
  tags: [langgraph]
---

# langgraph

General-purpose practice for writing and reviewing Python LangGraph applications. Like `bash` and `terraform`, this is a floor: what holds regardless of whether the graph is single-agent or multi-agent, not a tutorial on what a node or an edge is. Content verified live against `langgraph` 1.2.11 on 2026-08-13; treat version-specific claims (defaults, signatures) as a dated snapshot rather than permanent fact.

Scope is the Python `langgraph` package. The JS/TS `@langchain/langgraph` SDK is a different package with its own API surface and is out of scope here.

## State schema and reducers

A state field with no reducer is **overwritten**, not merged, on every node return — silently, with no error or warning. A node that returns a partial update for an unannotated field replaces whatever was there, even if the previous value was itself accumulated across several prior nodes.

Accumulating fields need an explicit reducer: `Annotated[list[AnyMessage], add_messages]` for message history, or a custom merge function for anything else. Don't assume a bare `list` field appends — it doesn't, unless annotated.

`add_messages` itself has a second trap once adopted: it merges by message **ID**, not by blind append. Two messages with different IDs append as expected; two messages sharing an ID cause the second to silently replace the first rather than appending. This is usually what's wanted (editing a message in place), but it means duplicating an ID to "add" a message is a bug that produces no error — it produces a replacement.

## Conditional edges and routing

A conditional edge's routing function returning a value that names no node is not one failure mode — it's three, and which one you get depends on whether the graph was given anything to check against. With no `path_map` and no `Literal`-annotated return type declaring the destinations, `.compile()` succeeds and a bad return isn't even raised as an exception — LangGraph logs it (`wrote to unknown channel ... ignoring it`) and the branch silently does nothing, which a test asserting only on the final state won't catch. Declare destinations via a `path_map` or a `Literal` return annotation and a return value absent from them raises `KeyError` — but only when that branch runs, not at `.compile()`. Only a *declared* destination that names no real node — a `path_map` value or a `Literal` member, not what the function returns — is caught at `.compile()` time. Adding a `path_map` turns a silent no-op into a loud `KeyError`, which is worth having, but it is not compile-time protection against a routing typo — nothing checks what the function actually returns until the graph runs.

## Recursion limits and cycles

Cyclic graphs need explicit attention to the recursion limit. The default is high — 10007 as of `langgraph` 1.2.11, not the "25" still floating around in older tutorials — so the practical risk of an unbounded cycle isn't hitting a low ceiling quickly; it's burning a large number of steps, and whatever they cost, before `GraphRecursionError` fires. An agent handoff loop (A routes to B, B routes back to A, indefinitely) is a concrete case of a cycle that can run for a long time before that error surfaces. Set an explicit, deliberately tight `recursion_limit` for any graph with a cycle, rather than relying on the default to catch a runaway loop early.

## Checkpointing, briefly

`MemorySaver` (or an equivalent in-process, non-persistent checkpointer) behaves identically to a persistent checkpointer in every local run and loses all state the moment the process restarts. Surface that trade-off explicitly before it's used for anything beyond local development or a test. See `references/checkpointing.md` for thread-ID hygiene and subgraph state-passing.

## Streaming modes

LangGraph's streaming modes (`values`, `updates`, `messages`, and any other mode the invoking API exposes) return meaningfully different shapes. Picking the wrong one for a given consumer — a UI expecting incremental token output getting whole-state snapshots instead, for instance — is a common mismatch. Choose the mode for what the consumer actually needs rather than leaving it at whatever a first example used.

## Testing

`.invoke()` and `.stream()` can diverge in observed behavior. A graph tested only through `.invoke()` but also exposed through `.stream()` in production has not had its streaming path tested by that alone.

A graph also presents four distinct things a test can observe, and picking a level above the smallest one that can observe the behavior costs speed and determinism without adding evidence. A **node's** behavior is testable by calling it directly with a state dict — no graph involved. A **routing decision** is testable by calling whatever makes it: the conditional edge's path function where the edge is conditional, or the node itself where routing is a `Command(goto=...)` return, since that form has no separate path function at all. That a routing decision **reaches the intended node** needs the compiled graph — see *Conditional edges and routing*, above, for what that check does and doesn't catch. Behavior spanning **turns** needs a checkpointer. See `references/testing.md` for how to construct a test at each level, and for stubbing a model to emit tool calls — the part that's actually hard.

## Read the project's conventions first

This skill is a floor, not an authority. A consuming project's `AGENTS.md`, `CLAUDE.md`, and existing code override it wherever they conflict — read those first in an unfamiliar repository, and report a conflict rather than silently resolving it. Where a question turns on a project decision this skill can't answer — which checkpointer backend is used, the project's own state-schema conventions, its deployment target (LangGraph Platform, self-hosted, or otherwise) — and the project records no convention at all, say so and ask rather than supplying an answer from assumption. A repository with nothing recorded is the normal case, not an edge case.

## Where to go deeper

- `references/checkpointing.md` — checkpointer choice and the restart trade-off, thread-ID hygiene for multi-tenant checkpointed state, and subgraph state-passing when a parent and child graph's schemas don't line up.
- `references/multi-agent-tool-calling.md` — supervisor vs. swarm handoff patterns, the `Command(goto=, update=)` idiom, `ToolNode` and `tools_condition`, parallel tool calls, tool-call error handling, and `interrupt()`-gated approval for sensitive tool calls.
- `references/testing.md` — stubbing a model to emit tool calls, constructing a test at each level of the ladder above, and checkpointer-backed state across turns.

For the language-agnostic discipline this skill's testing content assumes rather than restates — what a baseline establishes, what each failure state establishes, how an assertion's provenance is classified — load `ai-toolkit:testing` alongside this skill.

## Trigger check fixtures

The prompts this skill's own authoring verified against, kept here so a later edit to the description can be re-verified against the same pair rather than inventing a new one from scratch. Only the prompts and expected routing are recorded — never the outcome or the run date, since a description edit invalidates whatever was last confirmed.

- **Positive** — "I'm building a multi-agent LangGraph app in Python and my graph keeps hitting a recursion limit error when two agents hand off to each other in a loop — how do I fix this?" → expected routing: `langgraph`.
- **Negative** — "I'm building a multi-agent chatbot with the @langchain/langgraph JS SDK in a Next.js app — how should I structure the handoffs between agents?" → expected routing: none — no asset in this library covers the JS/TS `@langchain/langgraph` SDK, and `langgraph`'s own description excludes it explicitly.
- **Positive, testing coverage** — "How do I stub the LLM in my LangGraph test so it emits a tool call?" → expected routing: `langgraph` **and** `testing` together. Recorded as co-triggering rather than exclusive, since this skill supplies the LangGraph-specific stubbing mechanism and `testing` supplies the language-agnostic discipline it builds on — see `testing`'s own fixtures for the amended pass standard this follows.
