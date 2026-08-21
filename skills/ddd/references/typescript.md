# DDD in TypeScript

Ecosystem-specific traps and their concrete, current fix. This assumes the
decision points in `../SKILL.md`; it doesn't restate them.

## Structural typing defeats ID distinctness

TypeScript's structural typing means two differently-named types that
share a shape are freely interchangeable — including two ID types that
should never be confused:

```ts
type UserId = string;
type OrderId = string;

function cancelOrder(id: OrderId) { /* ... */ }

const userId: UserId = "u_123";
cancelOrder(userId); // compiles — nothing catches this
```

The fix is a **branded (opaque) type** — a nominal marker the structural
system can't see through:

```ts
type OrderId = string & { readonly __brand: "OrderId" };

function toOrderId(raw: string): OrderId {
  // validate here — this is also where always-valid construction lives
  return raw as OrderId;
}
```

Now `cancelOrder(userId)` fails to compile. This is the concrete mechanism
behind `../SKILL.md`'s "always-valid construction" decision for TypeScript:
pair a branded type with a smart constructor (a private constructor plus a
static factory returning the branded type or a `Result`/`Either`, rather
than throwing) so an invalid or wrongly-typed ID can't be constructed at
all, not just "shouldn't."

## A module boundary needs a lint rule, not just a barrel file

An `index.ts` barrel that re-exports only the intended public surface
*looks* like enforcement, but it isn't one: nothing stops another module
from importing the internal file directly —
`import { InternalRepo } from "../billing/internal/repo"` compiles exactly
as well as importing through the barrel. The barrel documents intent; it
doesn't enforce `../SKILL.md`'s public-API-per-module rule.

What actually enforces it is a lint rule that fails the build on a
cross-boundary import that bypasses the barrel — `eslint-plugin-boundaries`
configured with each module's allowed dependencies, or Nx's module
boundary rules (`@nx/enforce-module-boundaries`) in a monorepo already
using Nx. Either way, the check has to run in CI, not just exist in a
config file nobody's build fails on.

## ORM decorators pull persistence concerns onto the domain model

A common shape in NestJS-with-TypeORM (or Prisma-adjacent) codebases is
decorating the domain entity itself:

```ts
@Entity()
class Order {
  @PrimaryColumn() id: string;
  @Column() status: string;
  // domain methods mixed in here too
}
```

This is anemic-model pressure wearing a different disguise: the class now
has two reasons to change (a business rule changes, or the schema
changes), and the domain class depends outward on the ORM — the layered
half of `../SKILL.md`'s dependency-direction rule, violated by import
alone, before any logic is even wrong. The fix is a separate persistence
model (a TypeORM entity, a Prisma-generated type) plus a mapper that
translates it to and from the plain domain class. The domain class itself
imports nothing from the ORM.
