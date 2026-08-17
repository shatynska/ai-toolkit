# Verification record — add-testing-to-language-skills

Authoring record for every live-verification outcome required by tasks 1.1–1.6.
Where a claim could not be checked live, that is stated here with the fallback
used, per both capabilities' verification requirements.

## pytest

Installed via `pip3 install --target <dir> pytest` (no `venv` available in
this environment — `ensurepip`/`python3-venv` requires system packages).

**Verified version: `pytest==9.1.1`** (`iniconfig 2.3.0`, `packaging 26.3`,
`pluggy 1.6.0`, `pygments 2.20.0`), 2026-08-16.

## pytest claims (task 1.2)

**Bare `assert` rewriting.** Verified: `assert x == y` with `x=5, y=6` inside a
test module produces `E   assert 5 == 6` — pytest rewrites the bare assert to
show the compared values, not a bare `AssertionError`.

**Rewriting boundary.** Verified: the same `assert x == y` inside an *imported,
non-test* module (`mylib/helper.py`, called from a test) produces a plain
`E   AssertionError` with no operand detail — rewriting does not reach
arbitrary imported application code, only test modules and (per pytest's own
docs) registered plugins/`conftest.py`.

**`-O` stripping — more nuanced than the original claim, corrected here.**
Verified under `PYTHONOPTIMIZE=1`:
- A bare `assert` in a **plain script** (no pytest) is stripped entirely, as
  expected from CPython.
- A bare `assert` **inside a pytest test module** is *not* stripped — pytest's
  assertion-rewriting import hook bypasses `-O`, and the test still fails with
  the full rewritten message (`assert 5 == 6`). Pytest itself warns about this:
  *"assertions not in test modules or plugins will be ignored because assert
  statements are not executed by the underlying Python interpreter (are you
  using python -O?)"*.
- An `assert` in an **imported non-test module**, called from a test, *is*
  stripped under `-O` even when pytest is running — the test that previously
  failed now silently **passes**.

  This corrects the delta spec's claim that assert statements "are stripped
  entirely under `python -O`" — that is true for non-rewritten code (plain
  scripts, imported application modules) and false for assertions inside a
  collected test module, which is the more surprising and more relevant case.
  Per task 1.6, the delta is being amended to state this precisely rather than
  the broader claim.

**`pytest.raises` scoped narrowly.** Verified two ways: (1) it does not catch
the wrong exception type — a `NameError` inside a `pytest.raises(ValueError)`
block propagates and fails the test. (2) The real trap: a block scoped too
wide can catch an *unrelated* raise of the *same* exception type, so a test
"passes" even though the function actually under test was never called
(`int("also-bad")` inside the block satisfied `pytest.raises(ValueError)`
without `parse()` ever running).

**Fixture scope and shared mutable state.** Verified: a `scope="module"`
fixture returning a mutable `list` is the *same object* across every test in
the module — `test_a` appends `"a"`, and `test_b` (asserting an empty list)
sees `['a']` and fails, demonstrating the trap directly.

## LangGraph claims (task 1.4)

Verified against `langgraph==1.2.11`, `langgraph-checkpoint==4.2.0`,
`langgraph-prebuilt==1.1.0`, `langchain-core==1.5.5`, 2026-08-16
(`pip3 install --target <dir> langgraph langchain-core`).

**Stubbing a tool-calling model.** `langchain_core.language_models.fake_chat_models.FakeMessagesListChatModel`
returns pre-built `AIMessage` objects from a supplied list. `AIMessage`
accepts `tool_calls=[{"name": ..., "args": {...}, "id": ...}]` directly.
Confirmed end-to-end: `tools_condition({"messages": [tool_call_msg]})` returns
`"tools"` when the stubbed message carries `tool_calls`; the identical call
with a text-only `AIMessage` returns `"__end__"`. A text-only stub cannot
exercise the tool-calling branch — confirmed by direct routing-function
invocation, not by inspecting the graph's structure.

**In-process checkpointer.** `langgraph.checkpoint.memory.InMemorySaver`,
constructor `(self, *, serde=None, factory=<class 'collections.defaultdict'>)`
— no required arguments.

**Conditional-edge routing: three outcomes, not two.** This is the most
consequential finding of this verification pass, and it **corrects** the
qualified claim written into the delta before this task ran. Verified with
three constructions:

1. **No `path_map`, no `Literal` annotation** (a bare conditional edge):
   returning a value matching no node does **not raise**. LangGraph logs
   `WARNING:langgraph:Task a with path (...) wrote to unknown channel
   branch:to:<value>, ignoring it` via its own `logging` logger (confirmed:
   zero `warnings.warn` calls, one `logging` record captured directly) and
   `invoke()` returns normally — the graph simply does not proceed via that
   edge. Confirmed visible by default (Python's handler-of-last-resort prints
   `WARNING`+ to stderr with zero logging configuration), but **not an
   exception** — a test asserting only on the returned state sees a clean run.
2. **Valid `path_map` declared, function returns a key absent from it**:
   `compile()` succeeds; `invoke()` raises `KeyError: '<returned-key>'`. This
   is the construction the earlier qualified claim needed and did not
   distinguish from (1) — "fails at execution regardless of whether a
   `path_map` is supplied" is imprecise: *whether it fails at all* depends on
   whether one is supplied, only *when* is constant.
3. **`path_map` value (or `Literal` member) itself names a node that does not
   exist**: `compile()` raises `ValueError: ... branch found unknown target
   '<name>'`, confirming the declared-destination compile-time check.

Per task 1.6, the delta specs (`Conditional-Edge Routing and Recursion Limits
Are Covered`, and the parallel rung-3 wording in `Streaming-Mode and Testing
Distinctions Are Covered`) are amended in place to state three outcomes
rather than two, before the skill body is written from them.
