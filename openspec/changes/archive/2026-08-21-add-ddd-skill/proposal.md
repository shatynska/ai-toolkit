## Why

Domain-Driven Design is widely cited but unevenly applied: tactical patterns
(entities, aggregates, repositories) get reached for reflexively, strategic
boundaries get ignored, and the two language ecosystems this library's user
actually writes in — TypeScript and Python — each undermine the patterns in
ways specific to their type system and ORM culture (structural typing
defeating ID distinctness in TypeScript, Active Record ORMs producing anemic
models in Python). No asset in this library currently covers domain modeling
at all; the library's current skills are either authoring machinery or
infrastructure/language floors that stop short of architectural judgment
inside application code.

## What Changes

- Add `skills/ddd/SKILL.md` — a design-oriented, language-agnostic skill
  covering tactical DDD, organized around decision points (should this even
  be modeled tactically, entity vs. value object, always-valid objects,
  aggregate sizing, domain service vs. application service vs. entity
  method, domain events, repository + unit of work, dependency direction,
  public-API-per-module) rather than around a trap list. Traps are recorded
  inline against the decision they belong to, not collected into their own
  section.
- Lead the decision list with the 2026 consensus that DDD's value is
  concentrated in the strategic layer (domain modeling and bounded-context
  boundaries) and that tactical patterns should be reserved for the core
  domain — so the skill's first move is judging whether a subdomain warrants
  tactical DDD at all, not assuming it does.
- Cover strategic DDD only as far as this skill's tactical, code-writing
  focus needs it: enough to recognize when a tactical decision (a module
  reaching past another's public surface, a dependency pointing the wrong
  way) is really a bounded-context leak, and to say so and propose a fix
  rather than silently patching around it. Full strategic-DDD material
  (context mapping workshops, subdomain classification exercises) stays out
  of scope.
- Add `skills/ddd/references/typescript.md` and
  `skills/ddd/references/python.md` — ecosystem-specific implementation
  material loaded on demand: branded/opaque types for ID distinctness,
  `index.ts` barrels plus a boundary-enforcing lint rule, and ORM-decorator
  leakage for TypeScript; runtime-only invariant enforcement (validators),
  `import-linter`-style direction enforcement, and Active Record vs. domain
  model tension (Django/SQLAlchemy) for Python. Each reference names a
  concrete, current enforcement mechanism rather than describing the problem
  abstractly.
- Name a testing pointer section that states DDD's specific testing angle —
  exercising an aggregate's invariants with no I/O, versus testing through a
  repository port — and defers general testing discipline to this library's
  `testing` skill rather than restating it.
- Update `skills/testing/SKILL.md`'s existing pointer list to name `ddd`,
  satisfying `testing-practice`'s standing requirement that the pointer
  section name every domain skill covering a testable artifact, "whether or
  not it presently carries testing material." That requirement already
  exists and already governs this addition — `ddd` introduces genuinely new
  testable-artifact vocabulary (an aggregate's or value object's invariants
  tested with no I/O) that belongs nowhere else in the library, so a request
  entering through `testing` needs a route onward to it.
- Re-run the recorded trigger-check fixtures of any existing asset the new
  skill competes with, per the invalidation requirement in `skill-authoring`
  — including `testing`'s own fixtures, since its pointer-list edit may also
  touch its description if `ddd` is added as an explicit co-trigger.

## Capabilities

### New Capabilities
- `ddd-practice`: What the library's DDD guidance asserts and where it
  stops — tactical-first scope with strategic-leak awareness, the
  decision-point organization (not a trap list), the TypeScript/Python
  reference split and what each must name, and the deferral to `testing` for
  general testing discipline.

### Modified Capabilities
(none — `skills/testing/SKILL.md` is edited to add `ddd` to its pointer
list, per Impact below, but `testing-practice`'s requirement text is not
changing: that requirement already mandates naming every domain skill
covering a testable artifact, and this change is bringing an existing
requirement into compliance as new domain skills are added, not altering
what it asserts.)

## Impact

- **Affected**: new directory `skills/ddd/` (`SKILL.md` plus
  `references/typescript.md` and `references/python.md`); and an edit to the
  existing `skills/testing/SKILL.md`'s pointer list to name `ddd`, per
  `testing-practice`'s standing pointer-completeness requirement (above).
  This is the only existing asset this change modifies.
- **Library positioning**: this is the first asset in the library that
  covers architectural judgment inside application code, rather than
  authoring machinery or an infrastructure/language floor. It composes with
  `python` and (once one exists) a TypeScript skill without duplicating
  either — those cover language mechanics, this covers domain-modeling
  judgment expressed in those languages.
- **Recorded checks elsewhere**: `skill-authoring` requires that adding an
  asset invalidates the recorded trigger checks of every asset it competes
  with for the same prompts. Fixtures of any existing skill or agent whose
  prompts could plausibly route to `ddd` instead must be re-run and updated.
- **Tag vocabulary**: existing tags (`python`, `authoring`, `hitl`, ...)
  don't cover domain modeling; new tags (candidates: `ddd`, `architecture`,
  `typescript`) are expected and will be settled during `create-skill`'s own
  tag-vocabulary check, not decided here.
- **No new dependencies**, no tooling, no build step.
