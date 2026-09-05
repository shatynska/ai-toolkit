---
name: n8n-workflow-review
description: This skill should be used when the user wants to review, audit, or check a raw n8n workflow JSON file for problems — phrasings like "review this n8n workflow", "audit this n8n workflow.json", "check this n8n automation for issues", "does this workflow have any security problems", or when an n8n workflow export shows up in a diff/PR needing a domain-specific look. It applies a fixed checklist covering credential hygiene, error handling, trigger/webhook auth, structural correctness, and style directly against the workflow JSON's own fields (nodes, connections, credentials, settings, pinData) — independent of the n8n MCP server's workflow-building tools, and distinct from the general-purpose code-review skill, which checks correctness/simplification but carries no n8n-specific domain knowledge.
metadata:
  tags: [n8n, review]
---

# n8n-workflow-review

## When this applies

This skill reviews an n8n workflow as it already exists — the JSON export (`nodes`, `connections`, `settings`, `pinData`, `credentials` references, and so on), typically committed to a repo and read directly from disk or a diff. It does not build or edit workflows, and it does not call the n8n MCP server — apply it with just the JSON file in hand, nothing else required.

It is not a replacement for the general `code-review` skill. That skill already covers correctness, simplification, and reuse for any file in a diff, n8n JSON included. This skill exists for the domain knowledge `code-review` doesn't have: what specific fields and patterns in an n8n workflow are dangerous, broken, or sloppy. Both can fire on the same PR — they're checking different things.

## Checklist

Work through all five lanes against the workflow JSON. Every item below traces to a real field in n8n's export format — check the field directly rather than guessing from node type alone.

### 1. Credentials & secrets hygiene

- A raw token, API key, or password sitting in a node's `parameters` instead of going through the `credentials` field — the classic spot is an HTTP Request node's headers, query parameters, or body.
- A secret hardcoded inside a Code node's JS/Python source.
- `pinData` holding real production data rather than a synthetic fixture — pinned data is exported along with the workflow.
- One broad credential reused across many unrelated nodes where a scoped, purpose-specific credential would limit blast radius.

### 2. Error handling & reliability

- A node that performs an external call (HTTP Request, database, any API-specific node) with no `onError` / `retryOnFail` set — a transient failure silently stops the whole workflow.
- No workflow-level `settings.errorWorkflow` on a workflow where a failure has real consequences.
- A webhook-triggered workflow with no idempotency or dedup handling, against the fact that webhook delivery is commonly at-least-once.
- `continueOnFail` or `alwaysOutputData` used in a way that masks an error rather than handling it (downstream nodes silently consuming an error payload as if it were valid data).

### 3. Trigger & auth surface

- A Webhook node with `authentication: none`.
- A custom webhook path that's predictable or guessable rather than opaque.
- A Schedule Trigger cron expression that looks like a typo relative to the workflow's evident intent (e.g. runs every minute when the design implies daily).

### 4. Structural & correctness smells

- A deprecated or unusually old `typeVersion` on a node.
- An orphaned node — present in `nodes` but not reachable from any trigger via `connections`.
- An unreachable branch on an IF/Switch node.
- A Code node reimplementing logic a built-in node would do more safely or clearly (e.g. hand-rolled HTTP calls instead of the HTTP Request node).
- A disabled node (`disabled: true`) left committed with nothing — no Sticky Note, no name change — explaining why.
- An expression (`{{ }}`) that assumes a field exists with no null-safety, where a missing/undefined value would break the run.
- A loop over a large or paginated dataset with no batching (no Split In Batches or equivalent), risking timeouts or memory exhaustion.

### 5. Style & documentation

- Generic default node names left unchanged (e.g. "HTTP Request1", "IF1") instead of describing what the node does.
- A non-obvious branch, workaround, or the workflow's overall purpose with no Sticky Note explaining it.
- No workflow-level description or tags, hurting discoverability.
- Magic values (URLs, thresholds, IDs) inlined across multiple nodes instead of centralized in one Set/config node.
- Inconsistent naming convention across nodes in the same workflow.
- An expression or Code node doing something non-obvious with no comment or note, even where it's technically correct.

## Output format

Report findings as a flat checklist, grouped by the five lanes above — no severity ranking or scoring. For each lane, list only the items that actually apply to the workflow under review; omit a lane entirely if nothing in it applies. For each finding, name the specific node (by its `name` field) or the workflow-level field involved, and state the concrete problem in one line. Do not manufacture findings to populate an empty lane — an empty lane is a valid, and common, outcome.

## Trigger check fixtures

- **Positive** — "Can you review this n8n workflow.json for problems before I commit it — check credentials, error handling, that kind of thing?" → expected routing: `n8n-workflow-review`.
- **Negative** — "Build me an n8n workflow that posts a Slack message whenever a new GitHub issue is opened." → expected routing: none — every n8n-related asset in this library is scoped to reviewing an existing workflow, not authoring a new one; building falls to the n8n MCP server's own tools, which aren't a library asset.
