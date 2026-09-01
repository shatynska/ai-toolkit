## Context

See `proposal.md` - Why. This design was shaped by an `/opsx:explore`
session rather than derived from the codebase (there is no prior DDD asset
to build on): the shape below is the outcome of that conversation, not a
reconstruction from existing code.

`terraform`, `ansible`, `python`, and `bash` are this library's only
existing domain-practice skills, and they share a shape worth reusing
deliberately: a floor-level, provider/language-neutral body that states
practice rather than tutorial, defers to a consuming project's own
conventions, and (for `terraform`) records specific traps rather than
restating base knowledge. `ddd` follows the same posture but departs from
`terraform`'s trap-list organization on purpose — see Decisions below.

## Goals / Non-Goals

**Goals:**
- A single language-agnostic decision framework in `SKILL.md`, with
  TypeScript and Python specifics pushed to on-demand references.
- Content that reflects validated, current practice (2026 sources), not
  personal preference — sourced during exploration and named here rather
  than in `proposal.md` (Vaughn Vernon's aggregate rules,
  `cosmicpython`/*Architecture Patterns with Python*, Khalil Stemmler's
  TypeScript value-object material).
- A concrete link between the tactical patterns covered and the strategic
  boundaries they exist to enforce (dependency direction,
  public-API-per-module), so the skill can recognize a strategic leak
  without needing to teach strategic DDD as a subject.

**Non-Goals:**
- Full strategic DDD (context mapping, subdomain classification, core
  domain charting) as first-class content. It's referenced only far enough
  to support the leak-recognition requirement.
- CQRS, event sourcing, or sagas/process managers as covered patterns.
  They're adjacent to domain events but are a separate architectural
  commitment with their own tradeoffs; naming them as an escalation path
  from domain events (see Decisions) is in scope, teaching them is not.
- A third language reference beyond TypeScript and Python. Adding one
  later is a natural follow-on but isn't scoped here.
- Deciding the skill's final tags. `proposal.md` names candidates
  (`ddd`, `architecture`, `typescript`); `create-skill`'s own Checkpoint 1
  tag-vocabulary check settles this at authoring time.

## Decisions

**Decision-point organization instead of `terraform`'s trap-list
organization.** `terraform`'s body is built around "Traps that cost a
rewrite" because Terraform mistakes are often silent and destructive
(`prevent_destroy` accepting only a literal, `count` reshuffling
resources) — the value is in naming the trap before it's hit. DDD's
failure mode is different: the dominant real-world failure is applying the
wrong pattern *by choice*, not falling into a silent gotcha. Organizing by
decision ("entity or value object, and how to tell") puts the judgment
call front and center; a known pitfall is recorded inline against the
decision it belongs to, not collected separately. This was an explicit,
repeated instruction during exploration, not an inference — the user
confirmed it directly after `terraform`'s trap-list shape was presented as
a candidate model.

**Alternative considered:** organize by building block (Entity, Value
Object, Aggregate, ... — the classic Evans/Vernon catalogue order).
Rejected because it reads as a tutorial/reference catalogue rather than
guidance for someone about to make a specific choice, and doesn't naturally
accommodate "should this be modeled tactically at all" as an entry point.

**Lead with "should this even be modeled tactically."** Confirmed by 2026
sources as the dominant current framing (DDD's value is concentrated in
the strategic layer; tactical effort belongs in the core domain) rather
than an assumption carried in from the classic literature alone. Placing
it first also gives the skill a natural way to talk someone *out* of
over-applying entities/aggregates/repositories to a CRUD-shaped subdomain,
which was named during exploration as a real, observed failure mode.

**Repository is paired with Unit of Work, not covered alone.** Surfaced
during the research pass rather than the initial exploration — `terraform`
and the original decision list didn't include it. Repository without an
atomic-update mechanism across multiple repositories is unsafe by
omission: a service touching two aggregates has no transactional boundary
without it. Named explicitly so the pairing isn't lost during drafting.

**Dependency direction is stated as two rules, not one.** Exploration
surfaced that "dependency direction" was being used to mean both the
layered rule (domain → application → infrastructure, repository interface
owned by domain) and the inter-module rule (which bounded context may
depend on which) — confirmed as "both" when asked directly. Treating them
as one rule risks a reader fixing the layered violation and believing the
inter-module one is also handled, or vice versa.

**Public-API-per-module is presented as the inter-module rule's
enforcement mechanism, not a separate topic.** This is the connective
tissue identified during exploration between "tactical, code-writing
focus" and "strategic awareness": a module's public surface *is* the
concrete, checkable thing that either respects or violates a
bounded-context boundary. Presenting them together is what lets the skill
satisfy the strategic-leak-recognition requirement without teaching
strategic DDD as a separate subject.

**"Always-valid" objects gets a named decision point instead of being
folded into Entity/Value Object.** Confirmed as broadly endorsed, current
practice (Stemmler's private-constructor-plus-factory-plus-`Result`
pattern for TypeScript; pydantic/attrs validators for Python) rather than
a stylistic preference — and it's the one pattern that shows up by name in
both languages' current literature, which argues for treating it as its
own decision rather than a detail mentioned in passing under Entity vs.
Value Object.

**Language references stay to two files, `typescript.md` and
`python.md`, following `create-skill`'s reference-splitting convention.**
Each must name a mechanism that's actually enforced (a lint rule,
`import-linter`) rather than a convention nobody checks — this was raised
directly as a concern during exploration (folder-structure-by-context
"working" only as long as nothing enforces it) and is written into the
spec as its own requirement so a draft that only describes the problem
without naming the checked mechanism fails review.

**Testing gets a short pointer section, not its own deep-dive — and the
pointer runs both directions.** Matches how `terraform` and `python`
handle the same seam: `ddd` names the domain-specific angle (aggregate
invariants tested with no I/O) and defers general discipline to the
`testing` skill rather than duplicating it. The reverse direction is not
optional: `testing-practice` already requires its pointer section to name
every domain skill covering a testable artifact, "whether or not it
presently carries testing material" — that requirement predates this
change and already governs it. `ddd`'s invariant-testing angle is genuinely
new vocabulary no other skill in the library carries, so `testing`'s
pointer list is edited to add it, and `testing`'s own recorded trigger
fixtures are re-verified under the same invalidation discipline this
change already applies to `python`, `create-skill`, and `create-agent`
(tasks.md section 7). Whether `ddd` also becomes an explicit co-trigger in
`testing`'s description (as `terraform` and `python` are) or stays
list-only (as `ansible` is) is a drafting-time judgment call, resolved by
running the actual fixtures rather than decided here.

**Content-locking is asymmetric, on purpose.** `ddd-practice`'s "Guidance
Is Organized By Decision" requirement enumerates eight decision points and
locks their *presence* only (entity vs. value object, always-valid
objects, aggregate sizing, domain service vs. application service vs.
entity method, domain events, repository+UoW, dependency direction,
public-API-per-module) — of those eight, two (dependency direction,
public-API-per-module) additionally get their own dedicated requirements
that lock specific *content*, because exploration surfaced those two as
genuinely ambiguous ("dependency direction" was being used to mean two
different things at once) rather than merely under-specified. The other
six are well-established enough in the current literature that the risk is
omission, not drift in what gets asserted, so the spec locks that they're
covered and leaves *how* to the draft. Three further, separately-listed
spec requirements — tactical-first ordering, each language reference's
minimum content, and the testing deferral — are also content-locked, but
they aren't members of the eight-item decision list at all; conflating
them with it is a miscount to avoid repeating. This overall posture departs
from `terraform-practice`'s and `python-practice`'s pattern of locking
their enumerated content verbatim; that pattern fits a floor of "facts
that read as correct but aren't," which most of `ddd`'s decision points
aren't.

## Risks / Trade-offs

- **[Risk]** A design-oriented skill whose review-and-flag behavior
  (strategic-leak recognition) is a secondary mode rather than the primary
  trigger could under-fire on pure code-review prompts ("review this
  domain model for DDD violations") that don't mention writing new code.
  → **Mitigation**: deferred to `create-skill`'s trigger-check step, which
  exists specifically to catch under-triggering before the skill is
  reported complete; the description should name review-shaped phrasings
  explicitly, not just design-shaped ones.
- **[Risk]** "Reflects validated, current practice" is a high bar that a
  single exploration-time web search pass can't fully discharge — sources
  found were a sample, not exhaustive.
  → **Mitigation**: named sources are cited in `proposal.md` and here
  rather than treated as silent authority, so a later reviewer can check
  them directly; the spec requires *a* concrete current mechanism per
  language claim, not an exhaustive literature review.
- **[Risk]** Two reference files plus a body organized around eight-plus
  decision points risks exceeding the "readable in one pass" body-length
  guidance from `create-skill` even after splitting.
  → **Mitigation**: `create-skill`'s Checkpoint 2 (Shape) and its loading-
  budget guidance (~5000 words for the body) apply at draft time; if the
  body still runs long after the split, trimming inline pitfall notes
  rather than cutting decision points is the intended lever, since the
  decision points are this skill's substance.
