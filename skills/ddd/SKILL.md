---
name: ddd
description: >
  This skill should be used when the user is modeling a domain in
  application code, or reviewing code for how well it applies
  Domain-Driven Design — "help me design the aggregates for this
  feature", "should this be an entity or a value object", "is this
  aggregate too big", "review this domain model for DDD violations" —
  or any task touching tactical DDD (entities, value objects,
  aggregates, domain services, domain events, repositories). It covers
  decision points — whether a subdomain warrants tactical DDD at all,
  entity vs. value object, aggregate sizing, dependency direction,
  public-API-per-module — and flags a tactical symptom that's really a
  strategic leak, without teaching full strategic DDD. TypeScript/Python
  specifics live in bundled references. Not for language mechanics
  alone (python), a project's scope/tech-stack (project-foundation), or
  authoring this library's assets (create-skill, create-agent).
  Composes with testing for DDD-specific testing questions.
metadata:
  tags: [ddd, architecture, python, typescript]
---

# ddd

Like `python`, `terraform`, `bash`, and `ansible`, this is a floor: practice that holds regardless of which subdomain or language it's applied in — not a tutorial on what an aggregate is. It's organized around the decisions a developer writing or reviewing domain code actually faces, not around a list of pitfalls; a known pitfall is noted inline against the decision it belongs to rather than collected into its own section. TypeScript and Python specifics — where each language's type system or ORM culture works against these patterns, and the concrete mechanism that enforces the inter-module rule below — live in `references/typescript.md` and `references/python.md`, loaded on demand.

## Should this even be modeled tactically?

This is the first decision, not an afterthought: tactical DDD's value is concentrated in the core domain, where the business actually differentiates — not spread evenly across every subdomain a codebase happens to contain. Before reaching for an entity, an aggregate, or a repository, ask whether this subdomain has real invariants beyond field validation and real behavior beyond create/read/update/delete. If it doesn't, a plain data class and a thin CRUD service is the correct choice, not a shortcut — introducing tactical machinery around a subdomain with no invariants to protect is over-engineering, and it costs the same maintenance burden as doing it correctly with none of the benefit.

Where a subdomain does warrant it, the rest of this skill applies.

## Entity vs. Value Object

Distinguish by identity, not by shape. An **Entity** has a persistent identity that outlives any particular set of attribute values — a `Customer` whose name or email changes is still the same customer, tracked by its ID. A **Value Object** has no identity of its own; it's defined entirely by its current attributes, so two instances with equal attributes are interchangeable — two `Money(10, "USD")` values are simply equal, not "the same instance."

The decision test: does this concept need to be tracked and distinguished over time through mutation, or is it fully described by its current values? Default to Value Object whenever identity isn't actually needed — it's simpler to reason about and safer to share.

**Primitive obsession** — passing raw strings and numbers everywhere instead of wrapping a recurring concept (`Money`, `EmailAddress`, `DateRange`) as a Value Object — loses the one place those invariants could have been enforced once, and scatters ad hoc validation across every call site instead.

## Always-valid construction

An Entity or Value Object should be impossible to hold in an invalid state. Construction and validation happen together, never as two separate steps a caller can forget to connect. The standard shape is a guarded constructor plus a static factory (`create`, `of`) that validates and returns either a valid instance or a failure — not a public constructor that lets a caller build first and validate whenever they remember to.

**Shallow immutability** is the trap that survives this pattern anyway: marking the top-level object read-only doesn't protect a mutable field inside it (a list, a nested object) from being mutated through a reference someone still holds. The concrete construct that gets this right — and wrong — differs by language; see `references/typescript.md` and `references/python.md`.

## Sizing an aggregate

An aggregate is a cluster of entities and value objects treated as one unit for consistency, with a designated **aggregate root** as the only member anything outside the aggregate may hold a reference to. Draw the boundary around the smallest cluster of state that must be *transactionally* consistent with itself — an invariant that must hold right now, not one that can catch up eventually. Reference other aggregates by their identity (an ID) only, never by holding a direct object reference to them; that's what keeps the transactional boundary from silently growing to include whatever an object graph happens to reach.

**Sizing around a convenient object graph** instead of a genuine invariant — "an `Order`, and all its `OrderLines`, and the `Customer` who placed it" — is the trap that produces lock contention and giant transactions. The fix is almost always to shrink the aggregate and let true cross-aggregate consistency become eventual, coordinated by a domain event (below) instead of held inside one transaction.

## Domain Service vs. Application Service vs. Entity method

Put behavior as close to the data it operates on as the rule allows:

- A rule that genuinely belongs to one entity or value object and needs no other collaborator is a method on that object.
- An operation that naturally spans multiple aggregates and doesn't conceptually belong to any single one — "does this transfer violate a cross-account limit" — is a **Domain Service**: still pure domain logic, no I/O, no orchestration.
- Orchestrating a use case — opening a unit of work, calling a repository, calling a domain service, publishing an event, checking authorization — is an **Application Service**. It coordinates; it does not itself decide business rules.

The **anemic domain model** — entities reduced to getters and setters, with every actual rule pushed into application-layer services — is the most common tactical DDD failure, and it happens regardless of how many "aggregates" and "repositories" surround it. If every entity method is just a setter, the model is anemic.

## Domain Events

Use a Domain Event to decouple one aggregate's state change from another aggregate's reaction to it, when the two don't need to be consistent within the same transaction. Publish the event once the originating aggregate's own invariants are satisfied and its transaction has committed; a handler elsewhere reacts inside its own, separate transaction.

Don't reach for an event to avoid deciding an aggregate boundary correctly — an event is for two aggregates that are genuinely allowed to become consistent eventually, not an escape hatch for skipping the question of whether something needed to be one transaction in the first place. If enough related events start needing coordinated retries, ordering, or compensating actions, that's the signal to reach for a saga or process manager. Naming that escalation path is as far as this skill goes — it's a distinct architectural commitment with its own tradeoffs, not a tactical DDD building block.

## Repository, paired with Unit of Work

One repository per aggregate root, never per entity — it loads and saves the aggregate as a whole, so its invariants can never be persisted half-satisfied. Its *interface* belongs to the domain or application layer (see Dependency direction, next); only its *implementation* lives in infrastructure.

A repository alone isn't safe for any use case touching more than one aggregate: without a **Unit of Work** wrapping the calls in one atomic operation, a service that succeeds against one repository and fails against another leaves the system in a state no aggregate's own invariants ever permitted. Unit of Work is what makes "one repository per aggregate" compose safely across a real use case — treat the pairing as one decision, not two.

## Dependency direction

Two related but distinct rules travel under this name, and neither substitutes for the other:

**The layered rule.** Domain code depends on nothing outward. A repository's *interface* is declared in the domain or application layer; its *implementation* — the ORM, the SQL, the HTTP client — lives in infrastructure and depends inward on that interface, never the reverse. If a domain class imports an ORM decorator or a framework type directly, this rule is already broken, regardless of how many aggregates and repositories surround it.

**The inter-module rule.** Which bounded context or module may depend on which. Even with no layering violation, one module reaching directly into another module's internal classes couples them exactly as tightly as if no boundary existed, and makes the strategic decision behind that boundary meaningless. Public-API-per-module, next, is the mechanism that makes this rule enforceable rather than aspirational.

## Public-API-per-module

Each module or bounded context exposes an explicit public surface — what it's willing to be depended on for — and every other module depends only on that surface, never on internals reached around it. This is the concrete mechanism for the inter-module rule above, not a separate topic: a folder-structure convention alone ("the public stuff goes in this file") is not enforcement, because nothing stops a caller from importing the internal file directly unless something actually checks it. What "actually checks it" looks like concretely — a lint rule, an import-boundary tool — is in the language references.

## Recognizing a strategic leak

When one of the two dependency-direction rules is violated, the instinct is often to patch it locally: a narrower import, a small interface, a workaround. Before doing that, ask whether the violation is symptomatic — whether the bounded-context boundary itself is drawn in the wrong place. A module that keeps needing another module's internals is often evidence that the two "modules" are really one bounded context split in half, or that a concept belongs on the other side of the line. When that's the case, say so and propose moving the boundary rather than tactically working around the symptom; a local patch defers the same problem to the next place it's needed, while the fix that actually holds is strategic. This isn't an invitation to run a full context-mapping or subdomain-classification exercise on every import — it's specifically for the case where a tactical symptom keeps recurring and the pattern points at the boundary itself.

## Testing

An aggregate's or value object's invariants should be testable with zero I/O: construct it, or drive it through its own methods, and assert on the resulting state or the exception it raises — no database, no repository, no mock. If a domain-logic test needs a mock to pass, that's usually a sign the logic itself has an infrastructure dependency it shouldn't. Testing *through* a repository port — verifying an aggregate round-trips correctly through save and load — is a different, narrower kind of test, and shouldn't be conflated with invariant testing.

For everything else about writing and structuring tests — what a failing test's state actually establishes, recording a baseline before claiming a regression, and the rest of that discipline — see this library's `testing` skill; it isn't restated here.

## Trigger check fixtures

- **Positive, design-shaped** — "I'm building the Order subdomain for our e-commerce backend — help me figure out where the aggregate boundaries should be and what belongs on the entity vs. a service." → expected routing: `ddd`.
- **Positive, review-shaped** — "Can you review this domain model for DDD violations? I think our aggregates might be too big and I'm not sure the dependency direction is right." → expected routing: `ddd`. Recorded separately from the design-shaped fixture above because this skill's own design process flagged review-shaped phrasing as a real under-triggering risk distinct from design-shaped phrasing — both need to keep passing, not just one.
- **Negative** — "Can you review this Python class for bugs and style issues?" → expected routing: `python`. No domain-modeling vocabulary (entity, aggregate, value object) appears, so this stays with general Python review rather than `ddd`.
