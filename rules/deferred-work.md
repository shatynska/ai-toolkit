---
kind: standing-constraint
---

# Work that outlives the session

These rules govern what happens when a second change surfaces while a first
is in progress: how it is recorded, where, and what is not done about it
here.

## One change at a time

Work on one change per session.

Two changes in flight at once leaves it unclear which artifact and which
commit belong to which — a confusion that survives the session, in a
repository where the artifacts are how the next reader reconstructs what was
intended.

## Where the change in progress depends on the identified change

**Record the dependency and the wait in the current change's own artifacts
first**, before anything else is done about it. Recording is the obligation;
everything below is an option.

Having recorded it, you may open a proposal for the identified change on a
branch of its own and nothing further, and recommend that the work continue
in a separate session, returning here once it is merged.

The recording is what matters, because a dependency held only in
conversation is gone the moment the session ends, and the next session finds
a change that looks merely unfinished rather than blocked — indistinguishable
from one that stalled, and unactionable either way.

## Where it does not depend on the identified change

Record it as either:

- **a proposal on a branch of its own**, or
- **an entry in `docs/deferred-work.md`.**

Where the project has no such file, create it. An option that silently
reduces to no option in a project lacking a file these rules never told it
to create is not an option.

A project may also carry `rules/development-workflow.md` inlined, which
obliges out-of-scope work noticed during a change to become a separate
proposed change rather than being folded in. A deferred-work entry **is**
that separate proposed change, recorded rather than opened. The
reconciliation is with that obligation and not with any particular wording
of it: that fragment is versioned and expected to change, and a seam pinned
to its present sentence would be falsified by a reword that left the
obligation intact. Both obligations share the same substance —
that the work leaves the change in progress — and satisfying this one
satisfies that one. Stated here because, unreconciled, such a project would
hold two standing constraints on a single act, one permitting what the other
requires, and no session could satisfy both.

## A proposal-only branch is created and left

On either path, a branch opened for identified work is created and left. It
takes no working tree of its own, and it does not become the branch this
session works on.

A project may also keep one branch and one working tree per session. Without
this said, a session there reads a route these rules permit as one its other
rules forbid, and nothing reconciles the two.

## Why the file sits outside any change

A deferral recorded only inside a change stops being findable when that
change is archived. It is the change *succeeding*, not the session ending,
that loses it — which is why `docs/deferred-work.md` lives outside the
changes it came from, and why an entry there names the change that argued it
rather than repeating the argument.
