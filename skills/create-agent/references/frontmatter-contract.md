# Agent frontmatter contract

A dated reconciliation across three sources that disagree with each other and with shipped practice. Verified 2026-07-28 against:

- **The validator** — `plugin-dev/skills/agent-development/scripts/validate-agent.sh`, bundled with the official `plugin-dev` plugin.
- **The guide** — `plugin-dev/skills/agent-development/SKILL.md`, shipped in the same plugin.
- **The corpus** — the 31 agents at `<plugin>/agents/*.md` across the official marketplace, excluding three nested under `skill-creator/skills/skill-creator/agents/` (not top-level plugin agents; counting those gives 34, and the conclusions below are unaffected either way).

This is a snapshot, not permanent authority. Re-verify against the installed `plugin-dev` plugin and the current marketplace corpus if it has been a while — the two documents ship inside the same plugin and have already drifted from each other once.

## Where the sources conflict

| Claim | Validator | Guide | Corpus |
|---|---|---|---|
| `model` | required — hard error | required | 8/31 omit it, all load |
| `color` | required — hard error | required | 12/31 omit it, all load |
| trigger form | warns without `<example>` | prose summary + body section, never mentions `<example>` | 26/31 prose, 5/31 `<example>` |
| description opener | warns without "use this agent when" | templates it | 10/31 use it |
| `effort` | not mentioned | not mentioned | 7/31 use it (`xhigh` ×6, `medium` ×1, all `claude-security`) |
| `tools` syntax | YAML array | YAML array | array **and** bare comma list both appear |
| scoped grants | not mentioned | not mentioned | `Agent(...)`, `Workflow(...)` — 5 agents, 6 expressions, all `claude-security` |

No single source can be cited as authority. The guide was revised toward prose trigger summaries; the validator was not, and `agent-creator.md` — the flagship agent of the very plugin that ships both — still carries three `<example>` blocks.

## Required

`name` and `description` — the only fields all three sources and the corpus agree on.

## Optional at load time, with constraints where declared

`model`, `color`, `tools`, `effort`, `metadata.tags`.

**`model` and `color` should be declared anyway.** The loader does not require them, but `validate-agent.sh` hard-errors without them, and producing agents that fail the official validator on a field the loader never needed is friction on every use. Where no specific model is called for, declare `model: inherit` — it is in the validator's own accepted set (`inherit`, `sonnet`, `opus`, `haiku`), so the compatibility measure pins no model on a consuming project. Declaring `opus` or `sonnet` just to silence the validator would pin a model for a reason this contract calls a tool defect, not a real constraint.

**Value constraints the validator enforces, not just presence:**

- `name` — hard error unless it matches `^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$` and is 3–50 characters.
- `color` — warns unless it is one of `blue`, `cyan`, `green`, `yellow`, `magenta`, `red`.
- `model` — warns unless it is one of `inherit`, `sonnet`, `opus`, `haiku`.

Declaring `model`/`color` for compatibility and then picking a value outside these sets earns the warning anyway — the value matters as much as the field's presence.

**`effort` has no source at all.** Seven corpus agents use it (`xhigh` ×6, `medium` ×1); neither published document mentions the field; the validator does not check it. The corpus is the only evidence there is, and it shows values, not an accepted set — writing an enumeration here would be inventing authority nobody has stated. Record the field as available, record the observed values, and state plainly that the accepted set is unverified.

**`metadata.tags` is this repository's own requirement, not a shipped one.** No agent in the corpus declares `metadata` at all, and none of the three published sources mention it. `AGENTS.md` makes tags the only classification any asset in this library carries, and `toolkit-structure` extends that to every asset type — so a contract reconciled from external sources alone would silently drop the one field this repository requires. Loading was verified directly (not merely inferred): a throwaway agent declaring `metadata: { tags: [...] }` loaded and dispatched normally under `claude -p --plugin-dir`, confirmed 2026-07-28. When declared, tags are lowercase kebab-case, drawn from the vocabulary already in use across `skills/` and `agents/`, with a stated reason before a new tag is coined — the same rule `skill-authoring` applies to skills.

## `tools`

Both syntaxes appear in the corpus and either is acceptable:

```yaml
tools: ["Read", "Grep", "Glob"]
```
```yaml
tools: Read, Glob, Grep, Bash
```

Grant the minimum the agent's work requires. Omitting `tools` grants **all** tools — a deliberate choice to make explicitly, not a default to fall into.

**Scoped grants** whitelist specific subagents or workflows an agent may dispatch, rather than granting general dispatch capability:

```yaml
tools: Read, Glob, Grep, Bash, Agent(claude-security:explore)
```

An agent may name more than one target:

```yaml
tools: ..., Agent(claude-security:scan-inventory, claude-security:scan-researcher, claude-security:explore)
```

Use this when an agent needs to delegate to one or more *specific* other agents and nothing else — it is documented by neither published source, but five `claude-security` agents rely on it.

## Name and file-name agreement

An agent lives at `agents/<agent-name>.md`, flat, with no intervening directory. The frontmatter `name` and the file's base name **must agree.**

Which one wins if they differ is no longer an open question. A throwaway agent at `agents/throwaway-probe.md` declaring `name: throwaway-mismatch-check` was dispatched under `claude -p --plugin-dir`; it registered and was invoked as `ai-toolkit:throwaway-mismatch-check` — the **frontmatter `name`**, not the file's base name — confirmed 2026-07-28. The requirement to keep them identical stands regardless: a mismatch is confusing to a reader even when the loader resolves it consistently, and `toolkit-structure`'s invocation-name rule (`plugin:agent-name`, with a subdirectory folding into `plugin:subdir:agent-name`) is what a mismatched `name` would otherwise obscure.

## What a conforming agent still warns about

An agent produced to this contract still earns exactly **one** `validate-agent.sh` warning — the absent `<example>` blocks, which this standard deliberately rules out (see the description standard in `SKILL.md`) — **provided** its `color` is drawn from the validator's accepted set and its system prompt stays under the 10,000-character length the same script warns above. Both are easy to miss if only the "required fields" half of the validator is checked; a five-element system prompt plus a `## When to invoke` section is not always short.
