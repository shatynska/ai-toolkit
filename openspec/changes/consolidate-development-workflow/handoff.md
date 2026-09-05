# Handoff: OpenSpec vocabulary alignment

Findings from a survey of the OpenSpec ecosystem, handed from an
exploration session to the session working this change, while its stage
vocabulary is still uncommitted.

Every item here is a decision for this change rather than work for later,
so none of it is an entry for `docs/change-queue.md` or
`docs/deferred-work.md`. Each is cheap now and expensive once the
vocabulary reaches an archived spec.

Fold what is accepted into the change, and record what is declined where
the change records its rejected alternatives. Whether this file then
archives with the change as the survey behind those decisions, or is
deleted once consumed, is this change's call.

## What the survey established

There is no community *stage* vocabulary to converge on. OpenSpec's
`docs/workflows.md` states the design principle as "actions, not phases" —
a change is revisited wherever implementation reveals a gap "rather than
moving rigidly through locked stages". A stage machine is what upstream
declines to ship.

Three vocabularies exist instead, and none of them are stages:

| Surface | Kind | Words |
|---|---|---|
| OpenSpec CLI | commands | `explore` `propose` `apply` `update` `sync` `archive` `new` `continue` `ff` `verify` `onboard` `bulk-archive` |
| schemas | artifacts | `proposal` `specs` `design` `review` `test-plan` `tasks` `verify` `retrospective` |
| reviewers | verdicts | `APPROVE` `APPROVE_WITH_CHANGES` `REVISE` · `PASS` `PASS_WITH_WARNINGS` `FAIL` · `CRITICAL` `WARNING` `SUGGESTION` |

So renaming a state to match a verb is a category error, and matching the
community for its own sake buys nothing. The criterion that does earn a
rename is narrower:

> Rename where the word already means something else in the tooling the
> same session is driving.

By that test most of the vocabulary should stay. Three stages should not.

## Rename: `build:doing` → `build:apply`

`apply` is the most load-bearing verb in the ecosystem, across six
surfaces: `/opsx:apply`, the `openspec-apply-change` skill, `openspec
instructions apply --json`, `applyRequires` in the `status --json` payload,
the top-level `apply:` block every schema carries, and the `apply` step in
the `anvil` schema's flow.

`doing` names no operation. A session that reads `build:doing` has to infer
that the next call is `openspec instructions apply`; `build:apply` says it.
Nothing else in the ecosystem uses `doing`, so the rename costs nothing.

## Rename: `ship:record` → `ship:archive`

`archive` is unambiguous and pervasive: `openspec archive`, `/opsx:archive`,
`openspec-archive-change`, `openspec-bulk-archive-change`, `instructions
archive --json`, the `openspec/changes/archive/` directory, and the
`archive_*` diagnostic code family in the agent contract.

`record` collides with nothing outside the repository and with a good deal
inside it. `rules/development-workflow.md` already uses "record" as a plain
verb — "Record in `gate-log.md`", "keeps both from proposal to record",
"its change records" — so `ship:record` reads as a generic act in the one
document where a stage name has to be unmistakable.

## Rename: `build:review` → `build:code-review`

This is the collision with consequences.

In OpenSpec's `docs/reviewing-changes.md`, in the `anvil` schema's `review`
artifact, in `openspec-reviewed-workflow`, and in this repository's own
`plan:review`, **`review` means review of the plan** — a read-only pass over
proposal, design and specs before any code exists. `build:review` is the
one place the word means a diff.

`agents/change-plan-reviewer.md` enforces the other meaning: "Asked to
review a diff or an implementation, say so and stop — you review the plan,
not the code written from it." A session reading `build:review` in a gate
log can dispatch the reviewer that refuses.

Qualify the code one rather than the plan one: plan review is the unmarked
case in every other vocabulary.

## Consider: `test-manifest.md` → `test-plan.md`

The `anvil` schema's `test-plan` artifact is the same object as this
repository's `test-manifest.md` — every `#### Scenario:` mapped to a named
test, doubling as a red/green ledger a later verification audits.

The argument is integration cost, not popularity: it is the only community
artifact of this shape found, so "common" would overstate it. But an
artifact declared `id: test-plan` generating `test-plan.md` drops into a
forked schema unchanged, where `test-manifest.md` forces a rename at the
moment it is least wanted. `rules/test-manifest.md` moves with it.

Against: *manifest* is arguably the better word. It is produced after the
specs and enumerates what must exist, where *plan* suggests intent. If that
distinction is load-bearing, keep it — this is the weakest item here.

## Consider: align the reviewer's verdicts

`agents/change-plan-reviewer.md` emits `PROCEED`, `PROCEED WITH
CHANGES`, `CHANGES REQUIRED` and `REJECT`. The `anvil` reviewer emits
`APPROVE`, `APPROVE_WITH_CHANGES` and `REVISE`.

| this repository | anvil |
|---|---|
| `PROCEED` | `APPROVE` |
| `PROCEED WITH CHANGES` | `APPROVE_WITH_CHANGES` |
| `CHANGES REQUIRED` | `REVISE` |
| `REJECT` | *(no counterpart — anvil escalates to a human after two consecutive `REVISE`)* |

Two things follow. The vocabulary here is the **richer** one: `REJECT` —
"the concept is unsound, never reached by accumulating lower-severity
issues" — has nothing to map to, and should not be dropped to match.

And there is an internal seam independent of the community: the stage is
`plan:approved`, but nothing emits "approved"; the verdict that produces it
is `PROCEED`. Renaming the three that map closes that seam as a side
effect.

Against: `CHANGES REQUIRED` is plainer than `REVISE`, and the rename reaches
the agent, its `.checks.yaml`, and every gate log entry already written.

## Keep unchanged

| Stage | Why |
|---|---|
| `plan:draft` `plan:review` `plan:revise` `plan:approved` | already the closest shape to the `anvil` review loop; `plan:review` is the *correct* use of the community's word |
| `blocked:<what>` | already aligned by accident — the artifact status enum in the agent contract is `done \| skipped \| ready \| blocked`, and `blocked` carries `missingDeps` |
| `build:verify` | the strongest existing alignment: `/opsx:verify`, `openspec-verify-change`, `anvil`'s `verify` artifact |
| `ship:pr` `ship:merged` `ship:deployed` `ship:confirmed` `ship:done` | OpenSpec stops at `archive`; nothing upstream models delivery, so there is nothing to converge on |
| `plan:committed` `plan:tests` `build:fix` `build:clear` `abandoned` | no counterpart. `build:clear` against `anvil`'s `DECISION: PASS` is the only near-miss and not worth the churn |

One caveat on `build:verify`, which now has a tool behind it:
`openspec-verify-change` is **broader** than the stage. The stage is tests
run against the implementation; the skill checks task completion, spec
coverage, requirement implementation and design coherence, reporting
`CRITICAL`/`WARNING`/`SUGGESTION` and deliberately not blocking the archive.
`build:verify` and `build:review` together are its scope. Wiring the skill
to the stage will surface findings the stage does not claim to cover.

## A gap that is not a rename

`PROCEED WITH CHANGES` has no stage. There are four verdicts and two
outcome stages, `plan:approved` and `plan:revise`, and a `[MINOR]`-only
verdict lands in neither unambiguously.

`anvil` resolves exactly this with a second machine-readable line,
`CHANGES_APPLIED: yes | no | n/a`, initialised to `no` when the verdict
issues and flipped only after the reviewer re-checks the listed items;
downstream artifacts may not proceed until it reads `yes`. Either a stage
between approval and revision, or a sentence naming which existing stage
absorbs the verdict, closes it.

Two further `anvil` provisions have no counterpart here and are worth
weighing on the same pass, though neither is a naming question:

- **Verdict staleness.** A verdict applies to the exact artifact contents
  reviewed. If the proposal, design or specs change afterwards for any
  reason other than applying listed changes, the verdict is void and a new
  round is required. `gate-log.md` records verdicts; nothing invalidates
  one.
- **`N/A — non-executable`.** A scenario in a change with no code test
  surface — docs, config, pure schema — maps to a real mechanical check
  (a linter, `openspec validate`, a CI job) rather than a fabricated test,
  with prose sign-off explicitly not qualifying. This repository is largely
  that kind of change.

## Why now

Every affected word is uncommitted on `consolidate-development-workflow`:
`rules/development-workflow.md`, the `session-workflow` delta spec,
`tasks.md`, `test-manifest.md`, `gate-log.md`, and the cases
`tests/cases/workflow-fragment-stage-vocabulary.sh` and
`tests/cases/workflow-fragment-gate-log.sh`.

Renaming now is a substitution and a re-read of two cases. Renaming after
the change archives costs a `MODIFIED Requirements` delta against a
published spec, plus archived history written in the superseded words.

## Sources

- [`docs/workflows.md`](https://github.com/Fission-AI/OpenSpec/blob/main/docs/workflows.md) — profiles, and "actions, not phases"
- [`docs/customization.md`](https://github.com/Fission-AI/OpenSpec/blob/main/docs/customization.md) — schemas, project config, the community schema table
- [`docs/reviewing-changes.md`](https://github.com/Fission-AI/OpenSpec/blob/main/docs/reviewing-changes.md) — the two review moments
- [`docs/agent-contract.md`](https://github.com/Fission-AI/OpenSpec/blob/main/docs/agent-contract.md) — JSON shapes, status enums, diagnostic codes
- [`anvil`](https://github.com/jikkujoyce/openspec-schemas/tree/main/schemas/anvil) — the schema this vocabulary most nearly duplicates
- [awesome-openspec](https://github.com/speclib/awesome-openspec) — the wider ecosystem
