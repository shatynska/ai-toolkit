## 1. Fragment

- [x] 1.1 Replace the body of `rules/development-workflow.md` with the
      normative text in `design.md — The v2 fragment body`, verbatim. The
      body is the deliverable, not a description of it: do not reword,
      re-order or compress while transcribing.
- [x] 1.2 Set `version: 2` in the fragment's frontmatter; leave `kind:
      standing-constraint` unchanged.
- [x] 1.3 Verify no harness-specific name — `ai-toolkit:*`, `/code-review`,
      `PROCEED`, `PROCEED WITH CHANGES`, `CHANGES REQUIRED`, `REJECT`,
      `[MINOR]` — appears anywhere outside a `_Claude Code binding:_`
      paragraph. This is the MODIFIED requirement's role-before-tool
      constraint checked by reading, ahead of 3.1 checking it by running.
- [x] 1.4 Verify mechanically — not by eye — that the opening paragraph and
      the five sections carried over from v1 (`Verification before any
      completion claim`, `Small, reviewable commits`, `Incremental
      development and scope control`, `Requirements and assumptions`, `The
      repository is the source of truth`) are byte-identical to v1,
      including line breaks, so the diff shows only what this change intends
      to alter.
- [x] 1.5 Verify the test-authoring gate still scopes to a change with
      derivable behavior and yields to a stated exemption, and that author
      independence appears in the role sentence rather than only in the
      binding — the two regressions the first review round caught.

## 2. Decouple the existing suite from the literal version

- [x] 2.1 `tests/lib.sh`: add a helper that reads the current `version:`
      from `rules/development-workflow.md` — resolved relative to the
      toolkit the case is exercising, not hardcoded — so cases assert
      against the fragment's own value.
- [x] 2.2 `tests/cases/managed-block-current-version.sh`: build its
      pre-existing block from the helper instead of the literal `v1`, so it
      keeps testing "a block at the current version is not rewritten"
      rather than "a block at version 1".
- [x] 2.3 `tests/cases/self-location-conflicting-env.sh`: assert the real
      fragment's version from the helper instead of the literal `v1`. Leave
      the decoy's fabricated `999` hardcoded — a fixed, distinguishable
      wrong answer is what that case is built on.
- [x] 2.4 `tests/cases/managed-block-older-version.sh`: keep the fabricated
      *older* version hardcoded; take the "tool carries version N"
      assertion from the helper.
- [x] 2.5 `tests/cases/fragment-absent-block-present-blocks.sh`: confirm its
      `v1` marker is only a presence fixture and needs no change, or update
      it from the helper if the assertion is version-sensitive.

## 3. New coverage for the added requirements

- [x] 3.0 Resolve `tests/README.md`'s own standing claim before writing any
      case in this group. It scopes its hand-written exemption to that
      suite alone and forecloses deciding silently. Either dispatch
      `ai-toolkit:openspec-test-writer` for the cases in this group, or
      record an explicit exemption in `tests/README.md` saying why not.
      Deciding it silently is the one option the file forecloses.
- [x] 3.1 Add a case asserting the role-before-tool constraint mechanically:
      in the fragment, every line carrying a harness-specific token (the set
      enumerated in 1.3) is inside a binding paragraph. This covers the
      MODIFIED requirement — the one requirement in this change's delta the
      existing harness can check by running rather than by review.
- [x] 3.2 Add a case asserting that the block inlined into a fresh project
      carries the fragment's own current version marker and reproduces the
      fragment's body byte-for-byte — a structural property that survives a
      later section rename, rather than a list of v2 headings that would
      reintroduce the content coupling task 2 exists to remove.
- [x] 3.3 Update `tests/coverage.md`: add entries for this change's 13 new
      scenarios — 12 in the `project-bootstrap` delta (2 on the MODIFIED
      requirement; 3 + 3 + 2 across the three ADDED ones; plus the 2 added to
      the ordering requirement in review round 1) and 1 in the
      `toolkit-structure` delta ("The increment rule has exactly one owner").
      Mark which are covered by a running case and which are review-only.
      Correct both affected section headings: `project-bootstrap`
      `(36 scenarios)` → 48, and `toolkit-structure` `(26 scenarios)` → 27.
      Widen the preamble, which currently scopes the file to
      `add-project-workflow` alone.
- [x] 3.3a Change `tests/coverage.md`'s "Rules remain meaningful without the
      toolkit installed" row from uncovered to covered by task 3.1's new
      case — it is the scenario that case makes mechanical.
- [x] 3.4 Record in `tests/coverage.md`, once, why most scenarios of the
      three added requirements are review-verified: the harness exercises
      `scripts/project-init`'s behavior, and those requirements constrain
      the prose of a fragment the script copies without interpreting. State
      it as a stated limit, not an omission.

## 4. Verification

- [x] 4.1 Run `bash tests/run.sh`; every case passes.
- [x] 4.2 Run `openspec validate revise-development-workflow --strict`.
- [x] 4.2a Confirm both delta specs are written — `specs/project-bootstrap/`
      and `specs/toolkit-structure/` — and that neither has been applied to
      `openspec/specs/` by hand. Archival syncs both; hand-applying one
      leaves `toolkit-structure` pointing at a `project-bootstrap`
      requirement that does not exist yet, which is worse than the
      duplication this change removes.
- [x] 4.3 Initialize a throwaway directory with
      `bash scripts/project-init <tmpdir>` and confirm its `AGENTS.md`
      carries a `v2` block whose body matches the fragment.
- [x] 4.4 Run `bash scripts/project-init` against a fixture already holding
      a `v1` block and confirm the report states both versions and rewrites
      nothing — the propagation gap behaving as the proposal says it will,
      confirmed rather than assumed.

## 5. Completion

- [ ] 5.1 Run `/code-review` over the diff, per the rule this change adds.
- [x] 5.2 Update `rules/README.md`: it currently says `version` "increments
      when the fragment's text changes", which diverges from the body-scoped
      requirement for a frontmatter-only edit. Narrow it to the body and
      point at the owning requirement. This is an edit, not the no-op an
      earlier draft of this task predicted.
- [ ] 5.3 Propose the follow-on block-updating change so the three projects
      on `v1` have a named path forward. Propose only — implementing it is
      out of this change's scope.
