# ddd-practice Specification

## Purpose
Defines what the library's Domain-Driven Design guidance asserts and where it stops: tactical-first, decision-organized scope with strategic-leak awareness, the core tactical decision points it must cover, the TypeScript/Python reference split and what each must name, and the deferral to `testing` for general testing discipline.

## Requirements

### Requirement: Tactical Application Is Itself The First Decision

The skill SHALL lead its decision list with whether a subdomain warrants tactical DDD patterns at all, rather than assuming they apply once DDD is in scope. It SHALL state that tactical effort belongs in the core domain where the business actually differentiates, and that a simple, CRUD-shaped subdomain is a legitimate reason to skip entities, aggregates, and repositories entirely.

#### Scenario: A CRUD-shaped subdomain is told not to use tactical patterns

- **WHEN** the user is modeling a subdomain with no real invariants beyond field validation and no behavior beyond create/read/update/delete
- **THEN** the skill SHALL recommend against introducing tactical DDD patterns for it, rather than defaulting to entities and repositories because DDD is the topic

#### Scenario: Tactical effort is directed at the core domain

- **WHEN** the user is deciding where to invest modeling effort across several subdomains
- **THEN** the skill SHALL direct tactical effort toward the subdomain where the business differentiates, not apply it uniformly

### Requirement: Guidance Is Organized By Decision, Not By Trap List

The skill's body SHALL be organized around the decisions a developer writing domain code actually faces — entity vs. value object, always-valid object construction, aggregate sizing, domain service vs. application service vs. entity method, domain events, repository plus unit of work, dependency direction, and public-API-per-module — rather than around a standalone list of pitfalls to avoid.

A known pitfall SHALL be recorded inline against the decision it belongs to (for example, shallow immutability noted where always-valid objects are discussed) rather than collected into its own dedicated section.

#### Scenario: A pitfall is found next to its decision, not in a separate list

- **WHEN** the body is checked for where a known pitfall (for example, aggregate boundaries sized around object-graph convenience rather than true invariants) is recorded
- **THEN** it SHALL appear within the relevant decision's own section, and the skill SHALL NOT carry a separate, standalone traps section that collects pitfalls out of context

#### Scenario: The core decision points are all present

- **WHEN** the body's section list is checked
- **THEN** it SHALL include, at minimum, entity vs. value object, always-valid object construction, aggregate sizing, domain service vs. application service vs. entity method, domain events, repository paired with unit of work, dependency direction, and public-API-per-module

### Requirement: Strategic Leaks Are Recognized And Flagged, Not Silently Patched

The skill's primary focus SHALL be writing tactical code, and it SHALL NOT require or walk through strategic exercises such as context-mapping workshops or subdomain classification. Where a tactical symptom — a module reaching past another module's public surface, or a dependency pointing from a lower layer toward a higher one — indicates that a bounded-context boundary is actually wrong, the skill SHALL name that as a strategic issue and propose a boundary fix, rather than resolving it with a local, tactical workaround.

#### Scenario: A tactical symptom is traced to its strategic cause

- **WHEN** a module imports another module's internal (non-public-API) types to satisfy an immediate need
- **THEN** the skill SHALL flag this as a likely bounded-context leak and propose revisiting the boundary, rather than only suggesting a narrower import

#### Scenario: Strategic workshop exercises are out of scope

- **WHEN** the user asks the skill to run a full context-mapping or subdomain-classification exercise unprompted by a tactical symptom
- **THEN** the skill SHALL treat that as outside its scope rather than walking through it as core content

### Requirement: Dependency Direction Covers Both The Layered Rule And The Inter-Module Rule

The skill SHALL state dependency direction as two related but distinct rules: the layered rule (domain code depends on nothing outward; a repository's interface is owned by the domain/application layer while its implementation lives in infrastructure) and the inter-module rule (which bounded context or module is allowed to depend on which). Neither SHALL be presented as covering the other.

#### Scenario: A repository-ownership question is answered with the layered rule

- **WHEN** the user asks where a repository interface should live relative to its implementation
- **THEN** the skill SHALL state that the interface belongs to the domain/application layer and the implementation to infrastructure, as an instance of the layered dependency rule

#### Scenario: A cross-module import question is answered with the inter-module rule

- **WHEN** the user asks whether one module may import from another module's internals
- **THEN** the skill SHALL answer using the inter-module dependency rule and connect it to the public-API-per-module mechanism, rather than conflating it with the layered rule

### Requirement: Public-API-Per-Module Is Named As The Inter-Module Enforcement Mechanism

The skill SHALL state that each module or bounded context exposes an explicit public surface, and that other modules depend only on that surface — never on internals reached around it. It SHALL connect this mechanism explicitly to the inter-module half of dependency direction rather than presenting the two as unrelated topics.

#### Scenario: The mechanism is named when the inter-module rule is discussed

- **WHEN** the skill's inter-module dependency-direction content is checked
- **THEN** it SHALL name public-API-per-module as the concrete mechanism that makes the rule enforceable, not just an abstract principle

### Requirement: Language References Name Concrete, Current Enforcement Mechanisms

The skill SHALL ship `references/typescript.md` and `references/python.md` as on-demand material covering that ecosystem's implementation-specific traps and their concrete, current enforcement mechanism — not a restatement of the language-agnostic decision content.

`references/typescript.md` SHALL cover, at minimum: structural typing defeating identifier distinctness (and branded/opaque types as the fix), a lint-enforced module boundary (not just a barrel-file convention with no enforcement), and ORM-decorator leakage onto domain classes.

`references/python.md` SHALL cover, at minimum: runtime-only invariant enforcement (validators, since there is no compile-time check), import-linter-style enforcement of dependency direction (not just underscore-prefix convention), and the Active Record tension in Django/SQLAlchemy-style ORMs pulling domain classes toward anemic models.

#### Scenario: A TypeScript-specific question is answered from the TypeScript reference

- **WHEN** the user asks why two differently-named ID types in TypeScript are freely interchangeable
- **THEN** the skill SHALL answer from `references/typescript.md` with branded/opaque types as the fix, naming structural typing as the cause

#### Scenario: A Python-specific question is answered from the Python reference

- **WHEN** the user asks how to keep a Django or SQLAlchemy model from becoming the entire domain model
- **THEN** the skill SHALL answer from `references/python.md`, naming the Active Record tension and a concrete mitigation

#### Scenario: A convention-only mechanism is not presented as enforcement

- **WHEN** either reference discusses module-boundary or dependency direction enforcement for its language
- **THEN** it SHALL name a mechanism that is actually checked (a lint rule or an import-linter-style tool), not merely a naming or folder convention with nothing enforcing it

### Requirement: Testing Guidance Names The DDD-Specific Angle And Defers The Rest

The skill SHALL state DDD's specific testing angle — exercising an aggregate's or value object's invariants with no I/O, as distinct from testing through a repository port — and SHALL defer general, language-agnostic testing discipline (baseline-before-failure-claims, the states a failing test can be in, and similar) to this library's `testing` skill rather than restating it.

#### Scenario: The DDD-specific testing angle is answered directly

- **WHEN** the user asks how to test an aggregate's invariants
- **THEN** the skill SHALL explain testing it in isolation with no I/O, distinct from testing through a repository port

#### Scenario: General testing discipline is deferred rather than duplicated

- **WHEN** a testing question concerns baseline-before-failure-claims or the general states a failing test can be in
- **THEN** the skill SHALL defer to the `testing` skill rather than restating that discipline
