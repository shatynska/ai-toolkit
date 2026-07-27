# skills/

Skills live at `skills/<skill-name>/SKILL.md`, one level directly under this
directory — no grouping subdirectories. Skill discovery scans `skills/` for
subdirectories that directly contain a `SKILL.md` and descends no further, so
a `SKILL.md` placed any deeper is never found.

The directory name is the skill's invocation name. A differing `name` in the
frontmatter is ignored at load time without an error, so the two must match.

This file is a placeholder and is safe here: discovery only descends into
subdirectories that contain a `SKILL.md`, so a loose file directly under
`skills/` is never read as an asset. It is removed by the change that adds
the first skill.
