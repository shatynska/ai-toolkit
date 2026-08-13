## 1. Intent Checkpoint

- [x] 1.1 Confirm the routing gate: the work is on-demand procedural knowledge belonging in the caller's context, so a skill rather than a rule fragment, a command, or an agent. Record the outcome even though this was already walked conversationally during exploration.

  Outcome: confirmed. General Python-authoring traps triggered on demand by Python-authoring/review tasks, not a short standing instruction, a deterministic named sequence, or work needing its own execution context — a skill is the right artifact.
- [x] 1.2 Confirm the name `python` is free by listing `skills/` in this repository.

  Outcome: confirmed. `skills/` contains `bash`, `create-agent`, `create-skill`, `langgraph`, `n8n-workflow-review`, `terraform` only.
- [x] 1.3 List the `metadata.tags` in use across `skills/` and `agents/`, and confirm `python` is genuinely new rather than a synonym of an existing label.

  Outcome: tags in use are `langgraph`, `bash`, `authoring`, `hitl` (x2, `create-skill`/`create-agent`), `n8n`, `review` (x2), `infrastructure`, `terraform`, `openspec`. `python` is not a synonym of any of these.
- [x] 1.4 Confirm the skill's purpose in one or two sentences, matching proposal.md's Why.

  Outcome: general-purpose Python authoring-practice skill — floor-level traps in mutability/aliasing, scoping/closures, identity/equality, exception handling, and iterator/generator semantics, with `references/` covering concurrency, imports/module-state, typing/tooling, and datetime/numerics; defers to a consuming project's own `AGENTS.md`, and cross-references `langgraph` for LangGraph-specific material.
- [x] 1.5 Confirm the triggering conditions — the phrasings a user would plausibly type — against the description drafted in Checkpoint 2 below. Explicitly check overlap against `langgraph`'s recorded trigger fixtures.

  Outcome: confirmed at task 2.3/6.1 below (description drafted, then trigger-checked against `langgraph`'s fixtures).
- [x] 1.6 Confirm the target is this repository's own `skills/`, not any project the skill is written for.

  Outcome: confirmed — `skills/python/` in `ai-toolkit`.

## 2. Shape and Draft Checkpoints

- [x] 2.1 Draft the outline for `SKILL.md` and the four candidate `references/` files (`concurrency.md`, `imports-and-state.md`, `typing-and-tooling.md`, `datetime-and-numerics.md`) as section headers only, with a rough word-count projection per section. Confirm every requirement in the `python-practice` spec traces to at least one section across the files.

  Outcome: drafted and presented in the apply-session conversation — SKILL.md: Scope → Mutability & aliasing → Scoping & closures → Identity & equality → Exceptions → Iterators & generators → LangGraph cross-reference → Read the project's conventions first → Where to go deeper (~2,100 words projected); four references at ~400-600 words each. All 8 `python-practice` requirements traced to at least one section (re-confirmed against the actual written files at task 4.6).
- [x] 2.2 Check the word-count projection from 2.1 against design.md's Decision 1 and the Risks section's open question about it. If the floor projects comfortably under a single readable pass without the split, or if any one `references/` file projects too thin to justify its own file, revise the structure (collapse into `SKILL.md`, or merge reference files) and update design.md's Decision 1 to record the correction before proceeding.

  Outcome: projected combined total (~4,000 words) would exceed a comfortable single-pass flat file if merged, and no single reference file projected too thin to justify its own file — confirmed the pre-split structure from design.md Decision 1 without revision. Actual written word counts (task 5.3: 3,401 words total) confirmed this projection was directionally correct.
- [x] 2.3 Draft the frontmatter — `name`, `description`, `metadata.tags: [python]` — with no `allowed-tools`. Verify the description is third person, names adjacent trigger phrasings, states the general-purpose (not project-shape-scoped) boundary, names the `langgraph` cross-reference, and disambiguates against every asset in the library *and* the OpenSpec assets committed under `.claude/`.

  Outcome: drafted (third person, trigger phrasings for review/debug/lint, general "any task touching a .py file" scope, explicit `langgraph` cross-reference, explicit disambiguation against library-asset authoring/OpenSpec/Terraform/bash/n8n). Full library-wide disambiguation (including `.claude/` assets) exercised at tasks 5.2/6.2's trigger sweeps rather than asserted here.
- [x] 2.4 Verify the drafted description is at most 1024 characters and contains no angle brackets.

  Outcome: verified via script at draft time: 1,005 characters, no angle brackets. Re-confirmed programmatically at task 5.1 against the final written file (unchanged since draft).
- [x] 2.5 Present frontmatter and outline for approval. Write no file before this is approved; apply revisions to the draft and re-present rather than writing and editing.

  Outcome: presented in the apply-session conversation; user replied "ok". No file was written before this approval.

## 3. Verify Version-Dependent Claims Before Writing

- [x] 3.1 Check whether a Python interpreter is available in the authoring environment. If so, verify live: the CPython small-integer interning range (commonly cited as -5 to 256; confirm against the actual running version via `is`-comparison probing, e.g. `sys.intern` behavior and integer identity checks across the boundary) and short-string interning behavior.

  Outcome: verified live against CPython 3.12.3. Small-integer caching confirmed exactly at -5..256 inclusive: for each of -6, -5, 0, 100, 256, 257, 300, constructed a fresh object via `int(str(n))` and compared with `is` against the literal — True for -5, 0, 100, 256; False for -6, 257, 300. String interning: two identical string literals in the same module are the same object (`is` True, compile-time constant folding); the same value built at runtime via `"".join(...)` is a different object (`is` False) for a short lowercase word, demonstrating the same illusion applies to strings, not just ints.
- [x] 3.2 Check whether `ruff` and `mypy` are available in the authoring environment. If so, verify live which of this skill's core traps each catches by default: mutable default argument (expected `ruff` rule B006), `is` comparison against a literal (expected `ruff` rule F632), and confirm that late-binding closures in loops, `return`-in-`finally` masking exceptions, and `__exit__` swallowing exceptions on a truthy return are *not* caught by either tool's default configuration, by writing a minimal reproduction of each and running the tool against it.

  Outcome: neither tool was pre-installed; installed both via `pip3 install --break-system-packages --target <scratch>/py_pkgs ruff mypy` (no system-wide `python3-venv` available, same constraint `add-langgraph-skill` hit). Verified against `ruff 0.16.3` and `mypy 2.3.0` with a minimal reproduction file per trap, run with zero project config (`ruff check --isolated`, confirmed identical from a clean directory with no `pyproject.toml`/`ruff.toml` anywhere on the path).

  **Correction to the drafted assumption**: ruff 0.16.3's actual default rule set (zero config) is substantially broader than the "E4/E7/E9/F only" reputation carried into this change from training-data familiarity — it already includes flake8-bugbear (B), flake8-bandit (S), flake8-blind-except (BLE), and a slice of Pylint (PL) rules by default. Concretely, **caught by default**: `B006` mutable default argument, `F632` `is`-vs-literal, `RUF012` mutable class attribute default, `B023` late-binding closure in a loop ("function definition does not bind loop variable"), `B012` `return` inside `finally` silencing an exception, `BLE001`+`S110` a bare/broad `except Exception: pass`, and `PLW0177` comparing against a literal `float("nan")`. **Not caught by default**: `__exit__` returning `True` and swallowing the triggering exception, aliasing vs. copying (mutating a list through a second reference to the same object), mutating a list while iterating over it, generator single-use exhaustion, and general float-equality comparison (`a + 0.1 == b`) that doesn't syntactically match the `float("nan")` literal pattern `PLW0177` looks for. `mypy 2.3.0` caught none of the core traps directly — its one finding across all ten reproductions was a `var-annotated` hint on the empty-list class attribute, not the mutability trap itself; mypy's contribution to this skill's completion discipline is minor compared to ruff's.
- [x] 3.3 Where a live install isn't possible for either 3.1 or 3.2, source each claim from CPython's or the tool's own current published documentation instead, and record that the claim rests on documentation rather than a live check, per the `python-practice` spec's *Version-Dependent Claims Are Verified Against a Live Interpreter and Tooling* requirement.

  Outcome: not needed — live verification succeeded for both 3.1 and 3.2.
- [x] 3.4 Record the CPython version and `ruff`/`mypy` versions verified against (or the documentation version/date consulted) and the date, for the same reason `bash`'s ShellCheck section and `langgraph`'s API section each state their verified version.

  Outcome: verified against CPython 3.12.3, `ruff` 0.16.3, `mypy` 2.3.0, on 2026-08-13. Stated in `SKILL.md`'s opening section and in `references/typing-and-tooling.md`.
- [x] 3.5 Reconcile findings against the spec before writing: if verification contradicts anything drafted in Checkpoint 2's outline (for example, a trap turns out to be caught by default tooling when the outline assumed otherwise), amend the delta spec and the affected outline sections first rather than writing a body that contradicts what was verified.

  Outcome: contradiction found and reconciled before writing. `specs/python-practice/spec.md`'s *Tooling Is a Necessary But Not Sufficient Completion Check* requirement named late-binding closures and `return`-in-`finally` as examples of traps a default run misses — both are wrong per 3.2's live finding (both are caught by `ruff` 0.16.3 default). Amended the requirement's example list to the corrected caught/not-caught split (see spec diff in this commit). `design.md`'s Decision 2 carried the same wrong examples and was amended identically. No other drafted content contradicted verification.

## 4. Write

- [x] 4.1 Write `skills/python/SKILL.md`: frontmatter (per 2.3, as revised by approval), general-purpose scope statement, the core-traps floor (mutability/aliasing, scoping/closures, identity/equality, exception handling, iterator/generator semantics), the `langgraph` cross-reference, the consuming-project-conventions deference section, and a closing pointer naming each `references/` file and what it covers.

  Outcome: written, 1,406 words.
- [x] 4.2 Write `skills/python/references/concurrency.md`: GIL false-safety, forgotten `await`, blocking an event loop with a synchronous call.

  Outcome: written, 448 words. Forgotten-`await` behavior verified live (produces a `RuntimeWarning`, not an error, and the coroutine body never executes).
- [x] 4.3 Write `skills/python/references/imports-and-state.md`: circular imports, module-level mutable state as a hidden global.

  Outcome: written, 471 words. Circular-import failure mode and exact error message verified live with a two-module reproduction.
- [x] 4.4 Write `skills/python/references/typing-and-tooling.md`: the `ruff`/`mypy` necessary-but-not-sufficient completion discipline, stating the verified caught-vs-missed split from task 3.2.

  Outcome: written, 679 words, with the corrected caught/missed table from task 3.2's finding.
- [x] 4.5 Write `skills/python/references/datetime-and-numerics.md`: naive vs. aware `datetime`, float vs. `Decimal` for money.

  Outcome: written, 397 words. Naive/aware `TypeError` message, `0.1 + 0.2` imprecision, and `Decimal(0.1)` inheriting float imprecision all verified live.
- [x] 4.6 Cross-check every requirement and scenario in `specs/python-practice/spec.md` against the written files; note any gap and close it before proceeding.

  Outcome: all 8 requirements trace to written content — general-purpose scope statement (SKILL.md opening), all 11 minimum-list core traps (SKILL.md body), pre-split structure with closing pointer (SKILL.md + 4 reference files), corrected tooling caught/missed split (typing-and-tooling.md), LangGraph cross-reference with "traps still apply" scenario (SKILL.md "LangGraph-specific work"), verified-version statements (SKILL.md opening + typing-and-tooling.md), and project-convention deference with both the conflict-reporting and absent-convention-question scenarios (SKILL.md "Read the project's conventions first"). No gap found.

## 5. Verify Against `create-skill`'s Standard

- [x] 5.1 Run `create-skill`'s frontmatter and description checklist against the written `SKILL.md`.

  Outcome: verified programmatically. Frontmatter is valid YAML with only the allowed top-level keys (`name`, `description`, `metadata`); `name: python` matches the `skills/python/` directory; `metadata.tags: [python]` is lowercase kebab-case; description is 1,005 characters (≤1024) with no angle brackets; no `allowed-tools` (correctly omitted — not a single-command wrapper); all four `references/` files named in "Where to go deeper" exist on disk.
- [x] 5.2 Run any cold-run / trigger-check fixtures `create-skill` requires, recording the fixture prompts and results (mirroring `langgraph`'s task 5.5-style correction record if a drafted estimate turns out wrong under an actual check).

  Outcome: ran via a fresh-context evaluator agent (no access to this authoring conversation) holding the `name`/`description` of every skill and agent in `skills/`/`agents/` plus every `.claude/skills/*` and `.claude/commands/**` entry. Positive prompt ("review this Python function... subtle bug in how I'm handling the default argument") routed to `python`. Negative prompt ("build a LangGraph agent in Python that routes between two tools and hands off state") routed to `langgraph`, not `python` — confirming the cross-reference boundary (design.md Decision 4) holds. Both outcomes as expected; description not revised. Fixtures recorded in `SKILL.md`'s own `## Trigger check fixtures` section (prompts and expected routing only, no outcome/date, per `create-skill`'s recording rule).
- [x] 5.3 Confirm word counts for `SKILL.md` and each `references/` file are within a single readable pass, per `create-skill`'s "Choosing structure" guidance.

  Outcome: `SKILL.md` 1,406 words; `references/concurrency.md` 448; `references/imports-and-state.md` 471; `references/typing-and-tooling.md` 679; `references/datetime-and-numerics.md` 397. All comfortably under the ~5,000-word single-document budget individually; combined (3,401 words total) would have exceeded a comfortable single-pass read if left flat, confirming design.md Decision 1's pre-split call was warranted rather than premature.

## 6. Trigger-Competition Sweep

- [x] 6.1 Re-run the recorded trigger-check fixtures for `langgraph` against the new `python` description (and vice versa), confirming the topic-based division from design.md Decision 4 holds — a general Python-review prompt should reach `python`, a LangGraph-specific prompt should reach `langgraph`, and a prompt spanning both should be able to reach both.

  Outcome: `langgraph`'s recorded positive fixture ("multi-agent LangGraph app in Python... recursion limit error") and negative fixture ("@langchain/langgraph JS SDK... how should I structure the handoffs") both name no content `python`'s description would plausibly compete for — `python` explicitly excludes LangGraph specifics and the JS/TS SDK is outside both skills. Task 5.2's own negative prompt is functionally the reverse check (a LangGraph-Python prompt correctly skipping `python` for `langgraph`). No invalidation found.
- [x] 6.2 Re-run the recorded trigger-check fixtures for `bash`, `terraform`, `create-skill`, `create-agent`, `n8n-workflow-review`, and `openspec-change-reviewer` against the new `python` description. Record the outcome for each even if no conflict is expected, per proposal.md's Impact section.

  Outcome: ran an 8-prompt sweep via a fresh-context evaluator agent (same asset roster as 5.2), covering a `python`-positive script-writing prompt, an authoring-a-skill-about-Python prompt (→ `create-skill`, not `python`), a Terraform apply/plan prompt (→ `terraform`), an n8n workflow review prompt (→ `n8n-workflow-review`), a build-a-subagent-that-reviews-Python prompt (→ `create-agent`, not `python`), an OpenSpec change-review prompt (→ `openspec-change-reviewer`), a bash deploy-script prompt (→ `bash`), and a second `python`-positive trap-specific prompt (comprehension scoping). All 8 routed to the expected asset with no misfire onto or away from `python`. None of `bash`'s, `terraform`'s, `create-skill`'s, `create-agent`'s, `n8n-workflow-review`'s, or `openspec-change-reviewer`'s own recorded fixtures name Python content `python` would compete for.
- [x] 6.3 Update any fixture found invalidated by 6.1 or 6.2 as part of this change.

  Outcome: none invalidated — no update needed.

## 7. Close Out

- [x] 7.1 Validate the change: `openspec validate --change "add-python-skill" --strict` (adjust flag to the CLI's actual validate invocation for a named change).

  Outcome: `openspec validate add-python-skill --strict` → "Change 'add-python-skill' is valid".
- [x] 7.2 Record any harvest candidates — content considered but deliberately deferred (e.g., a specific `asyncio` pattern, a packaging-tool comparison) — in design.md's Harvest candidates section, per this repository's established close-out convention, rather than silently dropping them.

  Outcome: three candidates recorded — `dataclasses`' loud (`ValueError`-at-class-definition) rejection of a mutable default field, contrasted with the shipped silent-sharing function/class-attribute trap; `unittest.mock.patch`'s "patch where it's used" rule, deferred because this skill has no testing section; `contextlib.suppress` as the deliberate counterpart to the accidental `__exit__`-swallowing trap.
- [x] 7.3 Summarize the finished skill for the user: files written, word counts, verified versions, and the trigger-competition sweep outcome.

  Outcome: see final chat summary.
