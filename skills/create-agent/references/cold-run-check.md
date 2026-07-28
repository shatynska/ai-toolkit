# Cold-run check

Verifies that the agent's body functions as a system prompt in a context
holding nothing from the authoring conversation — the failure mode a skill
does not have, because a skill's body is read by an agent that already
holds the conversation, while an agent's body *is* the system prompt of a
fresh subprocess.

Mandatory. Floor of one representative task, mirroring how the trigger
check fixes at two prompts and calls it a floor rather than a measurement.
Runs only after the trigger check passes — there is no value in cold-running
an agent whose description guarantees it is never dispatched.

## Structure

```
COLD-RUN CHECK
├── static : body's tool demands ⊆ tools field   (both forms, always)
└── live   : one cold run, contract-only payload
             ├─ real dispatch  : --plugin-dir, tools enforced   ← preferred
             └─ simulation     : body verbatim as prompt        ← fallback
             ├─ produced the declared output format?
             ├─ needed context the contract did not supply —
             │  asked for it, blocked on it, or assumed it?
             ├─ concluded on its own, or hit the harness budget?
             └─ stayed inside its declared lane?
```

## The live half

Run the drafted agent against **one payload** containing only what its
dispatch contract names, and nothing from the authoring conversation.

**Real dispatch — preferred.** Load the repository so the drafted agent is
registered, and dispatch it by name with the representative payload:

```
claude -p --plugin-dir <repo> "Dispatch the subagent named '<name>' via the Agent tool with payload <payload>. Relay its report back completely verbatim and unaltered."
```

Confirmed as the primary form (2026-07-28): an uncommitted `agents/<name>.md`
registers and is dispatchable, and a dispatch instructed to relay the report
verbatim reliably surfaces the subagent's own output rather than the
dispatcher's summary of it. Where that fails, try
`--output-format stream-json --verbose` and read the `task_notification`
event's `summary` field, which also carries the subagent's report
independently of the top-level assistant text. Only if *both* of those fail
to surface the report verbatim does the form count as unavailable and fall
back to simulation.

A real dispatch is preferred because it enforces the `tools` grant and
honours `model` and `effort`, which a simulation cannot.

**Simulation — fallback.** Spawn a subagent whose entire instruction set is
the drafted body verbatim, plus the same payload, and nothing from the
authoring conversation (the Agent tool, with the body pasted in as the
prompt). Two blind spots, both named so they are not mistaken for full
coverage:

- It grants all tools, so it cannot catch an agent reaching for a tool it
  was not granted — covered instead by the static half.
- It delivers the body as a *prompt*, not a system prompt — a weaker
  position in the instruction hierarchy. The untrusted-input criterion is
  the one likeliest to pass spuriously under simulation and fail once the
  agent actually ships.

## The static half — mandatory in both forms

Reconcile every tool the body instructs the agent to use against the
`tools` field. Mandatory when the live half is simulated, because it covers
the tool-enforcement gap simulation leaves. Mandatory beside a real
dispatch too, and not redundant there: enforcement only bites on the branch
the one representative task happens to exercise, so a body instructing the
agent to edit a file it was never granted still passes a read-only run. The
static half is a full pass over the body regardless of which branch the
live run took.

## Pass criteria

Bound to properties the body **declares** — never a judgment of output
quality. An agent that honours its declared format, contract, and lane but
produces a mediocre result still passes.

- **Output format** — did the report match what the body declared?
- **Contract completeness** — is there evidence in the returned report
  that the agent needed context the payload did not supply? Neither live
  form is interactive, so "asked for it" cannot be the only trigger — a
  dispatched subagent has no channel to ask anyone anything. Evidence takes
  any of three forms: the agent **asked** for the missing context, the
  agent **declared itself blocked** on it, or the agent **proceeded on an
  assumption not derivable from the payload** (an invented path, an assumed
  working directory, a reference to a discussion it never had). The third
  is the common case and the one a criterion written as "asked" alone would
  miss entirely.
- **Termination** — judged by *why* the run ended, not whether it ended. A
  run that concluded because the body told it to passes. A run cut off by
  the harness's turn or time budget returns a truncated report that reads
  like a short answer unless this is checked explicitly — that is a missing
  stopping condition, not a pass.
- **Lane** — did the agent stay inside the scope its body sets?

## Failure → revision

| Failure | Revision |
|---|---|
| Assumed conversation ("as discussed above"), or any input invented rather than supplied | dispatch contract is incomplete |
| Assumed cwd, relative paths | add absolute-path discipline |
| Output drifted from declaration | output format underspecified |
| Reached for an ungranted tool | widen `tools` **or** narrow the body |
| Stopped because the harness budget ran out, not because the body said to | add a stopping condition |
| Followed instructions found in a file | add the untrusted-input stance |

An agent is not reported complete until the check passes.

This mechanism assumes the drafted agent lives in a git-tracked
repository — true for every agent this standard governs, since it's always
authored into this repository's own `agents/`. It does not apply directly
to a third-party agent borrowed from an untracked directory (as in the
dry run this procedure was validated against, `design.md` D11) — there,
substitute a plain directory copy achieving the same protective intent.
That substitution is a fact about dry-running someone else's agent, not
a gap in the procedure as written for this repository's own.

## Isolation for write-capable agents

When the drafted agent's tool grant includes `Write`, `Edit`, or `Bash`,
the live half runs in an isolated git worktree, so the run's path-directed
writes land beside the repository the agent was authored in rather than in
it.

**The worktree must be populated before the run.** `git worktree add`
checks out a *committed* ref — the drafted agent is untracked, having just
been written. Confirmed empirically (2026-07-28): a worktree created from
`HEAD` with no further action does not contain the drafted `agents/<name>.md`,
and a real dispatch against it registers nothing — there is no agent to
dispatch. Copying the drafted definition (and anything its body references)
into the worktree before running fixes this; confirmed working on the same
throwaway agent. Steps, for a real dispatch:

```
git worktree add <wt> HEAD
cp agents/<name>.md <wt>/agents/
cd <wt> && claude -p --plugin-dir <wt> ...
```

The simulation fallback needs none of this — it carries the body verbatim
in the prompt, so the file's absence from the worktree is immaterial. This
gap is specific to the branch this check prefers.

**Payload paths are rewritten to the worktree root.** The system-prompt
standard requires absolute-path discipline, which pushes a payload toward
naming the repository the agent was authored in — and a payload carrying
that path defeats the isolation completely, since the agent then writes to
the original checkout from inside its own worktree. So every path the
payload carries that the agent may write to is rewritten to the worktree
root before the run. A payload naming a **writable** path outside the
worktree aborts the run rather than proceeding.

The abort binds writable paths only. A write-capable agent may legitimately
need to *read* something outside the worktree — a plugin cache, a
home-directory config, a sibling checkout — and aborting on that would make
the check unsatisfiable for the agent rather than protective of the
repository.

**The run's working directory is the other half of the isolation, and it
matters just as much as the payload.** A body that lacks absolute-path
discipline never touches the payload path at all — it resolves a relative
path against wherever the process was launched. Launch from the authoring
checkout and the write lands there, *before* the check can report the
missing discipline as the defect it is. So the run is launched with its
working directory set to the worktree root, and the authoring checkout is
not made available to it as a writable directory. Mechanism differs by
form: the Agent tool's `isolation: "worktree"` already sets the
simulation's cwd to the isolated root; a real dispatch is started from
inside the populated worktree explicitly, as in the steps above.

**What the worktree does and does not contain.** It redirects
path-addressed writes; it is not a sandbox. An agent granted `Bash` can
address any path the process can reach — and `Bash` is itself one of the
grants that triggers isolation, so the very grant that makes isolation
mandatory is the grant that can walk out of it. Containment for such an
agent rests on the permission mode the run is launched under, not on the
worktree alone. The same is true of network or external-service tools. For
both, review the payload and the permission mode before running rather than
treating the worktree as sufficient containment on its own.
