# Multi-agent handoff and tool-calling

Verified against `langgraph` 1.2.11 / `langgraph_prebuilt` 1.1.0 on 2026-08-13.

## Handoff patterns: supervisor vs. swarm

Multi-agent coordination in LangGraph is built on one primitive — `Command(goto=..., update=...)` (see below) — not on separate built-in "supervisor" and "swarm" APIs in the core `langgraph` package. (Dedicated `langgraph-supervisor` and `langgraph-swarm` packages exist for the prebuilt versions of these patterns; they're separate installs, out of scope for this skill's core-package coverage.)

The distinction is architectural, not mechanical:

- **Supervisor** — a central node routes to worker agents and receives control back after each one, deciding what happens next. Workers don't route to each other directly.
- **Swarm / direct handoff** — agents route to each other directly via `Command(goto=<next_agent>)`, with no central router in the loop for every step.

Both are graphs built from ordinary nodes and `Command` returns. Naming which shape a given graph uses is the useful decision — not which API to call, since there's one API either way.

## `Command(goto=, update=)`

`Command` combines a state update and a routing decision in a single node return, instead of returning state and letting a separate conditional edge decide where to go next. Current signature (`langgraph.types.Command`): `Command(*, graph=None, update=None, resume=None, goto=())`.

- `update` — the state update, same as an ordinary node return.
- `goto` — the next node (or nodes, or a `Send`) to route to, replacing a conditional edge for this transition.
- `graph` — targets the current graph (default) or `Command.PARENT`, for a subgraph handing control back to its parent.
- `resume` — paired with `interrupt()`, not with routing; see below.

Because `goto` is a plain node-name string with no static check against the graph's actual node set, the same typo/stale-name risk that applies to conditional-edge routing functions (see `SKILL.md`) applies here too — a `Command(goto="wrong_name")` fails at execution, not at `.compile()`.

## `ToolNode` and `tools_condition`

`langgraph.prebuilt.ToolNode` executes the tool calls attached to the last `AIMessage` and manages parallel execution automatically — it is not something to build by hand for the common case. `langgraph.prebuilt.tools_condition` is the matching conditional-edge helper: `tools_condition(state, messages_key='messages')` returns `'tools'` if the last message has tool calls, `'__end__'` otherwise.

## Parallel tool calls

A single `AIMessage` can carry multiple tool calls at once. Each one requires a matching `ToolMessage` in the response, tied back by `tool_call_id` — the underlying chat-completion APIs this wraps reject a follow-up call that's missing a `ToolMessage` for any `tool_call_id` the prior `AIMessage` issued. `ToolNode` handles this correctly by default when used as intended; a hand-rolled tool-execution node that only handles the first tool call, or that drops a call on an error path, breaks the next model call rather than just skipping a result.

## Tool-call error handling

`ToolNode` has a `handle_tool_errors` parameter, and its **default handler is narrower than "catches errors"**: it catches `ToolInvocationError` specifically, returning the error's message as the `ToolMessage` content so the model can react to it. Any other exception type raised inside a tool function is **re-raised**, not swallowed — it propagates and crashes the graph run. Reaching for `ToolNode` doesn't mean tool errors are handled in general; only the one error type is, out of the box. A tool that can raise something else (a network error, a validation error from a different layer) needs `handle_tool_errors` set explicitly — a bool to catch everything, a specific exception type or tuple of types, or a callable returning the message to send back — if that failure mode should reach the model as a `ToolMessage` instead of crashing the run.

## Approval-gated tool calls via `interrupt()`

`interrupt(value)` (`langgraph.types.interrupt`) pauses a node before a sensitive action fires, surfacing `value` to whatever's driving the graph and waiting for a `Command(resume=...)` to continue. Three behaviors that aren't obvious from the name:

- **It requires a checkpointer.** Without one enabled on `.compile()`, `interrupt()` cannot function at all — the mechanism relies on persisting state to resume from.
- **Resuming re-executes the entire node from its start**, not just from the `interrupt()` call onward. Any side effect placed before the `interrupt()` call inside that node — a partial state mutation, a call to something non-idempotent — runs again on resume. Put `interrupt()` before side effects within a node, or make anything before it safe to repeat.
- **Multiple `interrupt()` calls in one node are matched to resume values by call order**, scoped to that node's specific execution — not shared globally across the graph.

This is the mechanism for gating a tool call on human approval before it runs — call `interrupt()` with a description of the pending action before the tool executes, and only proceed once `Command(resume=...)` supplies an approval.

**This is not this library's own `hitl` convention.** This library tags some of its own skills `hitl` when *the assistant itself* pauses to confirm before taking its own risky action (a Terraform apply, writing a new skill file). `interrupt()` is a property of the *graph being authored* — the code the assistant is helping build — pausing for a human using that application. The two are unrelated: this skill's own authoring carries no `hitl` gate, and `interrupt()` is ordinary LangGraph subject matter covered here like any other primitive.
