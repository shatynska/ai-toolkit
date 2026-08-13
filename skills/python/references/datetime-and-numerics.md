# Datetime and numeric pitfalls

Depth on naive-vs-aware datetimes and float-vs-Decimal numerics. See
`SKILL.md` for the always-resident floor; this file loads only when a
question concerns dates, times, or precise numeric values.

## Naive and aware datetimes don't mix, and the failure isn't always loud

A "naive" `datetime` (no `tzinfo`) and an "aware" `datetime` (`tzinfo` set,
e.g. via `datetime.now(timezone.utc)`) are not interchangeable. Verified live
(CPython 3.12.3): comparing one of each with `<` raises `TypeError: can't
compare offset-naive and offset-aware datetimes` immediately — that half of
the trap is loud, not silent.

The quieter failure is upstream of the comparison: constructing a naive
`datetime` where an aware one was intended. `datetime.now()` returns a naive
local-clock reading with no record of which timezone it's local *to* — code
that stores it, sends it to another service, or compares it against a value
computed in a different timezone is silently comparing wall-clock numbers
with no timezone context, which produces a wrong answer rather than an
error whenever the two sides don't happen to share an implicit timezone
assumption. Default to `datetime.now(timezone.utc)` (or an explicit
`zoneinfo` zone) for anything that crosses a process boundary, gets stored,
or gets compared against a value from elsewhere — naive datetimes are
reasonable only for a value that's used immediately, locally, and never
compared against another source's clock.

## Float accumulates rounding error; Decimal doesn't, at a cost

`0.1 + 0.2 == 0.3` is `False` — verified live, `0.1 + 0.2` evaluates to
`0.30000000000000004` under IEEE-754 double precision, because `0.1` and
`0.2` have no exact binary floating-point representation. This isn't a bug
in a specific operation; it's a property of binary floating-point
representing decimal fractions approximately, and it compounds across a
chain of arithmetic.

`decimal.Decimal` avoids this for values that matter exactly — `Decimal("0.1")
+ Decimal("0.2")` verified live to equal exactly `Decimal("0.3")` — **but
only when constructed from a string or an integer**. `Decimal(0.1)`
(constructing from the float literal) inherits the float's own imprecision:
verified live, it produces
`Decimal("0.1000000000000000055511151231257827021181583404541015625")`, the
exact binary value `0.1` already rounded to, not a clean `0.1`. Constructing
`Decimal` from a float doesn't fix the imprecision — it just makes the
already-rounded value visible at full precision. Use `Decimal` (constructed
from strings) for money or any value where exact decimal arithmetic matters;
use `math.isclose()` rather than `==` when comparing `float`s that have
passed through arithmetic and exactness was never the intent.
