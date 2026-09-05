---
kind: standing-constraint
version: 1
---

# The session's database

This section binds the workflow rules' shared-state obligations to this
project's database. Where those rules state an end state, this one names the
service and the operations that reach it; it restates no obligation they
already carry.

## The database is real, and it is running

This project runs its database in a container, continuously. Integration tests
run against it — not against a double, an in-memory substitute, or a different
engine that is easier to reach from a working tree. A test that proves the code
works against something other than the database production uses has proved
something else.

Check the running containers before concluding that the database, or the
container runtime, is unavailable. That conclusion has been reached and been
wrong, in a session whose container was up and serving the whole time.

## What is isolated is the database, not the server

Every session shares the running server and takes **its own database** within
it, named after its working tree in whatever form this project's naming
constraints impose. The suite writes freely and issues at least one unscoped
delete, so two sessions in one database produce failures that read as defects
in the change under test and are not.

Do not stand up a second server, do not work in the development database this
project's own compose file names, and do not work in another session's.

## Provisioning this session's database

A working tree carries tracked files only, and the environment files naming a
database are ignored — so `git worktree add` brings none. Before relying on any
verification result: write this working tree's environment file, taking the
connection string from the main checkout and pointing it at this working tree's
own database; install dependencies; create that database, or reset it where one
already exists under that name, since a removed working tree leaves its database
behind; and bring it to the project's initial state.

**Migrating is not seeding.** Run this project's seed step as well as its
migrations. A database carrying only the schema fails tests that say so in
their own assertion messages.

Read a failing test's assertion message before concluding a failure is
pre-existing. It usually names the provisioning step that was missed, and
"pre-existing failure" has been the wrong answer every time it has been given.

Removing a working tree does not drop the database it used, and nothing here
reclaims one.
