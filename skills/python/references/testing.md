# Testing with pytest

Depth on `pytest` structure, fixtures, and what makes an assertion
meaningful. See `SKILL.md` for the always-resident floor; this file loads
only when a question concerns writing or reviewing a test.

Verified live (`pytest` 9.1.1) on 2026-08-16. This file states `pytest`
specifics only — for what a baseline establishes, what each failure state
establishes, how an assertion's provenance is classified, and why weakening
an existing test destroys it, load `ai-toolkit:testing`. Load both together
before writing a test; this file does not restate what that skill owns.

**Runner scope is `pytest`.** A project on a different runner (`unittest`,
for instance) is not covered here — read that project's own conventions
first, per this skill's deference to a consuming project's own decisions.

**This skill's core traps apply to test files unchanged.** A mutable
default argument in a fixture, a late-binding closure in a
`pytest.mark.parametrize` loop, a broad `except` swallowing a test's own
assertion failure — none of that stops being a trap because the file is a
test rather than production code. A test file is Python.

## A bare `assert` is rewritten — but only inside a collected test module

`pytest` rewrites a bare `assert` statement at import time, replacing it with
code that captures and reports the operands on failure. `assert x == y` with
`x = 5, y = 6` fails with:

```
E       assert 5 == 6
```

That rewriting reaches **test modules and registered plugins/`conftest.py`
only** — not arbitrary application code a test happens to import. The same
`assert x == y` inside an imported library module produces a bare
`AssertionError` with no operand detail:

```
E       AssertionError
```

Don't rely on rewritten output from code outside the test suite; write an
explicit message in library-code assertions if the value matters on failure.

## `python -O` strips `assert` — except where `pytest` already rewrote it

`assert` statements compiled under `python -O` (or `PYTHONOPTIMIZE=1`) are
stripped from the bytecode entirely — the statement never runs, regardless
of what the condition would have evaluated to. This is standard CPython
behavior and applies to a plain script.

It behaves differently inside `pytest`. A bare `assert` in a **collected test
module** keeps firing under `PYTHONOPTIMIZE=1`, because `pytest`'s
import-time rewriting already replaced it with explicit code before the
interpreter's `-O` stripping would apply — the same failing test still
fails, with the same rewritten message. `pytest` even warns about the
asymmetry when it detects `-O`: *"assertions not in test modules or plugins
will be ignored because assert statements are not executed by the underlying
Python interpreter."*

That's the trap: an `assert` in an **imported, non-test module**, called from
a test, *is* stripped under `-O` — even while `pytest` is running and even
while the test module's own asserts keep working. A test that exercises a
helper function's internal `assert` can pass silently under `-O` where it
failed without it, because the assertion inside the helper simply never
executes. If a project's CI runs under `-O` (or any `PYTHONOPTIMIZE` value),
an assertion meant to guard application code, not test code, is not a
reliable check — verify behavior with an explicit `raise` or a test
assertion instead.

## `pytest.raises` scoped too wide passes without exercising anything

`pytest.raises(SomeError)` passes the moment *any* line inside its `with`
block raises `SomeError` — not specifically the line calling the function
under test. A block scoped around more than the one call under test can pass
while that call never ran at all: an unrelated line inside the block raising
the same exception type satisfies `pytest.raises` just as well, and the test
reports green having established nothing about the function it was written
to cover.

Scope the block to the single line under test:

```python
# Wrong: passes even if parse() is never called, because int("bad-2")
# also raises ValueError.
def test_parse_rejects_bad_input():
    with pytest.raises(ValueError):
        int("bad-2")

# Right: only the call under test is inside the block.
def test_parse_rejects_bad_input():
    with pytest.raises(ValueError):
        parse("bad-2")
```

`pytest.raises` does correctly reject the *wrong exception type* — a
`NameError` raised inside a block scoped to `ValueError` propagates and fails
the test as expected. The trap is specifically the same-type case, where
scope is the only thing standing between a real check and a coincidence.

## Fixture scope controls whether state is shared, not just how often setup runs

A fixture's `scope` (`function`, the default; `module`; `session`; others)
controls how many tests share the *same object* the fixture returns, not
merely how often the fixture function itself executes. A `module`-scoped
fixture returning a mutable object — a list, a dict, a class instance with
mutable attributes — hands every test in that module the same object.
Verified: a `module`-scoped fixture returning `[]`, appended to by one test,
is observed non-empty by the next test in the same module, because both
received the identical list rather than independent copies.

```python
@pytest.fixture(scope="module")
def shared_list():
    return []

def test_a(shared_list):
    shared_list.append("a")
    assert shared_list == ["a"]

def test_b(shared_list):
    assert shared_list == []   # fails: sees ["a"] left over from test_a
```

Default to `function` scope for anything mutable. Widen the scope only for
genuinely expensive, read-only setup, and construct a fresh mutable object
per test even from a broader-scoped fixture if sharing isn't intended.

## `conftest.py` shares fixtures without importing them

A fixture defined in a `conftest.py` is available to every test file in that
directory and below, with no import statement in the test file — `pytest`
discovers `conftest.py` files up the directory tree from each collected
test and makes their fixtures available by name. This is the mechanism for
sharing setup across test files without either duplicating it or importing
test-only helpers into test modules that don't need them.

## Comparing floats for exact equality in an assertion is unreliable

`assert result == 0.3` for a `result` computed as `0.1 + 0.2` fails —
floating-point arithmetic does not produce exact decimal results, and
accumulated rounding error makes exact equality assertion-flaky. Use
`pytest.approx` for a tolerance-based comparison instead of a bare `==`
wherever the value being asserted on came from arithmetic rather than being
a literal.

## Where a mocking boundary belongs

Mock at the boundary the code under test actually calls through — the
network client, the filesystem call, the external API wrapper — not the
function under test itself and not a boundary several layers removed from
where the real dependency is invoked. Mocking too close to the function
under test (mocking the function's own internal helper) tests that the
helper was called rather than that the function behaves correctly; mocking
too far away (patching a low-level library the code doesn't call directly)
is brittle to implementation changes unrelated to the behavior being tested.

## Where to go deeper

This file is depth for `skills/python`'s always-resident floor. See
`SKILL.md`'s own `Where to go deeper` section for the sibling references
(concurrency, imports and module-level state, typing and tooling,
datetime/numerics), and `ai-toolkit:testing` for the language-agnostic
discipline this file assumes rather than restates.
