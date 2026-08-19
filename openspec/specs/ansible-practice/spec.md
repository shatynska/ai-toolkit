## Purpose

Defines what the library's Ansible guidance asserts and where it stops: a host-configuration scope bounded against infrastructure provisioning on one side and application-runtime lifecycle on the other, the traps specific to Ansible's stateless run model, and deference to a consuming project's own conventions for anything the skill deliberately leaves as an open choice.

## Requirements

### Requirement: Scope Boundary Against Provisioning and Application Runtime

The skill SHALL state its subject matter as host configuration only: the state of an already-provisioned host (OS packages, users, mounts, directories, host-level security, and installation of a container runtime engine).

The skill SHALL NOT take infrastructure provisioning (servers, networks, cloud firewalls, volumes) as its subject matter, and SHALL direct the reader to a provisioning-focused asset for it instead.

The skill SHALL NOT take application-runtime lifecycle (service definitions, container start/stop/restart, environment/service configuration for the running application) as its subject matter. It SHALL stop at the container runtime engine being installed and available, and SHALL NOT instruct that a playbook template a runtime's service-definition file (for example, a Compose file) or invoke that runtime's lifecycle commands (for example, starting or restarting the service stack).

#### Scenario: A provisioning question is deferred rather than answered

- **WHEN** the user asks how to provision a server, network, or cloud firewall
- **THEN** the skill SHALL direct them to a provisioning-focused asset rather than answering for them

#### Scenario: A runtime-lifecycle question is deferred rather than answered

- **WHEN** the user asks whether a playbook should template a service-definition file or start/restart the application stack
- **THEN** the skill SHALL state that this is out of scope and that its own responsibility ends once the runtime engine is installed and ready

#### Scenario: Excluded content classes are absent from the body

- **WHEN** the body is checked for the content classes this requirement excludes — provisioning steps for servers/networks/cloud firewalls, and application service-definition or lifecycle instructions
- **THEN** none of them SHALL be present

### Requirement: Runtime-Engine Installation Is Flexible But Pinned

The skill SHALL NOT mandate one specific mechanism for installing the container runtime engine on a configured host — a Galaxy role and hand-rolled tasks SHALL both be presented as acceptable.

Where an external Galaxy role or collection is used for this or any other purpose, the skill SHALL require explicit version pinning (a committed requirements file recording pinned versions) rather than an unpinned reference.

#### Scenario: Installation mechanism is not mandated

- **WHEN** the user asks whether to use a Galaxy role or hand-rolled tasks to install the container runtime
- **THEN** the skill SHALL present both as acceptable rather than mandating one

#### Scenario: An unpinned external role or collection is flagged

- **WHEN** a playbook references an external Galaxy role or collection without a pinned version recorded in a committed requirements file
- **THEN** the skill SHALL flag the missing pin as a drift risk before the reference is treated as safe

### Requirement: Secrets Boundary Is Stated, Mechanism Is Not Prescribed

The skill SHALL NOT mandate a single secrets mechanism (such as Ansible Vault) as the only acceptable answer; it SHALL instead state the boundary a secrets-handling approach must respect and name safe patterns.

The skill SHALL explicitly record the risk that a secret decrypted for use during a run can end up rendered into a plaintext file on the host filesystem (for example, an environment file or a runtime service-definition file), potentially with world-readable permissions — and SHALL state that encryption at rest does not by itself prevent this.

#### Scenario: A secrets-mechanism question is answered as a boundary, not a single tool

- **WHEN** the user asks what to use for secrets in a playbook
- **THEN** the skill SHALL describe the boundary and named safe patterns rather than prescribing one mechanism as mandatory

#### Scenario: The plaintext-rendering risk is surfaced before a secret reaches a host file

- **WHEN** a task would template a decrypted secret into a file that will exist on the host filesystem
- **THEN** the skill SHALL surface the risk that the rendered file may be plaintext and world-readable regardless of how the source value was protected at rest

### Requirement: Host Security Ownership Is Explicit and Split From Cloud Firewall

The skill SHALL state that cloud-level firewall rules belong to the provisioning stage, and that host-level security — host firewall rules, SSH hardening, and unattended security updates — belongs to this skill's scope.

Where both a cloud-level and a host-level firewall are in play for the same host, the skill SHALL warn against treating them as two independent, uncoordinated sources of truth.

#### Scenario: Firewall ownership question is answered with the split

- **WHEN** the user asks whether a firewall rule belongs in Terraform or in Ansible
- **THEN** the skill SHALL answer using the cloud-level versus host-level split rather than treating the two as interchangeable

#### Scenario: Dual-firewall risk is surfaced

- **WHEN** a host has both a cloud-level firewall and a host-level firewall configured
- **THEN** the skill SHALL warn that the two must not be allowed to silently disagree about what is reachable

### Requirement: Idempotency Traps Specific to a Stateless Run Model Are Recorded

The skill SHALL state that Ansible holds no state file and re-derives a host's configuration state from the live host on every run, and SHALL distinguish this explicitly from a stored-state model.

The skill SHALL record at minimum these behaviours, each of which contradicts a reasonable expectation:

- `shell`/`command` modules are not idempotent by default and report a change on every run unless `creates`, `changed_when`, or an equivalent `state` parameter is used — which in turn affects whether a dependent handler correctly fires only on a real change.
- Scoping `become` at the play level when only a single task needs elevated privileges expands the run's blast radius beyond what the task requires.
- Inventory variable precedence across `group_vars` and `host_vars` has many levels and can silently override a value from a more specific scope than the author expects.

General Ansible material that a competent model already supplies unprompted SHALL NOT displace this content.

#### Scenario: A recorded trap is available before it is hit

- **WHEN** an agent working under this skill is about to write a `shell`/`command` task without an idempotency guard, scope `become` at the play level for a single privileged task, or rely on an inventory variable without checking precedence
- **THEN** the skill SHALL already carry the reason not to, without the user having to know to ask

#### Scenario: Base knowledge is deferred to rather than restated

- **WHEN** an agent working under this skill meets a question the base model already answers reliably, such as basic YAML/playbook syntax or what a role is
- **THEN** the skill SHALL leave that to the model rather than carrying a restatement of it

### Requirement: Inventory Provenance Is a Named Menu, Not a Mandate

The skill SHALL name the common patterns by which a playbook learns which host a provisioning stage produced — at minimum a manually maintained static inventory, a provisioning stage writing the inventory directly, and a dynamic inventory plugin reading provisioning output — together with the failure mode each pattern carries.

The skill SHALL NOT mandate one of these patterns as the correct answer. It SHALL instruct that the consuming project record its own choice in its own conventions, and SHALL treat a project that has not yet recorded one as the expected case rather than an edge case.

#### Scenario: An inventory-provenance question is answered with a menu

- **WHEN** the user asks how a playbook should learn a provisioned host's address
- **THEN** the skill SHALL present the named patterns and their failure modes rather than mandating one

#### Scenario: An unrecorded choice produces a question, not a silent default

- **WHEN** a project has not recorded which inventory-provenance pattern it uses
- **THEN** the skill SHALL say that the choice is project-specific and ask, rather than silently applying one pattern

### Requirement: Consuming Project Conventions Take Precedence

The skill SHALL declare itself a floor rather than an authority: a consuming project's `AGENTS.md`, `CLAUDE.md`, and design documents override it wherever they conflict.

It SHALL instruct that those be read before Ansible work begins in an unfamiliar repository, and SHALL require that a conflict between its own guidance and a project convention be reported rather than silently resolved.

#### Scenario: Project convention wins a conflict

- **WHEN** a consuming project's recorded convention contradicts a preference stated in the skill
- **THEN** the project's convention SHALL be followed and the conflict reported rather than silently resolved

#### Scenario: Absent conventions produce a question, not an invention

- **WHEN** a project-specific question arises (for example, which host-hardening baseline to apply) in a repository that records no conventions
- **THEN** the skill SHALL state that the answer is project-specific and ask, rather than supplying an assumed answer unmarked
