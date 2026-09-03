---
kind: standing-constraint
---

# Working in an isolated worktree

These rules govern a worktree in which a session is doing a change's work:
how it is created, what it owes before anything it produces can be trusted,
and the condition under which it is removed. They apply wherever more than
one session may work on a repository at the same time.

A worktree whose lifetime is bounded by the single act of tooling that
created it, and which carries no branch destined for the trunk — a
throwaway checkout made for one automated check, say — is outside them. The
discriminator is the branch and the lifetime, not the contents. A worktree
created from a committed ref carries whatever that commit held, a change's
own artifacts included, so a scope drawn on contents would exclude nothing
and would leave such a checkout bound by rules it can satisfy no route of.
These rules do not govern it, and they make no claim about what does. Do
not read the exclusion as an assurance that its removal is owned elsewhere;
whether anything owns it is a separate question these rules leave open.

## Orientation on entering a worktree

Before taking any other action on the change, report where it stands: what
stage it has reached, whether its verification passes, and what has been
committed.

Derive that report from the repository — the change's own artifacts, the
commit log, and, except as the next paragraph provides, a real run of the
verification. Do not assemble it from recalled conversation. A session
entering a worktree is resuming work some other session left there, and the
worktree is the only party that knows how far it got; a conversation records
what was true when it was written, and the repository records what is true
now.

The stage and the committed state are readable at once. A verification
result is not. Report the verification half either from a run made after
provisioning is complete, or as **not run, and why** — never from a run made
against a worktree that has not been provisioned. Such a run does not fail;
it skips and reports success, so a report that took it at face value would
open this work by stating that verification passes on exactly the evidence
the provisioning rule below rejects. Nothing here licenses skipping the
report: orientation still precedes the work.

## One session, one branch, one worktree

Work in a worktree of your own, on a branch of your own, created from the
trunk — freshly fetched from the remote where the project has one. Two
sessions sharing a working tree contend over one index and one checked-out
branch, and the contention is silent until it is not.

Put it at `.claude/worktrees/<name>`, one directory per worktree. The path
is named here rather than left to the project because the two obligations
below are checks against a specific path, and a path left to choice makes
them uncheckable by anyone.

That location carries both of these:

- **Name the worktree root in the repository's ignore file.** Without it, a
  forced clean of the parent reaches into every session's worktree at once
  and destroys unmerged work in all of them.
- **Scope every recursive tool the project runs that does not read that
  ignore file** — test collection, linters, type checkers, container build
  context — so it cannot descend into the root. Without it, one session's
  run silently includes every other session's copy of the source tree.

## Provisioning before a verification result is relied on

A newly created worktree carries tracked files only: no ignored
configuration, no installed dependencies, no build artifacts, and no share
of any external state the verification touches. That is the premise the rest
of this rule rests on — without it, "provision before relying on a result"
never says what is missing.

**Provisioning is a precondition of relying on any verification result.**
The reason is the false pass, not convenience. Verification that cannot
reach what it needs does not fail loudly; it skips, the gate reports success,
and the result is indistinguishable from a run that passed.

Provisioning is complete when the end state of every step the project's own
conventions name holds — not when the first one does. A partially
provisioned environment fails in ways that read as defects in the change
under test.

Reach the provisioned state; do not ask whether someone already reached it.
Every clause above is a state to hold, the completeness clause included, and
each is safe to re-reach. A session entering a worktree it did not provision
therefore provisions it without first establishing what an earlier session
did — which it usually cannot. A session that instead had to judge whether
re-performing a step was destructive would fall back to reporting
verification as not run every time, in exactly the resumed-worktree case
orientation exists for.

Where the project's verification writes to a shared external service,
provisioning brings this session's namespace in that service to the
project's known initial state, whether or not a namespace already exists
under the name this session derives. A namespace outlives the worktree that
named it and these rules state no release, so a later worktree deriving the
same name would otherwise run against whatever the previous one left. This
is an end state, not a sequence of commands: what reaches it is the
project's own binding.

Before concluding that a required shared service is unavailable, check for
it. An assertion that a service is absent rests on having looked.

## A session's own namespace in a shared service

A worktree isolates the filesystem. It does not isolate a service the
verification writes to, and that is what breaks: two sessions writing to one
namespace produce failures that read as defects in the change under test and
are not.

Where the project's verification writes to a shared external service, take a
namespace of your own within it rather than sharing one. Derive its name
deterministically from the worktree, in whatever form the project's own
naming constraints impose — so that which session holds which namespace is
readable rather than guessed. No naming form is prescribed here, and no
service.

These rules allocate a namespace and do not release one. Reclaiming a
namespace once its worktree is gone is not directed here, so a project that
allocates needs a sweep of its own; said plainly, because an unstated gap in
a rule about isolation is indistinguishable from a rule that forgot.

## Removing the branch and the worktree

Remove a session's branch and worktree only against an observable condition,
never against a judgment that the work looks finished. Two routes satisfy
it, and each carries its own clauses in full — read the route you are on,
not a shared list.

**Route one — the branch is merged into the trunk.** Alongside it: nothing
uncommitted remains in the worktree, and, where the project has a remote,
nothing unpushed remains.

**Route two — the change's abandonment is recorded in its own artifacts,**
stating that the change is abandoned and that the work on its branch is not
wanted. Alongside it: nothing uncommitted remains. That is the whole of it —
the record stands in for the merge clause and, where the project has a
remote, for the unpushed clause too, because both concern commits on the
abandoned branch and those commits are exactly what the record covers. An
abandoned branch whose commits were never pushed is still removable.

The record does not stand in for the uncommitted clause. Uncommitted changes
are not what the decision mentioned — they may be unrelated or accidental —
so removal still halts and reports them, and the operator extends the
decision or does not.

A merge is not the only way a change legitimately ends. With a merge as the
only route, an abandoned change's branch and worktree can never be removed
and they accumulate, which is what this rule exists to prevent. The record is
written down rather than said, because the session that removes a worktree
may not be the session that abandoned the change and cannot see an exchange
it was not part of. Commit it on the abandoned branch before reading the
condition: left uncommitted, it trips the one clause it does not stand in
for, so the act that authorises removal blocks it.

Every clause above that presupposes a remote is conditioned on the project
having one. A project without a remote is one this rule is meant to serve,
and an unconditional remote clause is either unsatisfiable there — so
removal never happens and the accumulation occurs anyway — or dead text a
session must decide to ignore.

Removal covers the branch locally, the branch on the remote where one
exists, and the worktree. Perform the worktree's removal from the
repository's main working tree, not from inside the worktree being removed:
it is ordinarily the one the session is running in, and an act with no
stated execution context gets resolved by whoever arrives first.

Removal does not cover the namespace the session allocated in a shared
service. Reclaiming that is not directed here, and half a reclamation rule
would be one whose safety depends on clauses these rules do not carry.
