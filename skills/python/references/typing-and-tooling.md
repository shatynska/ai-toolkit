# ruff and mypy: necessary but not sufficient

The full completion discipline for Python code written or modified under this skill. See `SKILL.md` for the always-resident floor; this file loads on demand for the completion check itself.

## Run ruff (and mypy, where the project types) before reporting code finished

Run `ruff check` against any Python file written or modified, and `mypy` where the project uses type hints, wherever the tools are available. A clean run from both is **necessary** before reporting the code finished.

It is not **sufficient**. Report a clean run (or the tools' unavailability) *and* state explicitly that the traps a default run doesn't catch were checked by reading — completion is both halves together, not the lint result alone.

## What ruff's default rule set actually catches

Verified live against `ruff` **0.16.3** on 2026-08-13, run with zero project configuration (`ruff check --isolated` from a directory with no `pyproject.toml`/`ruff.toml` anywhere on the path — confirmed identical to a plain `ruff check` with no config file present). This is worth stating plainly because it corrects a common assumption: `ruff`'s no-config default is **not** the older, narrower "pycodestyle errors and pyflakes only" (`E4`/`E7`/`E9`/`F`) reputation it's sometimes described with. As installed and verified here, the default already includes flake8-bugbear (`B`), flake8-bandit (`S`), flake8-blind-except (`BLE`), and a slice of Pylint (`PL`) — a materially broader net than that older description suggests. Re-verify against whatever version is actually installed rather than trusting this list to hold indefinitely; rule defaults are exactly the kind of thing a tool changes across releases.

**Caught by `ruff`'s default rule set**, one minimal reproduction per trap, confirmed by an actual run — not by reading rule descriptions:

| Trap (from `SKILL.md`) | Rule | 
|---|---|
| Mutable default argument | `B006` |
| Mutable class attribute default | `RUF012` |
| `is` used to compare against a literal | `F632` |
| Late-binding closure in a loop | `B023` ("function definition does not bind loop variable") |
| `return` inside `finally` | `B012` |
| Bare/broad `except Exception: pass` | `BLE001` + `S110` (two rules on the same code) |
| Comparison against a literal `float("nan")` | `PLW0177` |

**Not caught by any default rule**, confirmed by an actual clean run on a minimal reproduction of each:

- Aliasing vs. copying — `b = a` followed by mutating `b` and reading `a`. Ordinary, syntactically unremarkable code; no AST pattern distinguishes an intentional shared reference from an accidental one.
- Mutating a list while iterating over it (`for x in items: items.remove(x)`).
- Generator single-use exhaustion — consuming the same generator object twice, expecting the second pass to reproduce the first.
- `__exit__` returning a truthy value and swallowing the triggering exception.
- General float-equality comparison (`a + 0.1 == b`) — `PLW0177` matches only the specific syntactic pattern of comparing against a `float("nan")` literal, not float equality generally; ordinary rounding-error cases like `0.1 + 0.2 == 0.3` pass a clean `ruff` run.

For every trap in the "not caught" list, the read-through is what carries completion — there is no tool result to lean on.

## Where mypy fits

Verified live against `mypy` **2.3.0**: across minimal reproductions of all ten core traps, `mypy` flagged exactly one thing — a `var-annotated` hint on the class-with-mutable-default-attribute reproduction (asking for an explicit type annotation on the empty-list attribute), which is a type- inference nudge, not a report of the mutability trap itself. `mypy` is a type checker; none of this skill's core traps are type errors, so `mypy`'s contribution to this specific completion discipline is minor. Still worth running where the project types its code, for the type-correctness guarantees it does provide — just don't expect it to catch anything on the trap list above.

## When neither tool is available

State that plainly rather than silently reporting the code as checked, and fall back to an explicit read-through against every trap in `SKILL.md` — naming what was checked, the same way the ruff-caught traps still need a named read-through for the tool-missed half even when `ruff` did run.
