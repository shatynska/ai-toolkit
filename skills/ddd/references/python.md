# DDD in Python

Ecosystem-specific traps and their concrete, current fix. This assumes the
decision points in `../SKILL.md`; it doesn't restate them.

## Invariant enforcement is entirely runtime

There's no compiler to reject an invalid domain object before it exists —
every invariant that "always-valid construction" (`../SKILL.md`) requires
has to be enforced at runtime, at the moment of construction, not in a
separately-called `validate()` method a caller can forget to invoke.

A frozen `dataclass` with a `__post_init__` check gets close:

```python
@dataclass(frozen=True)
class EmailAddress:
    value: str

    def __post_init__(self):
        if "@" not in self.value:
            raise ValueError(f"invalid email: {self.value}")
```

`pydantic` (`BaseModel` with validators) or `attrs` (`@attrs.define` with
`validator=`) give the same guarantee with less boilerplate for anything
past a single field. Whichever library, the fix is always "the object
cannot exist without having passed the check" — a `create()`-then-`.validate()`
two-step is the failure this decision point exists to rule out.

**`frozen=True` is shallow immutability** — the trap `../SKILL.md` names
generically. A frozen dataclass holding a `list` or a `dict` still lets
that field be mutated in place; freezing only blocks *reassigning* the
attribute, not mutating what it points to. Use an immutable collection
(a `tuple`, `frozenset`, or a wrapped immutable mapping) for any field that
needs the guarantee to actually hold.

## Dependency direction needs a checked rule, not `_leading_underscore`

Python has no enforced visibility — `_leading_underscore` signals "don't
import this" but nothing stops the import. Both halves of `../SKILL.md`'s
dependency-direction rule (domain not importing infrastructure; one module
not reaching into another's internals) are conventions only, unless
something checks them.

**`import-linter`** is the concrete tool: a `.importlinter` config declares
layers (`domain` may not import `infrastructure`) or independent
contracts (module `billing` may not import from module `shipping`'s
internals), and `lint-imports` fails in CI on a violation — the same role
`eslint-plugin-boundaries` plays for TypeScript. Without a tool like this
enforcing it, "the domain layer doesn't depend on infrastructure" is an
aspiration that survives exactly until someone adds a quick import under
deadline pressure.

## Active Record ORMs fight the domain model by design

Django's ORM model *is* the Active Record pattern: the class that maps to
a database table also carries whatever domain behavior gets added to it,
because the framework's idioms all assume that. This is the anemic-model
pressure from `../SKILL.md` built into the framework's default posture,
not a mistake a particular codebase made — a `Model` subclass with
`.save()` invites putting everything on it.

SQLAlchemy can go either way: **declarative mapping** (the common
`class Order(Base): __tablename__ = ...` style) pulls the same direction
as Django, mapping metadata directly onto the class that also holds
behavior. **Classical mapping** (`mapper_registry.map_imperatively(...)`
against a plain class defined with no ORM base class or decorators at all)
keeps the domain class genuinely plain — the mapping lives in a separate
configuration step, not on the class itself — and is the more direct route
to the layered dependency rule holding for real. Where a project is
already committed to Django or declarative SQLAlchemy, the repository
pattern's translation step (mapping the ORM model to and from a plain
domain object at the repository boundary) is what recovers the separation
instead.
