## MODIFIED Requirements

### Requirement: Repository is browsable without an index

The repository MUST NOT maintain an asset index. `README.md` SHALL instead document how to list the available assets from the repository itself, using the names and `description` fields the assets already carry.

Asset loading MUST NOT depend on any catalogue file.

The repository SHALL carry no tooling of its own: no build step, no script that operates on the repository, no dependency to install. This constraint governs the repository as a project. It does not govern the internals of an asset: a skill MAY bundle executable code under its own `scripts/` directory when its work is genuinely deterministic, because that code is a resource the skill carries to a consuming project rather than machinery this repository runs on itself.

#### Scenario: Adding an asset requires no catalogue update

- **WHEN** a new asset is added
- **THEN** no index or listing file needs editing, and the asset is complete once its own file is written

#### Scenario: README documents how to browse

- **WHEN** a reader wants to know what the library contains
- **THEN** `README.md` gives them the means to list it from the current contents of the repository

#### Scenario: No build step

- **WHEN** the repository is inspected for tooling
- **THEN** no build step, no repository-level script, and no dependency manifest exists, and the library is usable from a clone with nothing installed

#### Scenario: A skill bundles a script

- **WHEN** a skill requires a step to run deterministically rather than be performed by an agent
- **THEN** the code lives under that skill's own `scripts/` directory and does not count as repository tooling, because it ships as part of the asset and is never run to build or maintain this repository
