## Context

`bootstrap-toolkit-repo` establishes the layout, the tags-only classification, and the plugin packaging. This change adds the first asset: the skill that authors the others.

Two facts about how skills behave drive every decision below.

1. **The `description` is the entire loading decision.** It is the only text available when deciding whether to pull a skill into context. If it does not match how the request was phrased, the skill does not fire, and nothing reports that it could have.
2. **The observed bias is under-triggering.** Skills fail by staying silent more often than by firing wrongly. Published guidance from `skill-creator` is explicit about it: descriptions should be pushed past neutral, naming adjacent phrasings and instructing use even when the canonical keyword is absent.

Together these mean description quality is not a polish step. It is the feature, and it cannot be verified by reading.

## Goals / Non-Goals

**Goals:**

- Produce skills that meet a fixed standard without the author having to remember it.
- Catch the silent failure — a skill that never fires — before the skill is called finished.
- Keep the checkpoint count low enough that the tool gets used instead of bypassed.
- Reuse published guidance rather than restate it.

**Non-Goals:**

- A scripted eval harness, or any executable code.
- Auditing skills that already exist.
- Authoring standards for agents or rules.

## Decisions

### D1: Three checkpoints, two mandatory

```
 ① INTENT (mandatory) ──▶ ② SHAPE (conditional) ──▶ ③ DRAFT (mandatory) ──▶ write
   name · tags ·            flat vs bundled ·         frontmatter +           validate
   purpose · triggers ·     allowed-tools             body outline            trigger check
   should this be a
   skill at all?
```

Gates sit where a wrong answer is cheapest to fix at that moment and most expensive to fix later. Name and triggers are nearly free to change before anything exists and awkward afterwards, since the name is also the invocation name. Structure is cheap to change while the body is an outline.

Shape is conditional because four gates on a forty-line skill is friction, and a tool that feels heavy gets bypassed — at which point the standard stops existing. When the answer is obviously "flat file," asking is noise. Whether a given skill was "obviously flat" is a judgement made in the moment and not checkable afterwards, so this stays guidance in the skill body rather than a spec requirement.

Nothing is written before Draft approval. A rejected draft should cost a message, not a file deletion.

### D2: Intent may conclude that no skill is warranted

The Intent gate asks whether a skill is the right artifact at all, and recommends the alternative when it is not: a slash command for a deterministic sequence the user wants to invoke by name, a subagent for work needing its own context, a rule fragment or memory entry for a standing instruction.

A meta-skill that always produces a skill is a template with extra steps. The most valuable answer it can give is "that is three lines in a rule fragment" — and it is also the answer that keeps the library from filling with skills that never fire because they never needed to exist.

### D3: The trigger check is what makes a skill finished

A reviewed description is still an untested one. So the workflow closes by running two prompts against the new skill: one phrased the way a user plausibly would, which must fire it, and one adjacent prompt just outside its scope, which must not. Both outcomes are reported.

**How the check runs.** Each prompt goes to a fresh-context evaluator — given the candidate prompt and the `name` and `description` of every skill in the library, and nothing from the conversation in which the skill was written — which reports which skill, if any, it would load. The isolation is the whole point. The agent that just drafted a description will fire on its own prompt because the skill is already sitting in its working context, not because the description matched, so a same-context check returns a pass on exactly the failure this step exists to catch. Running the evaluator inside the workflow also keeps the check from becoming a fourth human round trip, which would cost more than any of the three gates.

A failure on the positive prompt means the description is too narrow and gets revised. A failure on the negative prompt means it is too broad and gets narrowed. Either way the check runs again.

*Alternative considered:* the scripted approach `skill-creator` takes — many prompts, quantitative trigger rates, variance analysis. Rejected for this repository, not on merit: it needs executable code and a harness, and at a handful of skills two prompts already catch the failure that matters. `create-skill` points at `skill-creator` for the cases where that is not enough.

*Consequence:* the evaluator reads descriptions from the library's own files, so the check does not wait on an install. Loading the library for real — installed, or `claude --plugin-dir` — remains the stronger confirmation, because it exercises discovery as well as the description.

### D4: Descriptions are written to a formula, against the bias

Three requirements, all from fact 2 rather than from taste: third-person phrasing (`This skill should be used when…`), deliberately over-eager coverage that names adjacent phrasings rather than only the canonical term, and explicit distinguishability from every other skill in the library.

The distinguishability requirement is repository-wide, not local to some group, because the layout is flat and the library has no index. Every skill competes with every other skill for the same trigger decision.

*Tension worth naming:* over-eager descriptions and clean disambiguation pull against each other. Pushing coverage widens the net; disambiguation narrows it. The resolution is that breadth is about *phrasings* of the same job and narrowness is about the *job*, and the trigger check's negative prompt is what proves the line was drawn in the right place.

### D5: Flat by default, bundled by budget

A skill is a single `SKILL.md` until that document stops being readable in one pass. Then it splits, following the convention published in `plugin-dev/skills/skill-development`: `references/` for material loaded into context on demand, `scripts/` for code that must run deterministically, `assets/` for files that end up in the skill's output rather than in context.

Adopting those three directory names rather than inventing a "supporting files" scheme means anyone who has read the official guidance already knows the layout. The loading budget comes from the same place: metadata always resident, body under roughly five thousand words, resources read only when needed.

`scripts/` deserves a note. Bundling executable code inside a skill is allowed by the convention and is the right answer for genuinely deterministic work, but it would be the first executable code in this repository — and `toolkit-structure` currently forbids executable code outright. That rule was written against build steps and repository tooling, not against a skill's own bundled resources, so this change narrows it rather than contradicting it silently: repository-level tooling stays out, a skill's `scripts/` becomes permissible. It stays available and unused until something actually needs it.

### D6: `create-skill` is its own worked example

It is authored to the standard it enforces — correct frontmatter, tags drawn from the existing vocabulary, a description meeting its own criteria, a structure chosen by its own rules, and a trigger check run against itself. Anyone who wants to know what good looks like here can read the skill that makes them, and any drift between the standard and its example is visible in one file.

### D7: `create-skill` authors into this library, not into the calling project

The skill ships in a plugin, so it can be invoked from any project that installed it. Everything it works with, though, belongs to this repository: the destination `skills/<name>/SKILL.md`, the tag vocabulary it presents, the names it checks for collisions, the descriptions it disambiguates against. Rather than resolve a target at run time between a project's `.claude/skills/`, a personal `~/.claude/skills/`, and this library, the skill is scoped to the library and says so in its own description.

The narrow scope is what keeps the workflow's rules true. Uniqueness across the library, tags drawn from the vocabulary already in use, and distinguishability from every other description are all statements about *this* library; run against an arbitrary project they are checks against an empty set that pass without meaning anything. A consuming-project variant is a later change with its own evidence, not an unstated fallback.

*Consequence:* invoked from somewhere else, the skill states that it authors into the toolkit repository and confirms that is what was wanted, rather than quietly writing into the current project.

## Risks / Trade-offs

- **The standard depends on discipline, not enforcement** → Nothing prevents writing a skill by hand; such a skill still loads and still works, minus any evidence that it triggers. Accepted deliberately. Enforcement would mean validation tooling, which means code, and the repository is markdown by design. `AGENTS.md` naming `create-skill` as the route is the whole mechanism.
- **`create-skill`'s own description competes for triggers** → It is the skill most at risk from D4's push toward breadth, since "help me build something" is adjacent to everything. Resolved by scoping to explicit skill-authoring language, and verified by the negative prompt in its own trigger check.
- **Checkpoint fatigue** → Even three gates may feel heavy for a trivial skill, and the failure mode is silent abandonment. Mitigations: the conditional Shape gate, and a Draft gate that presents a compact outline rather than a full body to read. Revisit if the tool starts getting skipped.
- **The trigger check is two prompts, and two prompts is not a measurement** → It reliably catches "never fires" and "fires on everything," and does not catch a description that works for the phrasing its author imagined and fails on three others. Accepted as a floor. `skill-creator` is the escalation path when a specific skill deserves more.
- **Prior art can drift** → `skill-creator` and `plugin-dev` are versioned outside this repository, so a referenced convention could change under us. Mitigated by referencing them for guidance rather than copying their text, so a drift shows up as a pointer worth rereading rather than as a stale duplicate. The one thing that must be copied is the list of schema-defined top-level frontmatter fields, since the contract is unusable as a pointer. It is recorded as a dated snapshot naming where it was read, so a stale list reads as stale rather than as authority.

## Migration Plan

No migration; this adds a new asset. Rollback is deleting `skills/create-skill/` and the `AGENTS.md` pointer line.

## Open Questions

- Should the trigger check's two prompts be recorded inside the skill they test, so the check is repeatable after a later edit? Recording them costs a few lines and makes re-verification mechanical; it also puts test fixtures in a file whose job is instructions. Leaning toward recording them, deferred until the first skill is written against the standard.
