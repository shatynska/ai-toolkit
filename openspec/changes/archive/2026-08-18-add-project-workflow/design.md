## Context

See `proposal.md` — Why, and `specs/` for the requirements. This document records how they are met and which alternatives were rejected.

Three properties of the repository as it stands shape everything below:

- **Every asset shipped so far is markdown.** Verification has been review plus trigger checks, never execution. `scripts/project-init` is the first executable, so this change introduces testing to a repository that has none — no runner, no config, no CI.
- **Installation copies the whole tree.** Verified against the local plugin cache: `rules/`, `openspec/`, and root documentation are present alongside `skills/` and `agents/`, under a version-pinned directory (`cache/ai-toolkit/ai-toolkit/0.2.0/`). This is what lets a shipped script read a rule fragment, and it is also what makes version skew possible.
- **`.claude/` is regenerated.** `openspec init` produced `.claude/commands/opsx/` and `.claude/skills/openspec-*`, and `openspec update` overwrites them. Nothing here may edit those files.

## Goals / Non-Goals

**Goals:**

- One code path serving new-project and adoption, with per-concern checks rather than mode branching
- Failure semantics a shell caller can act on without parsing text
- The workflow's substance reachable by tools that have no skills primitive
- A test harness proportionate to a repository with no build step

**Non-Goals:**

- CI. The tests run from one local command; wiring a pipeline is a separate concern with its own decisions.
- Machine-readable report output (`--json`). Exit codes carry the outcome, and structured output has no consumer yet.
- Any update mechanism for an already-inlined managed block. The block is *shaped* so one is possible; building it now would design against an unobserved need.

## Decisions

### The directory is `scripts/`, not `bin/`

`bin/` is the Unix convention and would be expected if anything were ever added to `PATH`. It was rejected because it is an abbreviation of a word that does not describe its contents — there are no binaries, only shell scripts — and because it is the only name in the repository requiring prior knowledge to decode, in a layout whose other names (`skills/`, `agents/`, `rules/`) are plural nouns naming what they hold.

`tools/` was the closer runner-up and was rejected for a domain-specific reason: in an AI assets repository, "tools" already means function-calling and MCP tool definitions, so `ai-toolkit/tools/` invites exactly the wrong reading.

`scripts/` costs one thing — it conventionally names a repository's *internal* helpers, whereas these ship and are meant to be run by consumers. That is corrected where it matters rather than left to inference: `toolkit-structure` now requires `AGENTS.md` to state it explicitly and to name `.claude/` as the home for repository-only tooling.

**This placement overrides an existing constraint, deliberately.** `toolkit-structure` → *Repository is browsable without an index* forbade "no script that operates on the repository" and carved out only a *skill's own* `scripts/` directory, on the reasoning that such code "ships as part of the asset." That carve-out already answered the placement question — in favour of `skills/project-init/scripts/` — using the same shipping argument this change uses to reach the opposite conclusion.

The carve-out is too narrow rather than wrong. Its reasoning is about *shipping to a consumer versus maintaining this repository*, and shipped tooling at the root satisfies that test just as well; what it did not anticipate is a consumer with no skills primitive, for whom a path under `skills/` is unreachable. The requirement is therefore widened to admit both forms and to keep the constraint that actually matters — no build step, no dependency manifest, no repository machinery — rather than being quietly broken. The same widening admits `tests/`, which the original text forbade outright.

### Root resolution belongs to the caller; the script only self-locates

This decision was absent from an earlier draft, and its absence let the specs and tasks drift into contradicting each other — the specs assigned the chain to the caller while the tasks implemented it in the script. It is recorded here so there is one owner.

**The caller owns the chain.** A skill, agent, or wrapper that must *find* the script tries `$AI_TOOLKIT_ROOT`, then `$CLAUDE_PLUGIN_ROOT`, then the machine-local path, and reports blocked if none resolves. A person typing the path has already resolved it and is subject to none of this.

**The script owns nothing but its own location.** Once running, it derives its directory from its invocation path and reads fragments relative to that, consulting no environment variable.

**Why not resolve in the script:** it could then be invoked from one copy while reading fragments from another, which would make the version it stamps into a project's marker untrue of the text it actually inlined — the one thing the marker exists to make reliable.

**Cost, accepted:** the "unresolvable root" outcome belongs to the caller, so it cannot be covered by `tests/cases/`, which exercises the script. That is one test case genuinely lost, not a reason to duplicate the chain in both places.

### Fragment metadata format

The normative form is fixed in the `toolkit-structure` delta rather than here, for the same reason the `.gitignore` entries are: this requirement outlives the change, and an obligation deferred to an archived document cannot be checked afterwards. The shape it fixes:

```yaml
---
kind: standing-constraint    # or: procedural-checklist
version: 1                   # inlined fragments only
---
```

Recorded here is only the rationale: frontmatter is chosen over a naming convention (which encodes the kind in a string nothing validates) and over a manifest (a second file to keep in sync), and it matches the form `SKILL.md` and agent definitions already use in this repository. Both fields must be readable by a human scanning the file and by the script parsing it.

### The tests are a plain shell harness, not bats

`tests/run.sh` supplies a few assertions (`assert_exit`, `assert_file`, `assert_unchanged`) and executes each case in `tests/cases/`. Every case creates a temporary directory, runs the tool against it, and asserts on filesystem state and exit code.

**Why not bats:** it is the idiomatic choice and gives better failure output, real setup/teardown, and TAP. It would also be this repository's first development dependency and first contributor install step, in a repository whose consistent property is that it has neither. The tests are structurally trivial — make a directory, run a command, assert on files and status — which is where a framework's leverage is smallest and its cost most visible. If the suite grows into something a framework would materially help with, migrating shell cases to bats is mechanical.

**Trade-off accepted:** roughly fifty lines of harness to write and maintain, and plainer failure messages than a framework would give.

### Mode is derived, never flagged

`--new` and `--adopt` were considered and rejected. A caller who must remember the mode will eventually pass the wrong one, and the tool can observe the answer directly: whether the repository rooted at the target has at least one commit.

Mode affects exactly one thing — whether the report names foundation discovery as *the next step* or as *an available option*. Every filesystem concern is evaluated identically in both. This is why the specs describe per-concern checking rather than two procedures: the modes are two endings to one path, not two paths.

### Exit codes: 0 / 1 / 2

`0` = `SUCCESS`, `1` = `ERROR`, `2` = `BLOCKED`.

`BLOCKED` takes the distinct, higher code because it is the actionable one: the caller's environment is wrong (no toolkit root, missing `git` or `openspec`, absent fragment) and the fix is theirs. `ERROR` means the tool tried and failed, which is the tool's problem. A caller wanting to distinguish "fix your environment" from "something broke" can branch on the code alone.

### Managed block delimiters

```
<!-- ai-toolkit:development-workflow v1 -->
<!-- Generated. Do not edit inside this block — it is replaced on update.
     Project-specific conventions belong below the closing marker. -->
...fragment contents...
<!-- /ai-toolkit:development-workflow -->
```

Both markers name the fragment; only the opening one carries the version, so a future update matches on the stable prefix `<!-- ai-toolkit:development-workflow` and reads the version from that same line rather than needing an exact-string match it would have to keep in sync.

The version is the *fragment's*, not the plugin's. A workflow that has not changed keeps `v1` across plugin releases, so a project's marker answers "is my workflow current?" rather than "when was I bootstrapped?"

**Why HTML comments:** invisible in rendered markdown, and every conventions file consuming this is markdown. YAML frontmatter or a fenced section would be visible clutter in a file humans read.

### The block is appended, never positioned

On a conventions file that already exists, the block goes at the end. The tool does not try to insert it near related content or ahead of project sections.

Choosing a position requires understanding a document the tool did not write. Appending is the only placement that is always correct and never surprising, and a human who wants it elsewhere can move it — the future update path matches on markers, not offsets, so a moved block is still found.

### `.gitignore` contents

The entries are enumerated in `specs/project-bootstrap/spec.md` rather than here. A design document is archived with its change while the requirement outlives it, so a durable constraint pointing at a transient file could not be checked later — and the whole purpose of enumerating is to hold the line against "minimal" growing into twenty patterns.

Recorded here is only the rationale for the one non-obvious entry: `!.env.example` is deliberate, because `.env.*` would otherwise exclude the single file in that family meant to be committed, and a developer hitting that discovers it late and confusingly.

### Foundation's `design.md` sections are fixed and named

```
## Identity
   - What it is
   - Problem it solves
   - Intended audience
## Scope
## Non-Goals
## Technology          language and framework
## Architecture
## Testing Strategy
## Development Tooling  (incl. stack-specific ignore entries)
```

Seven headings covering the nine decisions — `Identity` absorbs the three closely-related identity questions, which are never settled separately in practice.

**`Identity` carries a named item per absorbed decision.** Without them, a filled `Identity` section reads as complete even when the audience was never discussed, which defeats the gate's whole purpose: making an unanswered decision *visible*. The named items restore per-decision visibility without fragmenting a single conversation across three top-level headings.

**Why not one section per decision:** nine headings, three of which are always answered in the same breath, produces artificial fragmentation and invites one-line sections written to satisfy a checklist rather than to record a decision. The objection is to top-level fragmentation, not to itemising within a section — which is why the items are the right resolution rather than nine headings.

### Foundation surfaces into README.md and AGENTS.md, split by auto-load need

Two further decisions needed a home once foundation could produce nine settled facts: where they end up permanently, and by what rule they're split across two files.

**Rejected: `design.md` alone.** Foundation's `design.md` gets archived with the change once foundation completes (*Foundation completes at archival and remains complete*, above). Archived means discoverable only by digging into OpenSpec's own archive — not what a human landing on the repository reads, and not what a fresh agent session loads. Leaving decisions there only would make a foundation invisible the moment it succeeds.

**Rejected: everything into both files.** Duplicating all nine decisions into both `README.md` and `AGENTS.md` avoids a placement decision but creates two documents that drift the moment either is edited alone, with no marker — unlike the `development-workflow` block — recording which is authoritative.

**Chosen: split by auto-load, not by audience.** The split a reader's first instinct reaches for — "identity is for humans, tech stack is for agents" — does not track the property that actually matters. This same change already settled the load-bearing question empirically (task 1.6): Claude Code auto-loads `AGENTS.md` only via a `CLAUDE.md` import, and never auto-loads `README.md` at all. The real test is whether a future agent turn needs a fact without being told to go find it. Testing strategy and development tooling pass that test directly — they are exactly the test command and test-path glob `openspec-test-writer`'s dispatch contract requires as inputs for the very next change. Identity, problem, audience, scope, non-goals, technology, and architecture fail it — nothing downstream reads them mechanically, so they belong where a human already looks first: `README.md`.

**`AGENTS.md` gets a second, unmanaged section — not folded into the marker.** The existing `<!-- ai-toolkit:development-workflow vN -->` block is explicitly "Generated. Do not edit" — replaced wholesale on update. Foundation's testing-strategy/development-tooling content is the opposite: project-specific, never regenerated from a fragment, and would be silently destroyed by a future update if it lived inside that block. It gets its own heading below the managed block instead, outside the markers the update mechanism is scoped to.

**Mechanics.** Both destinations reuse the boundary idiom already established for the workflow block — HTML comments, invisible in rendered markdown — but carry no version, since this content is never regenerated from a toolkit fragment; it originates entirely from the project's own settled decisions, and a human is free to edit it afterward.

- `README.md`: create the file if absent, or append a section if it exists, delimited by `<!-- ai-toolkit:project-foundation -->` / `<!-- /ai-toolkit:project-foundation -->`, holding these headings in order — `## What it is`, `## Problem`, `## Audience`, `## Scope`, `## Non-Goals`, `## Technology`, `## Architecture` — fixed rather than left to phrasing, matching the precision `design.md`'s own sections already have. As each decision settles, the skill rewrites the content between the markers rather than duplicating it — the same incremental-write discipline already applied to `design.md`.
- `AGENTS.md`: append a second, separate section — outside the existing `<!-- ai-toolkit:development-workflow vN -->` block, never inside it — delimited by `<!-- ai-toolkit:project-foundation -->` / `<!-- /ai-toolkit:project-foundation -->`, holding `## Testing Strategy` and `## Development Tooling`. Placed after the workflow block where one exists, so `AGENTS.md` reads as: workflow rules, then this project's own testing/tooling conventions. `AGENTS.md` is presupposed to already exist — bootstrap always creates it before foundation can run — so no create-if-absent branch is needed here, unlike `README.md`, which bootstrap deliberately never writes.

### Each fragment declares its own kind

`rules/development-workflow.md` and `rules/project-foundation.md` each state near the top whether they are a standing constraint or a procedural checklist. The kind determines whether a tool may inline the fragment into a project's conventions file.

**Why in the fragment rather than a naming convention or a manifest:** a filename convention encodes the kind in a string nothing validates, and a manifest is a second file to keep in sync with the first. Declaring it in the fragment puts the fact where the reader — human or tool — is already looking.

### The Claude Code skill is thin by construction

`skills/project-init/SKILL.md` resolves the root, invokes `bash <root>/scripts/project-init`, relays the report, offers a commit, names the next step. It holds no logic a second harness's wrapper would have to replicate.

The test of whether the split held: a wrapper for another tool should be writable from `--help` alone, without reading the Claude Code skill.

### `AGENTS.md` is not loaded by Claude Code without a `CLAUDE.md` import — confirmed empirically

Verified 2026-08-17, decisively. Two scratch directories, otherwise identical, each carrying an `AGENTS.md` instructing that the response to "say hello" must be exactly a fixed marker string:

- **`AGENTS.md` alone, no `CLAUDE.md`**: `claude -p "say hello"` returned an ordinary greeting. The rule was never seen.
- **Same `AGENTS.md`, plus a `CLAUDE.md` containing only `@AGENTS.md`**: `claude -p "say hello"` returned the exact marker string.

This settles task 1.6 and the branch it was gated on: for Claude Code, writing `AGENTS.md` alone genuinely does leave the workflow rules inert, exactly as the bootstrap spec's *Workflow rules reach a project as a versioned managed block* requirement anticipated. The consequence reaches further than that requirement's own scope, though. Its ordered rule only creates `CLAUDE.md`-adjacent content when `CLAUDE.md` *already exists* (case 2: leave it untouched, state the import line). It says nothing for case 1 (`AGENTS.md` created fresh, neither file existed) or case 3 (`AGENTS.md` already existed, still no `CLAUDE.md`) — and case 1 is the ordinary **new-project** path, the single most common bootstrap outcome. Under the requirement as written, a brand-new project bootstrapped for Claude Code gets an `AGENTS.md` carrying the workflow rules and no `CLAUDE.md` at all, which this test shows are then never loaded.

The requirement's "the report SHALL state the one line the user must add" clause is written broadly enough to cover this — it triggers whenever a harness reaches conventions only through a different file, not only in the already-has-`CLAUDE.md` branch — but the *implementation* task list did not make that explicit for cases 1 and 3. Fixing forward: the report names the import line (`@AGENTS.md` in `CLAUDE.md`) whenever `CLAUDE.md` does not exist or does not already import `AGENTS.md`, regardless of which of the three ordered-rule branches produced the current `AGENTS.md`. This is a clarification of scope, not a new obligation — the requirement's own reasoning already demanded it; only the case enumeration undersold it.

**Codex and Antigravity remain unverified** (task 1.7) — this session has no way to invoke either non-interactively, so the proposal's claim that they read `AGENTS.md` natively stays an assertion, not an observation, and is flagged as such wherever it is stated.

## Risks / Trade-offs

**A project is bootstrapped from a stale installed plugin, silently getting an older workflow** → The marker records the fragment version and the report states it at the moment of the run. `$AI_TOOLKIT_ROOT` bypasses the pin for anyone editing the toolkit. Not prevented — reconciling an outdated install is the deferred update command's job.

**`$CLAUDE_PLUGIN_ROOT` does not resolve at skill runtime — confirmed, not hypothetical.** Verified 2026-08-17 against Claude Code with `ai-toolkit` both as an installed plugin and via `--plugin-dir`: a throwaway skill instructing `printenv CLAUDE_PLUGIN_ROOT` exited non-zero (variable unset) in both cases, invoked non-interactively via `claude -p`. It is second in a three-entry chain, so failure degrades to the machine-local path rather than breaking the tool — `skills/project-init/SKILL.md` documents `$AI_TOOLKIT_ROOT` as the setup step that makes resolution zero-friction, and the machine-local default remains the fallback for everyone else. No other part of the design changes: the chain was written to survive exactly this outcome.

**The tool corrupts a conventions file it appends to** → It only ever appends, never parses or rewrites existing content. The one destructive-looking operation — replacing a managed block — is out of scope here; this change writes a block only where none exists.

**The delegated initializer writes files the tool never sees** → Confirmed empirically 2026-08-17: `openspec init --tools <value> --no-animation <target>` is fully non-interactive and exits 0. Run against a target directory that already held `AGENTS.md`, `CLAUDE.md`, `.gitignore`, and a source file, its writes were entirely confined to `.claude/commands/opsx/*`, `.claude/skills/openspec-*`, and `openspec/config.yaml` for `--tools claude`; to `.agents/skills/*` and `openspec/config.yaml` for `--tools agents`. Every one of `AGENTS.md`, `CLAUDE.md`, `.gitignore`, and the source file was byte-for-byte unchanged (checksummed before and after) under both values. The delegated command does not touch the files this tool's never-overwrite guarantee is stated in terms of — the bound recorded above is real but, empirically, its cost is near zero for the two `--tools` values tested. **`claude` is the documented default**, since this is the toolkit's primary harness; `--tools` remains a passthrough for any other value `openspec init` accepts.

**`scripts/` accumulates repository-internal helpers** → The name invites exactly that. `toolkit-structure` states what belongs there (deterministic operations that ship) and names `.claude/` for tooling used only to work on this repository. This is the chosen name's known weakness and the mitigation is documentary, so it needs watching rather than trusting.

**The two new skills trigger on each other's prompts, or on `create-skill`'s** → "Set up a new project" is genuinely ambiguous between them. Descriptions must draw the boundary explicitly, and `skill-authoring` requires it be *observed* in a trigger check rather than judged from the draft. Budgeted as real work, not a formality.

**Tests pass while the tool is broken under a real harness** → The suite exercises the script directly and cannot cover skill invocation, root resolution under a real plugin install, or `openspec init`'s interactive behavior. A manual end-to-end run — empty directory through to a foundation change — remains necessary, and is a task rather than an assumption.

**The bash 3.2 constraint is violated without anyone noticing** → ShellCheck does not check version compatibility by default, and development happens on a newer bash, so a 4.x-only construct would pass every local check. Mitigated by keeping the script small and avoiding the constructs that carry the risk (associative arrays, `${var,,}`, `readarray`), and by naming this in review rather than trusting the linter.

**Scoping the repository concern to the target itself creates a nested `.git`** → Running the tool in an uncommitted subdirectory of an existing repository now initializes a second repository rooted there, because the enclosing repository no longer satisfies the concern. This is the deliberate fix for a project inside a monorepo being misclassified as adoption — the alternative (walking up for an enclosing repository) would misclassify the common case this fix targets. The nested repository is an accepted consequence, not an oversight: it is what "new project" mode means when the target has no repository of its own, and a user working inside a monorepo who wants the enclosing repository is expected to run the tool without initializing a new one, which per-concern checking makes safe to interrupt before it does.

## Open Questions

**Should `scripts/project-init` be documented as a `PATH` addition, or always invoked by full path?** A `PATH` entry makes it feel like a real tool and shortens every invocation; a full path is unambiguous and needs no shell setup.

One constraint on whichever form wins: the script locates its fragments from its own invocation path, so a **symlinked** entry point resolves to the symlink's directory rather than the toolkit's, and the fragments would not be found. The failure is safe — `BLOCKED`, not a wrong result — but any `PATH` form must either preserve self-location (a wrapper that invokes the real path, or a `PATH` entry pointing at `scripts/` itself) or symlinked invocation must be documented as unsupported. Subject to that, this remains a documentation decision, deferrable until it is clear which form actually gets typed.

**Resolved as: still deferred, deliberately.** Every invocation in this change's own implementation and verification — the test suite, every manual chain-resolution check, every end-to-end run — used an explicit full path (`bash "$PROJECT_INIT"`, `bash <root>/scripts/project-init`), because the Claude Code skill (`skills/project-init/SKILL.md`) is the primary caller and it resolves and invokes by full path itself; a human typing the command directly never came up. That is not the "used a few times" signal this question was waiting on — it is zero signal about direct human typing, since the skill is the one doing the typing. The question stays open for the same reason it was deferred originally, now with slightly more (still inconclusive) grounds: nothing in this change's own usage argued for either form.
