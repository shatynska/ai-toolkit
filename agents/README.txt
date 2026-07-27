agents/

Subagent definitions live at agents/<agent-name>.md, flat, directly under
this directory. The flat shape keeps the invocation name free of grouping:
agent discovery walks subdirectories but folds them into the invocation name
as plugin:subdir:agent-name, so a subdirectory would make the name encode a
grouping decision that renames the agent if the grouping is later revised.

This placeholder is a .txt file, not .md: agent discovery reads every .md
file directly inside agents/ as an agent definition regardless of a leading
dot in the filename (confirmed empirically — a prior .gitkeep.md placeholder
was loaded as an agent named ai-toolkit:.gitkeep). A non-.md extension is
what keeps a placeholder here from being discovered as one.
