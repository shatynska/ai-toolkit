## Why

`rules/development-workflow.md` reached `version: 2`, and no project already
carrying the `v1` block will ever receive it. `scripts/project-init` reports
version skew and stops — by an explicit requirement, not an oversight:

> Where a managed block for the same fragment is already present, the concern
> is satisfied and the block SHALL NOT be rewritten. […] reconciling a
> difference is out of scope for this tool.

Three projects on this machine carry the `v1` block today —
`commerce-ops`, `commerce-ops-product-dossier`, `infrastructure`. Each is
running a workflow the library no longer prescribes, including the
post-implementation review bound to an agent that declines the job. The
library now says one thing and its consumers do another, and the only signal
is a skew line in a report nobody runs on a schedule.

`add-project-workflow` anticipated this and left the door open deliberately:
the block's delimiters were shaped so "a later update can locate and replace
the block without parsing hand-written text". That later update is this
change. Nothing about the mechanism is new; what is missing is the decision
about what to do when the block a project holds is not the block the tool
would write.

## What Changes

- **A project's managed block can be brought to the fragment's current
  version.** The delimiters already carry everything needed to locate the
  block and read the version it holds; what this adds is the operation that
  replaces its contents and leaves everything outside the delimiters alone.
- **The block's generated contents become genuinely replaceable, and the
  claim that they already were becomes true.** `project-bootstrap` defines
  content between the delimiters as "generated and replaceable" while
  shipping no tool that replaces it. This change makes the definition
  operative rather than aspirational.
- **A block a project has edited by hand is the central case, not an edge
  one.** The block says "Do not edit inside this block"; some project will
  have done so anyway. Overwriting silently destroys work the project
  believed it owned; refusing outright strands the project on an old version
  forever. This change must decide, state the decision, and make the
  situation detectable rather than assumed — see Open questions.
- **Skew stops being reported without a remedy.** Today the report names a
  problem and says resolving it is out of scope. After this change it names
  the problem and the operation that resolves it.
- **The updating capability is deliberately not folded into initialization.**
  Whether it is a flag on `scripts/project-init` or a second executable is a
  design decision, but it is not one initialization should make implicitly:
  a tool whose contract is "never overwrites a file it did not create" should
  not acquire an overwrite path as a side effect of being re-run.

## Capabilities

### New Capabilities

None yet — this may resolve into a new capability rather than an extension of
`project-bootstrap`, but the proposal is not the place to decide it. See Open
questions.

### Modified Capabilities

- `project-bootstrap`: its "Workflow rules reach a project as a versioned
  managed block" requirement currently states that an existing block SHALL
  NOT be rewritten and that reconciling a difference is out of scope for the
  tool. Both clauses were correct while no updater existed. They need to be
  scoped to initialization rather than stated absolutely, without weakening
  the never-overwrite guarantee that initialization itself still owes.

## Impact

- `scripts/` — the updating operation, as a flag or a second executable.
- `openspec/specs/project-bootstrap/spec.md` — the scoping described above.
- `tests/` — the harness already covers skew reporting
  (`managed-block-older-version.sh`) and body fidelity
  (`inlined-body-matches-fragment.sh`); both become the baseline this change
  is measured against, and neither should have to change.
- `rules/development-workflow.md` — unchanged. This change moves an existing
  fragment to consumers; it does not edit what the fragment says.
- The three `v1` projects — the intended beneficiaries, and the material for
  confirming the operation works against real blocks rather than fixtures.

## Open questions

These are named here rather than answered, because each would change the
design and the task breakdown, and answering them by inference is what this
proposal exists to prevent.

1. **A hand-edited block.** Refuse, overwrite, or report and let the operator
   choose? Detection is the harder half: telling an edited block from an
   intact one means comparing it against the fragment text of the version it
   claims, which the toolkit may no longer carry.
2. **Flag or separate executable.** `--update` on `scripts/project-init`, or
   a sibling tool. The existing script's never-overwrite contract argues for
   a sibling; a single entry point argues for a flag.
3. **Scope of one invocation.** One project per run, or a set of paths. The
   three-project reality suggests the latter; the deterministic-tool
   discipline in `AGENTS.md` suggests the former.

## Status

Proposal only. `design.md`, the delta specs and `tasks.md` are deliberately
absent — under the workflow this repository now runs, a reviewer is dispatched
against a complete package, and the open questions above must be answered
before that package can be written.
