---
name: terraform
description: >
  This skill should be used when the user is writing or running Terraform —
  "write a terraform module", "add a resource", "review my .tf files", "set up
  terraform in this repo", "why does the plan want to replace this", "should I
  run apply", "the state is out of sync", "import an existing resource", "how
  do I test this module" — or on any task touching .tf files, .tfvars, a plan,
  or Terraform state. It covers provider-neutral practice: module and variable
  design, validation, version pinning, testing mechanisms and their limits, and
  the discipline around plan, apply, state and drift, including confirming
  before any apply that would replace or destroy a resource. Not for authoring
  library assets (create-skill, create-agent) or OpenSpec work. How to build a
  CI pipeline around Terraform is not covered here. Provider specifics and a
  project's own infrastructure decisions belong in that project's AGENTS.md;
  this skill defers to them on conflict.
metadata:
  tags: [infrastructure, terraform, hitl]
---

# terraform

Provider-neutral practice for writing and running Terraform. This skill is a floor, not an authority: it states what holds regardless of provider or CI system, and stops short of anything a specific project or a specific cloud would need to decide for itself.

## Read the project's conventions first

A consuming project's `AGENTS.md`, `CLAUDE.md`, and design documents override everything below wherever they conflict with it. Read those before touching Terraform in an unfamiliar repository.

When this skill's guidance conflicts with a project's recorded convention, follow the project's convention — and say so; report the conflict rather than resolving it silently.

When a question is provider-specific or project-specific (which server types exist, which region, what the backend is, how credentials are scoped) and the project has recorded no convention at all, say that the answer is provider- or project-specific and ask, rather than supplying one from assumption. A repository with no recorded conventions yet is the normal case here, not an edge case — treat it as a question to raise, not a gap to fill in silently.

## Module and environment boundaries

A module encapsulates a resource or a closely related group of resources behind variables and outputs. It should not know which environment consumes it — environment-specific values (region, sizing, an environment name) belong in the calling configuration, not hardcoded inside the module.

Where possible, make an unsafe configuration structurally inexpressible rather than documenting a rule against it. If every server a project creates must have a firewall, wire firewall attachment into the module so a firewall-less server can't be created through it — don't rely on every caller remembering.

A conventional file split keeps a module skimmable: `main.tf` for resources, `variables.tf` for inputs and their validation, `outputs.tf`, `versions.tf` for provider requirements. This is a convention, not a rule — follow the project's own layout where one is already established.

## `variable validation` is the cheapest guardrail

Reject bad input at plan time with `validation` blocks rather than letting a malformed value surface as a provider error, or worse, apply successfully. Validate the properties that actually matter for safety or correctness — non-empty, excluded values, format — not just type, which Terraform already enforces.

## Traps that cost a rewrite

These four contradict a reasonable expectation, which is exactly why they're worth stating rather than assuming they'll be caught by inspection:

- **`prevent_destroy` accepts only a literal `true`/`false` — it cannot read a variable.** Hardcoding it inside a shared module makes that module permanently undestroyable for every consumer, including a future environment that legitimately needs to be torn down. Keep it out of modules entirely. If a resource genuinely must never be destroyed, declare `prevent_destroy` as a literal in that specific environment's own configuration, on that specific resource — not in shared code.
- **`count` index shifts destroy and recreate resources that didn't change.** `count` addresses resources positionally. Remove or reorder an element in the list driving it, and every resource after that point shifts index — Terraform reads that as "destroy the old index, create a new one," even though nothing about that resource's own configuration changed. `for_each` keyed by a stable identifier (a map key, a name) ties each resource to its key regardless of ordering, so removing one element leaves its neighbors alone. Default to `for_each` whenever the underlying collection can plausibly reorder or lose an element from the middle.
- **A version constraint without a committed lock file is not pinning.** A `~>` constraint in `required_providers` only bounds what `terraform init` is allowed to select; the version actually resolved is recorded in `.terraform.lock.hcl`. Without that file committed, two runs of `init` at different times can resolve different provider versions within the same constraint, silently changing behavior between runs. Commit the lock file.
- **`sensitive = true` does not keep a value out of state.** It redacts the value from CLI output and from a plan shown to a human. State itself is not encrypted by default, and a "sensitive" value is recoverable by anyone who can read the state file or backend directly. Treat access to state as the actual secret boundary, not the `sensitive` flag.

## State holds secrets in cleartext

State can contain values that are themselves secrets — a generated password, a private key, a connection string — independent of whether any variable was ever marked `sensitive`. Restrict who and what can read the state backend accordingly, and treat any local `plan` or `apply` as pulling that material onto whatever machine ran it.

A saved plan file (`-out=tfplan`) inherits the same property: an unencrypted artifact that can embed the same values a full state read would expose. Handle it like state — minimal retention, restricted access, and if it ever has to leave a trusted environment (a public repository's CI artifacts, for instance), encrypt it first. Never commit state or a plan file to version control.

## The plan is a checkpoint, not a step

Always run `plan` before `apply`, even for a change that looks obviously safe. Read the plan's summary — what it will create, update, replace, and destroy — and name every resource carrying a replace or destroy action before doing anything else with it.

A **replace** is not a form of update. Terraform performs it as destroy, then create. For any resource holding data — a server, a volume, a database — a replace can mean real data loss even though the configuration never asked for deletion.

**Confirmation rule:** if a plan contains any replace or destroy action, stop and get explicit confirmation from the user before applying it. Stating the blast radius and then applying within the same turn does not satisfy this — the user has to actually respond.

If a plan contains only create and update actions, the blast radius is still stated, and the apply may proceed without a separate confirmation — but only where the apply consumes that exact saved plan (see the next section). Where the apply would re-plan instead of consuming it, the classification is stale by the time the apply runs: a create/update-only plan can pick up a replace or destroy between when it was read and when a fresh plan executes, and the confirmation rule applies regardless.

## A saved plan is what makes approval binding

`terraform plan -out=tfplan`, followed later by `terraform apply tfplan`, applies exactly the plan that was saved and reviewed. No new plan is computed at apply time.

Running `terraform apply` without a saved plan file re-plans immediately before applying. Whatever was reviewed earlier — in conversation, in a pull request comment, wherever — is not what actually gets applied; a fresh plan is, computed against whatever state and configuration look like at that later moment, which can have moved in the meantime.

This is the mechanism that makes an approval mean something specific: approving "this diff" only binds to that diff if the apply consumes the saved plan file rather than a freshly computed one. It is a property of the plan artifact itself, not of any particular CI system — how a pipeline stores and passes that file between stages is a pipeline design question, outside what this skill covers.

## Applies happen where the project says

Some projects run applies only through a gated pipeline — required review, an approval step, specific credentials. Where that's the case, never apply directly from a local session, regardless of what credentials happen to be available locally. An available credential is not the same as an authorized path.

What that gated path looks like, how it's built, and how it's enforced is the project's own decision, recorded in its own conventions — not something this skill prescribes.

Where a project states no such constraint, plan and apply may run locally as normal — though state locking, below, means a local plan can still legitimately fail against a run that's mid-apply elsewhere.

## State is surgery, not editing

`terraform import`, `terraform state mv`, and `terraform state rm` change what Terraform believes is real without touching actual infrastructure. They are precise, deliberate operations — not a casual fix for a plan that looks wrong.

Never pass `-lock=false` to anything that writes state, including `apply` and most `state` subcommands. Locking exists so two runs against the same state can't corrupt it by writing concurrently; bypassing a stuck lock to "get past it" usually means something else is genuinely running, and skipping the lock risks exactly the corruption it exists to prevent. A read-only plan that writes nothing — a scheduled drift check, for instance — is the one place skipping the lock is legitimate, because it never contends for what the lock protects.

If a lock genuinely is stale — the process that held it is confirmed dead — that's a deliberate `force-unlock` after confirming the holder is actually gone, not a routine flag to reach for.

## Drift and honest `ignore_changes`

Drift is any difference between state and real infrastructure that Terraform didn't cause. Some of it is real — someone changed something out-of-band. Some of it is noise — a provider normalizing or generating a value it doesn't fully hand control of to Terraform.

Don't reach for `ignore_changes` on first sight of drift. Confirm first whether it's provider noise — check the provider's documentation, or observe that the same diff recurs identically on every run with no real-world cause — versus a real change that the plan is correctly reporting.

`ignore_changes` is honest when it's scoped to a specific attribute confirmed to be provider-managed noise, with a note saying so. It's concealment when it's applied broadly to make an inconvenient diff go away without knowing why the diff exists.

## Testing Terraform

Three mechanisms exist for testing Terraform code, each answering a different question — none of them substitutes for the others:

- **Static checking** — `terraform validate` and `terraform fmt -check`, together with third-party linters and policy tools (`tflint`, `checkov`, OPA/Sentinel, and similar) where the project already uses them. This catches structural, style, and policy problems before anything runs, at effectively zero cost — but it says nothing about what a real apply against real state would actually do.
- **`terraform plan` as a dry-run** — see "The plan is a checkpoint, not a step", above. That section's discipline is what this mechanism means for testing purposes, and isn't restated here.
- **`terraform test`** — the native HCL-based test framework, and the closest thing to an actual test suite: it runs assertions against either mocked providers or real infrastructure. It's proportionate for a module meant to be shared or reused; for a small, single-use configuration it's often more setup than the target warrants. Don't mandate it on the project's behalf — name it and let the project's own scale decide, the same way this skill defers CI/pipeline shape and module-registry choice. **A run against real infrastructure is not a shortcut around the plan checkpoint above.** Without `mock_provider` blocks, it applies and tears down real resources through a path other than a reviewed `terraform apply` — any replace or destroy it would perform carries the same confirmation obligation as an ordinary apply, not an exemption because the command is different.

For the language- and tool-agnostic side of testing discipline — recording a baseline before any claim that a test fails, what a failing test's state actually establishes — see this library's `testing` skill rather than restating it here.

## What this skill doesn't decide

Provider choice, backend choice, module registry versus local modules, and CI/pipeline shape are all project decisions. This skill states practice that holds regardless of those choices; it does not make them.

## Trigger check fixtures

- **Positive** — "I need to write a Terraform module for provisioning a server and I'm not sure how to structure the variables — can you help?" → expected routing: `terraform`.
- **Negative** — "I want to create a new skill in this repo that teaches good Terraform practices — how do I set that up?" → expected routing: `create-skill`.
- **Positive, testing** — "How do I test this Terraform module before I apply it?" → expected routing: `terraform` **and** `testing` together. `testing`'s own description names `terraform` explicitly among the skills it co-triggers with ("load python, langgraph, bash or terraform alongside it"), so this behaves like the documented `testing` + `python` pair rather than like `ansible`'s case, where `testing`'s description names no domain skill and a testing-shaped Ansible prompt was confirmed to route to `ansible` alone.
