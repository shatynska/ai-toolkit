# Testing LangGraph applications

Depth on stubbing a model, constructing a test at each level of the ladder
`SKILL.md`'s `## Testing` section states, and checkpointer-backed state
across turns. See `SKILL.md` for the always-resident floor; this file loads
only when a question concerns writing or reviewing a test for a graph.

Verified against `langgraph` 1.2.11 / `langgraph_checkpoint` 4.2.0 /
`langgraph_prebuilt` 1.1.0 / `langchain_core` 1.5.5 on 2026-08-16. This file
states LangGraph-and-Python specifics only — for what a baseline
establishes, what each failure state establishes, how an assertion's
provenance is classified, and why weakening an existing test destroys it,
load `ai-toolkit:testing`; for `pytest` mechanics not specific to LangGraph,
load `ai-toolkit:python`. Load all relevant skills together before writing a
test; this file does not restate what they own.

**Real-model calls don't belong in this loop.** A test invoking an actual
model is nondeterministic, costs money on every run, and is unsuited to
anything exercised on every change. Whether a project keeps a separate
real-model suite outside this loop is that project's own decision — read its
conventions first.

## Stubbing a model that emits tool calls — the part that's actually hard

Stubbing a model to return plain text is trivial and doesn't need this file.
The part worth documenting is a stub that emits **tool calls**, because a
graph's tool-calling path is driven by `tool_calls` on the model's response —
a text-only stub cannot reach it at all.

`langchain_core.language_models.fake_chat_models.FakeMessagesListChatModel`
returns pre-built messages from a list you supply, one per call. Attach tool
calls directly on the `AIMessage`:

```python
from langchain_core.language_models.fake_chat_models import FakeMessagesListChatModel
from langchain_core.messages import AIMessage

tool_call_response = AIMessage(
    content="",
    tool_calls=[{"name": "get_weather", "args": {"city": "Paris"}, "id": "call_1"}],
)
model = FakeMessagesListChatModel(responses=[tool_call_response])
```

Verified this is the actual mechanism that drives routing, not just a
plausible-looking construction: calling `tools_condition` directly on state
holding this message returns `"tools"`. The identical call with a
`AIMessage(content="sunny, I guess")` — no `tool_calls` — returns `"__end__"`.
A stub without `tool_calls` set silently never reaches the tool node, and a
test built on one establishes nothing about the tool-calling path regardless
of how confident its assertions look.

For a multi-turn conversation, supply one message per turn in `responses` —
`FakeMessagesListChatModel` returns them in order, one per `invoke()` call.

## Constructing a test at each level of the ladder

`SKILL.md`'s `## Testing` section states four things a test can observe. Each
is constructed differently:

**A node's behavior** — call the node function directly with a state dict.
No graph, no compilation, no model:

```python
result = my_node({"messages": [HumanMessage("hi")]})
```

**A routing decision, where the edge is conditional** — call the path
function directly with a state dict; it's an ordinary callable, and no graph
is needed to observe what it returns:

```python
assert my_router({"messages": [tool_call_response]}) == "tools"
```

**A routing decision, where routing is a node return** — a node returning
`Command(goto=...)` has no separate path function. Call the node and assert
on the returned `Command`'s destination:

```python
result = supervisor_node(state)
assert result.goto == "researcher"
```

**That a routing decision reaches the intended node** — this is the one
level that genuinely needs the compiled graph, and it's a narrower claim than
"testing routing needs a graph." Verified with three constructions, because
the actual behavior has three distinct outcomes, not two:

- **No declared destinations** (a bare conditional edge — no `path_map`, no
  `Literal`-annotated return type): a returned value matching no node is
  **not an exception**. LangGraph logs it —
  `WARNING:langgraph:Task ... wrote to unknown channel branch:to:<value>,
  ignoring it` — and the graph simply doesn't proceed via that edge.
  `invoke()` returns normally. A test asserting only on the final state sees
  a clean run; this is the quietest form of the bug, not the loudest.
- **A `path_map` (or `Literal` return type) is declared, and the function
  returns a value absent from it**: this raises — `KeyError` — but only when
  the graph runs, not when it compiles.
- **A declared destination itself names a node that doesn't exist** — a
  `path_map` value, or a `Literal` member: `compile()` catches this, raising
  `ValueError` before the graph ever runs.

The practical trap: adding a `path_map` does **not** make a routing typo
safe by itself. It changes a silent no-op into a raised `KeyError` at
execution — worth having, since a raised error is easier to catch than a
silent one — but it is not the compile-time protection the *declared*
destination case gets. Only a destination *named directly in the `path_map`
or `Literal` annotation* is checked at `compile()`; what the function
actually *returns* at runtime is never compared against anything until the
graph runs.

## Cross-turn state needs a checkpointer, and the thread ID is what ties turns together

Behavior spanning turns — memory, follow-up questions, anything depending on
history from an earlier `invoke()` — is only observable with a checkpointer
attached and the same `thread_id` used across calls. `InMemorySaver`
(`langgraph.checkpoint.memory`) needs no arguments and is what makes such a
test deterministic and self-contained — no external service, no state
surviving between unrelated test runs:

```python
from langgraph.checkpoint.memory import InMemorySaver

graph = builder.compile(checkpointer=InMemorySaver())
config = {"configurable": {"thread_id": "test-thread-1"}}

graph.invoke({"messages": [HumanMessage("hi")]}, config)
result = graph.invoke({"messages": [HumanMessage("and then?")]}, config)
# result reflects both turns -- verified: the second invoke() sees state
# accumulated from the first, only because the thread_id matched.
```

Give every test its own `thread_id` (a fresh UUID, or the test's own name) —
sharing one across tests reintroduces exactly the cross-test state leakage a
`function`-scoped `pytest` fixture exists to avoid. For thread-ID hygiene
beyond a single test's construction — multi-tenant checkpointed state, when
a thread ID must be namespaced — see `references/checkpointing.md`, which
this file does not restate.

## Where to go deeper

This file is depth for `skills/langgraph`'s always-resident floor. See
`SKILL.md`'s own `Where to go deeper` section for the sibling references
(checkpointing and persistence depth, multi-agent and tool-calling
patterns), and `ai-toolkit:testing` for the language-agnostic discipline
this file assumes rather than restates.
