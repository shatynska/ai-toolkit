# Imports and module-level state

Depth on circular imports and module-level mutable state. See `SKILL.md` for the always-resident floor; this file loads only when a question concerns import order or module-level global state.

## Circular imports fail on partial initialization, not import order alone

When module `a` imports module `b`, and `b` imports `a` back, the failure depends on exactly what each module does at import time, not just on the cycle existing. Verified live (CPython 3.12.3): with `a.py` doing `import b` at the top and defining `f()` below it, and `b.py` doing `import a` at the top and then calling `a.f()` at module level (not inside a function), running `import a` raises:

```
AttributeError: partially initialized module 'a' has no attribute 'f'
(most likely due to a circular import)
```

The mechanism: Python starts executing `a`, hits `import b` before `a.f` is defined, starts executing `b`, `b` imports the already-in-progress (partially initialized) `a` module object, and then tries to use `a.f` — which doesn't exist yet because `a`'s execution never got past the `import b` line. The same cycle is often *not* an error if the cross-module reference is deferred into a function body (`a.f()` called only when `b`'s own function runs, rather than at `b`'s module level) rather than executed immediately at import time — by the time that function actually runs, both modules have finished loading. A circular import is therefore not a fixed yes/no property of two modules referencing each other; it depends on whether either side uses the other before both have finished initializing. Restructuring to break the cycle (moving the shared piece to a third module, or deferring the cross-import into a function) is more robust than depending on the order happening to work.

## Module-level mutable state is a hidden global

A module-level variable — `_cache = {}`, `_connection = None` reassigned by a `connect()` function — is process-wide shared mutable state, imported wherever the module is imported. It behaves exactly like a global variable, including every problem globals have: any code that imports the module can read or mutate it, tests that don't explicitly reset it leak state into each other, and if the process runs multiple threads or async tasks, mutation is subject to the same race conditions as any other shared mutable state (see `concurrency.md`). It reads as innocuous specifically because it doesn't look like a `global` statement — there's no keyword marking it as global state, just a name assigned outside any function, and a second module importing it gets a reference to the same object, not a copy. Where shared state across calls is actually wanted, this is often the right tool — but name it as global state when reviewing or writing it, rather than treating module scope as if it were somehow more local than it is.
