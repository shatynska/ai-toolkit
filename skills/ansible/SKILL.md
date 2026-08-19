---
name: ansible
description: >
  This skill should be used when the user is writing or reviewing Ansible
  playbooks, roles, or inventory — "write an ansible playbook", "review my
  ansible role", "set up ansible in this repo", "why isn't this task
  idempotent", "should this install docker". It covers host-configuration
  practice: pinning external Galaxy roles/collections, secrets as a stated
  boundary rather than one mandated mechanism, host-level security (firewall,
  SSH hardening, unattended upgrades) split from cloud-level firewall
  ownership, inventory-provenance patterns, and idempotency traps from
  Ansible's stateless run model. It configures a provisioned host — not
  infrastructure provisioning (see terraform) and not the application stack
  itself (Compose/Kubernetes, container lifecycle); it stops once the runtime
  is installed. Not for authoring library assets (create-skill, create-agent)
  or OpenSpec work. A project's inventory choice, secrets mechanism, and
  hardening baseline belong in its own AGENTS.md; this skill defers to them.
metadata:
  tags: [infrastructure, ansible]
---

# ansible

Tool-neutral practice for configuring a host that something else has already
provisioned. This skill is a floor, not an authority: it states what holds
regardless of which provisioning tool ran first or which application runtime
runs after, and stops short of anything a specific project would need to
decide for itself.

## Read the project's conventions first

A consuming project's `AGENTS.md`, `CLAUDE.md`, and design documents override
everything below wherever they conflict with it. Read those before touching
Ansible in an unfamiliar repository.

When this skill's guidance conflicts with a project's recorded convention,
follow the project's convention — and say so; report the conflict rather than
resolving it silently.

When a question is project-specific — which inventory-provenance pattern to
use, which secrets mechanism, which host-hardening baseline — and the project
has recorded no convention at all, say that the answer is project-specific
and ask, rather than supplying one from assumption. A repository with no
recorded conventions yet is the normal case here, not an edge case — treat it
as a question to raise, not a gap to fill in silently.

## Scope: configuring a provisioned host, not provisioning it or running the app

This skill sits in the middle of a pipeline: something provisions
infrastructure (servers, networks, cloud firewalls, volumes), Ansible
configures the host that provisioning produced, and something runs the
application on top of it (Docker Compose today, possibly Kubernetes later).

Provisioning is out of scope. Don't create servers, networks, cloud
firewalls, or volumes here — that belongs to a provisioning-focused asset
(`terraform` in this library).

Application-runtime lifecycle is out of scope too, and this line is easy to
blur in practice: a playbook that installs the container runtime is one line
away from also templating a service-definition file (a Compose file, for
example) and starting the stack. Don't. This skill's responsibility ends once
the container runtime engine is installed and ready to run something — it
never templates a service-definition file and never invokes a runtime's
lifecycle commands (starting, stopping, or restarting the application stack).
That boundary is what keeps the runtime layer swappable — Compose today,
Kubernetes later — without this skill's guidance having to change.

## Installing the container runtime engine

Neither a Galaxy role nor hand-rolled tasks is the mandated way to install
the container runtime (Docker Engine or equivalent) — either is acceptable.
Whichever is used, if it pulls in an external Galaxy role or collection, pin
it. That requirement isn't scoped to this section alone — see the pinning
trap below, which applies to any external role or collection, for any
purpose, not only runtime installation.

## Secrets: a boundary, not a mandate

No single secrets mechanism is mandated here. Ansible Vault is a natural
option, but a project may reasonably choose something else — an external
secrets manager fetched at run time, for instance. What matters is the
boundary: a secret must not be committed in plaintext, and must not end up
rendered into a world-readable file on the host.

That second half is the one worth stating explicitly, because it's easy to
satisfy the first half and still fail the second: a value decrypted from an
Ansible Vault file is protected at rest, but the moment a task templates that
value into a file that will exist on the host — an environment file, a
runtime service-definition file — the rendered file is plaintext on disk,
regardless of how well the source was protected. "Encrypted at rest" is not
"never in plaintext anywhere." Set restrictive permissions on any file a
secret gets rendered into, and treat `no_log: true` as hiding a task's
output, not as protecting a file that task writes.

## Host-level security is this skill's job; cloud firewall isn't

Cloud-level firewall rules — security groups, a cloud provider's network
ACLs — belong to the provisioning stage. Host-level security belongs here:
the host's own firewall (`ufw`, `firewalld`), intrusion prevention
(`fail2ban`), SSH hardening (disabling password authentication, disabling
root login), and unattended security updates.

Don't let the two firewall layers become independent, uncoordinated sources
of truth. A host-level rule opening a port the cloud firewall closes does
nothing; the reverse — a cloud firewall open to a port the host firewall was
meant to restrict — can silently expose something nobody intended reachable.
Pick one layer as the actual gate for a given port and document which.

## Traps from a stateless run model

Ansible holds no state file. Where a provisioning tool keeps a stored model
of what it created and diffs against it, Ansible re-derives what's true by
inspecting the live host on every run. That's a materially different risk
model, not a detail — a mistake here doesn't show up as a wrong diff against
stored state, it shows up as behavior that looks fine until the host itself
tells a different story.

- **`shell`/`command` modules aren't idempotent by default.** Without a
  `creates`, `changed_when`, or an equivalent `state:` guard, they report
  "changed" on every run regardless of whether anything on the host actually
  changed. That isn't just noise: a handler `notify`d by that task fires on
  every run too, not only on a real change, silently turning "restart on
  change" into "restart every time."
- **`become` scoped at the play level expands the blast radius past what a
  single task needs.** If only one task in a play needs elevated privileges,
  scope `become` on that task, not on the whole play — a broadly-scoped
  `become` runs every other task in that play as root as well, whether or
  not it needed to be.
- **Inventory variable precedence across `group_vars` and `host_vars` is
  deep and non-obvious.** A value set at one scope can be silently
  overridden by a more specific scope the author didn't have in mind. Check
  precedence directly rather than assuming the value you set is the value
  that wins.
- **A Galaxy role or collection reference without a pinned version in a
  committed requirements file is not pinning**, for the same reason an
  unlocked Terraform provider constraint isn't: two runs of the install step
  at different times can resolve different versions within whatever range
  was specified, silently changing behavior between runs. This applies to
  any external role or collection used for any purpose — not only the one
  installing the container runtime engine.

## Inventory provenance: pick a pattern, record the choice

How a playbook learns which host a provisioning stage just produced has no
single correct answer — these are the common patterns, each with its own
failure mode:

- **A manually maintained static inventory** — simplest, but nothing stops
  it from going stale: reprovision a host, forget to update the inventory,
  and a run configures the wrong or now-nonexistent host.
- **The provisioning stage writes the inventory directly** — removes the
  staleness risk, but couples the two tools' run order together.
- **A dynamic inventory plugin reading the provisioning stage's output** —
  most robust against staleness, at the cost of the most moving parts.

Don't pick one of these as the correct answer on the project's behalf. Where
the project has already recorded a choice, follow it. Where it hasn't — which
is the expected case, not an edge case — say that the choice is
project-specific and ask, rather than silently defaulting to one pattern.

## Trigger check fixtures

- **Positive** — "I want to write an Ansible playbook that installs Docker,
  creates a deploy user, and mounts a data volume on a server I just
  provisioned with Terraform — can you help me structure it?" → expected
  routing: `ansible`.
- **Negative** — "I need to write a docker-compose.yml that defines my
  FastAPI, Postgres, and nginx services and wires up their networks and
  volumes — can you help me structure it?" → expected routing: none — no
  asset in this library covers Docker Compose service authoring or
  container-lifecycle work; `ansible`'s own scope excludes it explicitly.
