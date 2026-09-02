# Deferred work

What this repository has deliberately not done, and why. Each entry names
the change that argued it rather than repeating the argument.

This file exists outside any change because a deferral recorded only inside
one stops being findable when that change is archived — it is the change
*succeeding*, not the session ending, that loses it.

## A session's shared-service namespace is allocated and never reclaimed

`rules/worktree-isolation.md` directs a session to take its own namespace in
any shared service its verification writes to, and directs nothing about
releasing it. A project that adopts the fragment therefore accumulates
namespaces and needs a sweep of its own.

`add-namespace-reclamation` owns the release. It is a separate change
because reclamation is an algorithm whose every predicate — eligible,
claims, enumeration succeeded, this checkout's identity — would be left to
an adopting project's binding, and six review rounds established that prose
can require those predicates to exist without making them agree with one
another. See `add-session-workflow-fragments`, Decision 5.

Until it ships, the sweep is manual.

## A tooling-created worktree is governed by no removal obligation

`rules/worktree-isolation.md` scopes its rules to a worktree in which a
session is doing a change's work, and excludes one whose lifetime is bounded
by the single act of tooling that created it. The exclusion is necessary —
such a worktree carries no branch destined for the trunk, so it can satisfy
neither route of the removal condition, and unscoped rules would make it
permanently unremovable.

But nothing in this repository obliges anyone to remove it either.
`agent-authoring` mandates a cold-run worktree and states no removal. So the
accumulation `worktree-isolation.md` exists to prevent is displaced onto a
class of worktree it now excludes, rather than solved for it.

Either `agent-authoring` gains a removal clause, or something else takes the
obligation. Recorded from `add-session-workflow-fragments`, whose sixth
review round found the collision.
