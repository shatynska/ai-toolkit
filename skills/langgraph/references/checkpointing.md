# Checkpointing and persistence

Verified against `langgraph` 1.2.11 / `langgraph_checkpoint` 4.2.0 on 2026-08-13.

## Checkpointer choice

`MemorySaver` (`langgraph.checkpoint.memory.MemorySaver`, an alias for `InMemorySaver`) implements the same `BaseCheckpointSaver` interface every other checkpointer does, and in every local run — every test, every demo, every debugging session — it behaves exactly like a persistent backend. The difference only shows up on process restart, when everything it held is gone. This makes it a trap specifically because nothing about using it *looks* wrong until the one moment it matters.

Treat `MemorySaver` as fine for local development and tests, and treat "this needs to survive a restart, scale beyond one process, or be inspectable outside the running process" as the trigger to move to a persistent backend (Postgres, SQLite, Redis, or another `BaseCheckpointSaver` implementation — each ships as its own package, e.g. `langgraph-checkpoint-postgres`, `langgraph-checkpoint-sqlite`, built against the same interface). Surface this trade-off explicitly rather than letting `MemorySaver` quietly become the production choice because it was the first thing that worked.

## Thread ID hygiene

Checkpointed state is keyed by `thread_id`, passed via `config = {"configurable": {"thread_id": "..."}}`. It's the primary key for retrieving and continuing a specific run's state — there's no default isolation beyond what the `thread_id` scheme itself provides.

A thread-ID scheme that doesn't uniquely separate one user's or one session's state from another's will read or overwrite across them: reusing a fixed or predictable `thread_id` across users leaks one user's conversation history and any interrupted state into another's. Generate or derive `thread_id` from something that's actually unique per conversation/session/user in the application's own terms — a random UUID per session is the common baseline, not a constant or a value derived from something shared across users.

## Subgraph state-passing

A parent graph and a subgraph exchange state through their respective state schemas. When a subgraph is added as a node in a parent graph, LangGraph passes state between them by matching field names (and, depending on how the subgraph is wired in, by whether the schemas share those keys directly or the parent maps them explicitly). A field the parent's schema doesn't have — or has under a different name or a different type — doesn't transfer: it's silently absent on one side rather than raising an error. Where a subgraph's state needs to differ from its parent's, be deliberate about which fields are meant to cross the boundary and check that both schemas agree on the fields that must.
