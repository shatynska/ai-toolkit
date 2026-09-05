# rules/

Memory fragments live at `rules/<rule-name>.md`, flat, directly under this
directory.

Rules have no dedicated Claude Code primitive — nothing loads `rules/`
automatically the way `skills/` and `agents/` are loaded. That does not
mean they are absent from an installed copy: plugin installation copies
this repository's entire tree, so these files are present and readable
wherever the plugin is installed. Two paths reach a fragment from there:

- **`@` import** — referencing a fragment from a project's `CLAUDE.md` or
  `AGENTS.md`, for example `@~/projects/ai-toolkit/rules/<rule-name>.md`.
  This requires no tooling and no copying, and the fragment stays a single
  source of truth rather than being duplicated into the importing project.
  The import path is machine-local: it resolves only on a machine where
  this repository is checked out at that path. An import committed to a
  repository shared with other people resolves only for people with this
  library at the same path.
- **A shipped tool reading it** — an executable under `scripts/` locates a
  fragment relative to its own installed location and reads it directly,
  with no `@` import and no harness involved. `scripts/project-init` does
  this: it inlines `development-workflow.md` into a project's `AGENTS.md`.

Both paths reach any fragment under `rules/`, a binding fragment such as
`rules/development-workflow-database.md` included. What a binding fragment
lacks until tooling catches up is not a route but a *tool* route: it is
imported or copied by hand, where the workflow fragment is written into a
managed block.

## Fragment kind

Every fragment declares its kind in YAML frontmatter:

```yaml
---
kind: standing-constraint    # or: procedural-checklist
version: 1                   # only if the fragment is ever inlined
---
```

A **standing constraint** is intended to reach a project's `CLAUDE.md` or
`AGENTS.md` and remain in force there, by either path above. A
**procedural checklist** describes a one-time procedure, read on demand,
and is never inlined into a project's conventions file — inlining it would
leave permanent instructions for work already finished. `version`
increments when the fragment's **body** changes — the text a project actually
inlines — and not for an edit confined to the frontmatter itself; it has no
relationship to the plugin's own version. The obligation is owned by
`project-bootstrap`'s requirement "The fragment's version increments when its
body changes"; `toolkit-structure` fixes the frontmatter's form and defers
that condition to it.
