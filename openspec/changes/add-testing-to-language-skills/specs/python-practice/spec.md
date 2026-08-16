## MODIFIED Requirements

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

## ADDED Requirements

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
