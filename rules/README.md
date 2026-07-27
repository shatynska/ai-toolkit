# rules/

Memory fragments live at `rules/<rule-name>.md`, flat, directly under this
directory.

Rules are not carried by the plugin — there is no rules primitive to carry
them. They are consumed by referencing them from a project's `CLAUDE.md` or
`AGENTS.md` with an `@` import naming the fragment's path in this repository,
for example `@~/projects/ai-toolkit/rules/<rule-name>.md`. This requires no
tooling and no copying, and the fragment stays a single source of truth
rather than being duplicated into the importing project.

The import path is machine-local: it resolves only on a machine where this
repository is checked out at that path. An import committed to a repository
shared with other people resolves only for people with this library at the
same path.
