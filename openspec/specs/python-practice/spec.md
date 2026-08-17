# python-practice Specification

## Purpose
Defines the floor-level general-purpose Python authoring practice this library ships: the mutability, scoping, identity, exception-handling, and iterator behaviors that read as correct but aren't, the pre-split structure that keeps that floor resident while deeper material loads on demand, and the same verify-before-writing discipline this library's other domain skills carry.

## Requirements

### Requirement: Guidance Is General-Purpose, Not Shaped by Project Type

The skill SHALL state Python practice in terms that hold for any Python code, regardless of what the project is for. It SHALL NOT narrow its core mutability, scoping, identity, exception-handling, or iterator guidance to one project shape (a web backend, a data/ML pipeline, a CLI, a long-running service), even where a specific project is the motivating use case for the change that introduced or extended the skill.

#### Scenario: The same trap question gets the same answer regardless of project shape

- **WHEN** the same mutable-default-argument, late-binding-closure, or broad-`except` question arises in a web backend, a data pipeline, and a CLI tool
- **THEN** the skill SHALL give the same answer in all three, without a branch conditioned on what the code is for

### Requirement: Core Traps Are Recorded in Preference to Tutorial Content

The skill SHALL record at minimum these behaviors, each of which contradicts a reasonable reading of the code:

- A mutable default argument (`def f(x=[])`) is evaluated once at function-definition time and shared across every call that does not supply its own value, so mutations made through one call are visible in the next.
- A class attribute holding a mutable value is shared across every instance until an instance sets its own, so mutating it through one instance mutates it for all of them.
- Assigning a list, dict, or other mutable object does not copy it — both names reference the same object, and a mutation through either name is visible through the other; an explicit copy (or `copy.deepcopy` for nested structures) is required to avoid this.
- A closure created inside a loop (a `lambda` or nested function referencing the loop variable) captures the variable itself, not its value at the time of capture — every closure created in the loop reads whatever value the variable holds when the closure is finally called, typically the loop's last value.
- A comprehension has its own scope in Python 3, unlike a `for` loop — a name assigned only inside a comprehension is not visible after it, unlike the same assignment inside a `for` loop.
- `is` compares identity, not equality, and appears to work correctly on small integers and short strings only because CPython caches and interns them — the same comparison silently breaks the moment a value falls outside that cached range.
- `float('nan') != float('nan')` and no `NaN` value equals itself; equality comparison alone cannot detect a `NaN`, and comparing floats for exact equality generally is unreliable once arithmetic has introduced rounding error.
- A broad `except Exception:` (or bare `except:`) clause catches and can silently discard a bug in the code it wraps along with the error it was written to handle.
- `return` (or `break`/`continue`) inside a `finally` block silently discards any exception that was propagating through the `try`, replacing it with the `finally` block's own control flow.
- A context manager's `__exit__` returning a truthy value suppresses the exception that triggered it, so a `with`-block's exception can vanish without any indication in the context-manager code that this is happening.
- A generator is exhausted after one full iteration — a second `for` loop or `list()` call over an already-exhausted generator silently produces nothing, rather than re-running the generator function.

General Python syntax and idiom that a competent model already supplies unprompted SHALL NOT displace this content.

#### Scenario: A recorded trap is available before it is hit

- **WHEN** an agent is about to write a function with a mutable default argument, a closure inside a loop, or a broad `except` clause
- **THEN** the skill SHALL already carry the reason not to (or how to do so safely), without the user having to know to ask

#### Scenario: Base knowledge is deferred to rather than restated

- **WHEN** an agent meets a question the base model already answers reliably, such as basic syntax, list/dict literals, or how to define a function or class
- **THEN** the skill SHALL leave that to the model rather than carrying a restatement of it

### Requirement: Structure Separates the Always-Resident Floor from On-Demand Depth

The skill SHALL ship as a split structure from its initial version: a `SKILL.md` carrying the core-traps floor and the general-purpose scope statement as always-resident content, and `references/` files carrying deeper or narrower-audience material loaded on demand rather than resident on every trigger — at minimum covering concurrency (GIL false-safety, forgotten `await`, blocking an event loop), imports and module-level state (circular imports, module-level mutable state as a hidden global), typing and tooling (the `ruff`/`mypy` completion discipline), datetime/numeric pitfalls (naive vs. aware `datetime`, float vs. `Decimal` for money), and **testing** at `references/testing.md` (`pytest` structure, fixtures and their scope, parametrisation, and what makes a Python assertion meaningful).

`SKILL.md` SHALL close with a pointer naming each reference file and what it covers, so the on-demand material is reachable from the floor rather than left for the reader to discover unprompted.

#### Scenario: Deep concurrency material is not paid for on every trigger

- **WHEN** the skill is triggered by a question that does not concern threading, the GIL, or `asyncio`
- **THEN** the concurrency reference content SHALL NOT be part of what loads by default

#### Scenario: Deep testing material is not paid for on every trigger

- **WHEN** the skill is triggered by a question that does not concern writing or reviewing tests
- **THEN** the testing reference content SHALL NOT be part of what loads by default

#### Scenario: The floor points to where the depth lives

- **WHEN** `SKILL.md`'s content is checked
- **THEN** it SHALL end with a section pointing to each `references/` file, naming what it covers

### Requirement: Tooling Is a Necessary But Not Sufficient Completion Check

The skill SHALL require `ruff` and, where the project uses type hints, `mypy` (or an equivalent installed linter/type-checker) be run against Python code the agent has written or modified where the tool is available, and SHALL treat a clean run as necessary before the code is reported finished.

A clean run SHALL NOT be treated as sufficient. The skill SHALL state, for the core traps it records, which are typically caught by default linter configuration and which are not — for example, `ruff`'s default rule set catches a mutable default argument, a mutable class attribute default, an `is` comparison against a literal, a late-binding closure in a loop, a `return` inside `finally`, and a bare/broad `except`, while aliasing vs. copying, mutating a list while iterating it, generator single-use exhaustion, `__exit__` swallowing an exception on a truthy return, and a general (non-`NaN`-literal) float-equality comparison are not caught by a default run — and SHALL require that completion be reported only alongside an explicit statement that the unreported traps were checked by reading.

Where neither tool is available, the skill SHALL require this be stated rather than the code silently reported as checked, and SHALL name what carries the completion decision in its absence: an explicit read-through against the core traps.

#### Scenario: A clean lint alone does not finish the code

- **WHEN** code passes `ruff`/`mypy` but mutates a list while iterating over it, aliases a mutable object where a copy was intended, or lets a context manager's `__exit__` swallow an exception on a truthy return
- **THEN** the skill SHALL NOT permit it be reported finished on the strength of the clean run alone

#### Scenario: Completion names both halves of the check

- **WHEN** an agent working under this skill is about to report Python code complete
- **THEN** it SHALL report the linter/type-checker result, or the tools' unavailability, *and* state that the traps those tools do not reliably catch were checked by reading

### Requirement: LangGraph-Specific Material Is Cross-Referenced, Not Restated

Where a question concerns building a LangGraph graph specifically — state/reducer design, conditional-edge routing, checkpointer choice, or multi-agent handoff — the skill SHALL point to the `langgraph` skill rather than restating that material, the same way `bash-practice` names `terraform` as the place to go for provisioning semantics rather than drawing an exclusion boundary between the two.

The skill SHALL NOT exclude LangGraph code from its own core-traps floor: the mutability, scoping, identity, exception-handling, and iterator traps it records apply to LangGraph code exactly as they apply to any other Python code.

#### Scenario: A LangGraph-specific question is routed, not answered twice

- **WHEN** a question concerns LangGraph state schema, reducers, conditional-edge routing, checkpointers, or multi-agent handoff
- **THEN** the skill SHALL point to the `langgraph` skill for that material rather than restating it

#### Scenario: The core-traps floor still applies to LangGraph code

- **WHEN** Python code being reviewed or written happens to be a LangGraph graph
- **THEN** the skill's core traps (mutable defaults, late-binding closures, broad `except`, and the rest) SHALL still apply to it, the cross-reference to `langgraph` notwithstanding

### Requirement: Version-Dependent Claims Are Verified Against a Live Interpreter and Tooling

Claims this skill makes that depend on a specific CPython behavior or tool version — including the small-integer/string interning range and which traps a default `ruff`/`mypy` run does or does not catch — SHALL be verified against a live-installed interpreter and tool version during authoring rather than written from assumption.

Where a live check is unavailable during authoring, the skill's claims SHALL be sourced from the interpreter's or tool's own current published documentation, and the authoring record SHALL state that the claim rests on documentation rather than a live check, and SHALL record the version verified against.

#### Scenario: A version-dependent claim traces to a verified source

- **WHEN** the skill states a CPython-version-specific behavior or a specific linter/type-checker's default coverage
- **THEN** that claim SHALL have been checked against a live-installed interpreter or tool, or its current published documentation, during authoring, with the verified version recorded

### Requirement: Consuming Project Conventions Take Precedence

The skill SHALL declare itself a floor rather than an authority: a consuming project's `AGENTS.md`, `CLAUDE.md`, and existing code override it wherever they conflict, matching the deference convention `bash-practice`, `terraform-practice`, and `langgraph-practice` already state.

It SHALL instruct that those be read before Python work begins in an unfamiliar repository, and SHALL require that a conflict between its own guidance and a project convention be reported rather than silently resolved.

Where a question turns on a project decision — style conventions beyond the core traps, dependency/packaging tooling, or project layout — and the project records no convention at all, the skill SHALL state that the answer is project-specific and ask, rather than supplying one from assumption.

#### Scenario: Project convention wins a conflict

- **WHEN** a consuming project's recorded convention or established code contradicts a preference stated in the skill
- **THEN** the project's convention SHALL be followed and the conflict reported rather than silently resolved

#### Scenario: Absent conventions produce a question, not an invention

- **WHEN** a project-specific question arises — style conventions, packaging tooling, or project layout — in a repository that records no conventions
- **THEN** the skill SHALL state that the answer is project-specific and ask, rather than supplying one from assumption

### Requirement: Python Testing Practice Is Carried as On-Demand Depth

The skill SHALL carry Python-specific testing practice, covering at minimum: `pytest` test discovery and file/function naming; fixtures, their scope, and the shared-mutable-state trap a broader scope creates; parametrisation; what makes an assertion meaningful in Python, including that a bare `assert` is rewritten by `pytest` to produce a useful failure message, and the boundary of that rewriting — it covers test modules and `conftest.py`/registered plugins, not arbitrary imported application code, so an `assert` in a library module produces only the plain message. The reference SHALL separately state what `python -O` does to `assert` statements, with its scope stated to what verification establishes rather than assumed to carry over from bare CPython to a rewritten test module; `pytest.raises` scoped to the narrowest block that can raise, so it cannot pass on an exception from an unrelated line; the reason exact float equality fails in an assertion and what to use instead; `conftest.py` as the mechanism for sharing fixtures without importing across test files; and where a mocking boundary belongs.

This material SHALL be expressed as Python and `pytest` specifics, and its runner scope SHALL be stated in the reference itself: it covers `pytest`, and a project on a different runner is served by this capability's consuming-project deference rather than by content this skill does not carry. The general discipline that makes a test's evidence interpretable — what a baseline establishes, what each failure state establishes, how an assertion's provenance is classified — belongs to the library's testing skill and SHALL be cross-referenced rather than restated here, so the two do not drift.

Where a claim depends on a `pytest` version's behavior, it SHALL be verified against a live-installed `pytest` before it is written, and the verified version SHALL be recorded. Where a live check is not possible, this capability's existing verification requirement permits the claim to be sourced from current documentation instead, provided the reliance on documentation rather than a live check is recorded **both in the authoring record, as that existing requirement locates it, and at the point of the claim in the reference itself** — the second is an addition this requirement makes, not a relocation of the first, since a reader of the reference cannot see the authoring record.

#### Scenario: A Python-specific testing question is answered by this skill

- **WHEN** a question concerns how to express a test in Python **under `pytest`** — fixture scope, parametrisation, asserting an exception is raised, comparing floats in an assertion
- **THEN** the skill SHALL answer it, rather than deferring to the general testing skill, which carries no language specifics

#### Scenario: General testing discipline is cross-referenced, not restated

- **WHEN** the testing reference would state what a baseline establishes, what a failure state establishes, or how assertion provenance is classified
- **THEN** it SHALL point to the library's testing skill rather than restating that material

#### Scenario: The floor still applies to test code

- **WHEN** a mutable default argument, a late-binding closure, or a broad `except` appears in a test file rather than in production code
- **THEN** the skill's core traps SHALL apply unchanged, because a test file is Python
