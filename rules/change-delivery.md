---
kind: standing-constraint
---

# Delivering a change

These rules govern how a finished change reaches the trunk: what must be
true before delivery begins, what order the steps take, and what counts as
delivered.

They presuppose two things about the adopting project, and a project without
either cannot follow them: **a remote**, since every step below moves work
through one, and **OpenSpec**, since the change's record is archived by name
below rather than through a role a project could fill some other way. Both
are stated here rather than recorded elsewhere, because a project meeting an
unstated precondition meets it at the step that fails.

## Delivery begins only against a passing verification

Begin only where the change's verification has run and passed against the
branch head.

These rules can be adopted on their own, so a sequence that opened with the
archive commit and stated no precondition would sanction delivering work
that nothing verified. The gate is what a project checks before the first
step, not something the steps happen to imply.

## The sequence

1. **Archive the change's record** — `openspec archive <change>` — as the
   last commit on the branch.
2. **Push the branch.**
3. **Open the pull request.**
4. **Let verification run** against it.

This sequence fixes the archive commit's *position* — last on the branch,
before the merge — and not permission to make it. Where the project's own
rules require a commit to be proposed and confirmed rather than made unasked,
that applies here as it does anywhere: propose this one, and make it once
confirmed. Read as permission, step 1 would have a session commit unasked in
every project holding such a rule, and a session that instead deferred to
that rule would never reach step 2.

The archive commit precedes the merge rather than following it so that the
change's record is reviewed by the same pull request that reviews the work.
Archived afterwards, the record reaches the trunk outside any review — the
one part of a change that describes what the change intended, arriving where
nothing looked at it.

## A merge is confirmed, never inferred

Wait for the operator's confirmation that the merge happened. Do not infer a
merge from a green pull request, from an approval, or from the absence of
comments, and do not treat the change as delivered — or act on anything
conditioned on its delivery — before that confirmation arrives.

A pull request that can still be closed, amended, or left open is not a
change that shipped, and a session that assumes otherwise reports work as
done that the trunk does not have.
