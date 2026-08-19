## Why

A consuming project provisions infrastructure with Terraform, configures the provisioned host with Ansible, and runs its application stack with Docker Compose (with Kubernetes named as a likely future runtime swap). The library already carries provider-neutral practice for the provisioning stage (`terraform`) but nothing for the configuration-management stage, so a project reaching for Ansible today gets no recorded guidance on the traps specific to it — traps that, unlike Terraform's, stem from having no state file and from re-deriving host state on every run.

## What Changes

- Add a new `skills/ansible/SKILL.md` library skill, same tier and posture as `skills/terraform`: provider/tool-neutral practice, a floor rather than an authority, deferring to a consuming project's own `AGENTS.md`/`CLAUDE.md` wherever they conflict.
- Scope the skill to host configuration only, drawing an explicit boundary against the two neighboring stages of the pipeline it sits inside:
  - Provisioning infrastructure (servers, networks, cloud firewalls, volumes) stays out of scope — that is `terraform`'s subject matter.
  - Application-runtime concerns (Compose service definitions, container lifecycle, env/service configuration) stay out of scope — the skill installs the runtime engine and stops there, so the runtime layer (Compose today, possibly Kubernetes later) can be swapped without the skill's guidance changing.
- Cover, within that boundary: OS package/user/mount/directory state, host-level security (host firewall, SSH hardening, unattended upgrades) as distinct from cloud-level firewall ownership, runtime-engine installation with mandatory version pinning when an external Galaxy role/collection is used, secrets handling stated as a boundary and a named risk rather than a prescribed mechanism, and the idempotency traps that follow from Ansible having no state file.
- Record inventory provenance (how a playbook learns which host Terraform just built) as a named menu of patterns with their respective failure modes, deferring the actual choice to the consuming project — the same posture the skill takes toward runtime-engine installation and secrets.

## Capabilities

### New Capabilities

- `ansible-practice`: Provider/tool-neutral Ansible configuration-management guidance — scope boundary against provisioning and application-runtime stages, host-state content areas, and the traps specific to Ansible's stateless run model.

### Modified Capabilities

_None._

## Impact

- New file: `skills/ansible/SKILL.md`.
- New spec: `openspec/specs/ansible-practice/spec.md`.
- No existing capability's requirements change; `skills/terraform/SKILL.md` is referenced as a structural precedent but is not itself modified.
