# Concurrency: GIL, asyncio

Depth on threading and `asyncio` traps. See `SKILL.md` for the always-resident floor; this file loads only when a question concerns threading, the GIL, or `asyncio`.

## The GIL gives a false sense of thread safety

CPython's Global Interpreter Lock means only one thread executes Python bytecode at a time, which leads to the intuition that a simple operation like `counter += 1` is safe to run from multiple threads without a lock. It isn't: `+=` on a shared variable is a read, an add, and a write — three separate bytecode operations — and the GIL can switch threads between any of them. Two threads can both read the same value before either writes it back, losing an increment. The GIL protects individual bytecode operations from interleaving with each other; it does not make a multi-step operation atomic. Use a `threading.Lock` (or an equivalent primitive) around any read-modify-write sequence shared across threads, exactly as if the GIL didn't exist.

The GIL also means threading in CPython does not speed up CPU-bound work — only one thread runs Python bytecode at a time regardless of core count. Threading here helps with I/O-bound work (a thread blocked on a network call releases the GIL while waiting); CPU-bound parallelism needs `multiprocessing` or a C-extension that releases the GIL internally (as NumPy's array operations do).

## A forgotten `await` doesn't run the code — it creates an object

Calling an `async def` function without `await` does not run its body at all. It returns a coroutine object, and the function's code doesn't execute until something awaits that object. Verified live (CPython 3.12.3): calling `f()` on an `async def f()` and never awaiting it produces no output from `f`'s body, no exception, and only a `RuntimeWarning: coroutine 'f' was never awaited` — raised not at the call site, but later, whenever the unreferenced coroutine object is garbage-collected. In a codebase with non-trivial logging noise, that warning is easy to miss, and the visible symptom is simply "the code inside `f` never seems to run."

## Blocking the event loop stalls every other coroutine

`asyncio` is cooperative: a coroutine only yields control at an `await` point. A synchronous, blocking call inside an `async def` function — a plain `requests.get()`, a CPU-heavy loop, `time.sleep()` instead of `asyncio.sleep()` — blocks the entire event loop for its duration, stalling every other coroutine scheduled on it, not just the one that made the call. This is easy to miss locally with one coroutine running, and shows up as a mysterious throughput cliff once several are running concurrently. Use the async-native equivalent (`httpx.AsyncClient`, `asyncio.sleep`) or run the blocking call in a thread/process pool via `loop.run_in_executor`/`asyncio.to_thread`.
