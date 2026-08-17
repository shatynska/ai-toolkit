---
name: python
description: >
  This skill should be used when the user is writing, reviewing, or debugging
  general-purpose Python code — "write this in Python", "review my Python
  script", "why does this function behave unexpectedly", "lint this with
  ruff/mypy" — or any task touching a .py file. It covers traps that read as
  correct but aren't: mutable default arguments and class attributes,
  aliasing vs copying, late-binding closures in loops, comprehension scoping,
  is vs ==, float/NaN equality, overly broad except clauses, return-in-finally
  masking exceptions, __exit__ swallowing exceptions, and generator
  single-use exhaustion — plus references on concurrency, imports/module
  state, ruff/mypy coverage, datetime/numeric pitfalls, and pytest practice.
  For LangGraph state/routing/checkpointer specifics, see langgraph instead;
  this skill's traps still apply to LangGraph code. Not about authoring
  library assets, OpenSpec work, Terraform, bash, or n8n workflows. A
  project's own conventions in AGENTS.md take precedence.
metadata:
  tags: [python]
---

# python

General-purpose practice for writing and reviewing Python code. Like `bash`
and `terraform`, this is a floor: what holds regardless of what the code is
for — a web backend, a data pipeline, a CLI, a long-running service — not a
tutorial on syntax or a style guide. Content verified live against CPython
3.12.3, `ruff` 0.16.3, and `mypy` 2.3.0 on 2026-08-13; treat version-specific
claims (the small-integer caching range, which traps default tooling catches)
as a dated snapshot rather than permanent fact.

Nothing here varies with what the code is for. The same trap holds identically
in a web backend, a data pipeline, a CLI, or a long-running service.

## Mutability and aliasing

A **mutable default argument** (`def f(x=[])`) is evaluated once, at
function-definition time, and shared across every call that doesn't supply
its own value. A mutation made through one call is visible on the next —
`f()` called three times with no argument returns a list that grew by one
each time, not three independent empty lists. Default to `None` and
initialize inside the function body.

A **mutable class attribute** (`class C: items = []`) is shared across every
instance until an instance assigns its own. Mutating it through one instance
— `self.items.append(x)` — mutates it for all instances that haven't set
their own, because there's only ever one list object until then.

**Assignment aliases; it doesn't copy.** `b = a` for a list, dict, or other
mutable object makes `b` a second name for the same object — a mutation
through either name is visible through the other. An explicit `list(a)` or
`a.copy()` (or `copy.deepcopy(a)` for nested structures) is required to get
an independent copy. This is the same root cause as the two traps above: a
default argument and a class attribute are both cases of two things sharing
one mutable object where independent copies were assumed.

## Scoping and closures

A **closure created inside a loop** — a `lambda` or nested function
referencing the loop variable — captures the variable itself, not its value
at the time of capture. Every closure created across the loop's iterations
reads whatever value the variable holds when the closure is finally called,
typically the loop's last value: `[lambda: i for i in range(3)]` produces
three functions that all return `2`. Bind the value explicitly instead —
a default argument (`lambda i=i: i`) or a factory function that takes `i`
as a parameter both work by giving the closure its own copy.

A **comprehension has its own scope in Python 3**, unlike a `for` loop — a
name assigned only inside a list/set/dict/generator comprehension is not
visible after it. `[y for y in range(3)]` followed by a bare reference to
`y` outside the comprehension is a `NameError`, even though the equivalent
`for y in range(3): pass` would leave `y` bound afterward.

## Identity and equality

**`is` compares identity, not equality**, and appears to work correctly on
small integers and short string literals only because CPython caches and
interns them — not because the language guarantees it. Verified live: on
CPython 3.12.3, `is` returns `True` for cached integers in the closed range
**-5 to 256** and for two identical string literals compiled in the same
module, and `False` the moment either falls outside that — a value of `257`
or a string built at runtime via concatenation is a fresh object, and the
same `is` comparison that "worked" on `256` silently breaks. This is
CPython-implementation-defined caching behavior, not a language guarantee —
don't rely on `is` for value comparison at all; use `==`.

**`float('nan') != float('nan')`, and no `NaN` value equals itself** —
equality alone cannot detect a `NaN`; use `math.isnan()`. More generally,
comparing floats for exact equality is unreliable once arithmetic has
introduced rounding error (`0.1 + 0.2 == 0.3` is `False`) — compare with an
explicit tolerance (`math.isclose`) instead of `==` wherever a value has
passed through arithmetic.

## Exceptions

A **broad `except Exception:` (or bare `except:`)** catches and can silently
discard a bug in the code it wraps along with the error it was written to
handle — a typo'd attribute access inside the `try` block disappears the
same way the anticipated error would. Catch the specific exception type the
code is actually prepared to handle.

**`return` (or `break`/`continue`) inside a `finally` block silently
discards any exception that was propagating** through the `try`, replacing
it with the `finally` block's own control flow — the original exception is
gone, not chained, not logged, just gone. Avoid control-flow statements in
`finally`; let it run cleanup only, and let the exception continue
propagating.

A **context manager's `__exit__` returning a truthy value suppresses the
exception** that triggered it — a `with`-block's exception can vanish with
no indication in the context-manager code that this is happening unless the
reader checks `__exit__`'s return value specifically. Return `None` (or
`False`) from `__exit__` unless suppression is the explicit, documented
intent.

## Iterators and generators

A **generator is exhausted after one full iteration.** A second `for` loop
or `list()` call over an already-exhausted generator silently produces
nothing — no error, just an empty result — rather than re-running the
generator function. If a value needs to be iterated more than once,
materialize it into a list, or call the generator function again for a
fresh generator.

**Mutating a list while iterating over it** — removing or inserting an
element mid-loop — skips or repeats elements, because the iteration index
and the list's contents fall out of sync. Iterate over a copy (`for x in
list(items):`) if the loop needs to mutate the original.

## LangGraph-specific work

Building or reviewing a LangGraph graph specifically — state schema and
reducers, conditional-edge routing, checkpointer choice, multi-agent
handoff? That's the `langgraph` skill's material, not restated here. This
skill's traps above still apply to LangGraph code exactly as they apply to
any other Python — a LangGraph node function with a mutable default argument
has the same bug any other function would.

## Read the project's conventions first

A consuming project's `AGENTS.md`, `CLAUDE.md`, and existing code override
everything above wherever they conflict with it. Read those before writing or
reviewing Python code in an unfamiliar repository.

When this skill's guidance conflicts with a project's recorded convention or
established code style, follow the project's convention — and say so; report
the conflict rather than resolving it silently.

Where a question is project-specific — style conventions beyond the traps
above, which dependency-management tool the project uses, its packaging
layout — and the project has recorded no convention at all, say that the
answer is project-specific and ask, rather than supplying one from
assumption. A repository with nothing recorded yet is the normal case here,
not an edge case.

## Completion check: ruff/mypy, necessary but not sufficient

See `references/typing-and-tooling.md` for the full discipline. In short: run
`ruff` (and `mypy` where the project uses type hints) before reporting Python
code finished, but a clean run is not sufficient on its own — several of the
traps above (aliasing vs. copying, mutating a list while iterating it,
generator exhaustion, `__exit__` swallowing an exception, general
float-equality comparison) have no lint rule and need an explicit read-through
instead.

## Where to go deeper

- `references/concurrency.md` — the GIL's false sense of thread safety,
  forgetting `await`, blocking an event loop with a synchronous call.
- `references/imports-and-state.md` — circular imports, module-level mutable
  state acting as a hidden global.
- `references/typing-and-tooling.md` — the full `ruff`/`mypy`
  necessary-but-not-sufficient completion discipline, with the verified
  caught-vs-missed split for every trap in this file.
- `references/datetime-and-numerics.md` — naive vs. aware `datetime`, float
  vs. `Decimal` for money.
- `references/testing.md` — `pytest` structure, fixture scope and the
  shared-mutable-state trap, `pytest.raises` scoped narrowly, and what
  makes an assertion meaningful.

For the language-agnostic discipline this skill's testing content assumes
rather than restates — what a baseline establishes, what each failure
state establishes, how an assertion's provenance is classified — load
`ai-toolkit:testing` alongside this skill.

## Trigger check fixtures

The prompts this skill's own authoring verified against, kept here so a
later edit to the description can be re-verified against the same pair
rather than inventing a new one from scratch. Only the prompts and expected
routing are recorded — never the outcome or the run date, since a
description edit invalidates whatever was last confirmed.

- **Positive** — "Can you review this Python function for correctness? I'm
  worried I might have a subtle bug in how I'm handling the default
  argument." → expected routing: `python`.
- **Negative** — "I need to build a LangGraph agent in Python that routes
  between two tools and hands off state between them — can you help me
  write the graph?" → expected routing: `langgraph`.
- **Positive, testing coverage** — "My pytest fixture is scoped to the
  module and returns a list — is it safe to mutate it in a test?" →
  expected routing: `python`. `testing` co-triggering as well is a pass,
  not a failure — see `testing`'s own fixtures for the amended standard
  this follows.
