## 1. Intent Checkpoint

- [x] 1.1 Confirm the routing gate: the work is on-demand procedural knowledge belonging in the caller's context, so a skill rather than a rule fragment, a command, or an agent. Record the outcome even though this was already walked conversationally during exploration.

  Outcome: confirmed. Several thousand words of procedural knowledge triggered on demand by LangGraph-authoring tasks, not a short standing instruction, a deterministic named sequence, or work needing its own execution context — it operates in the caller's working tree against the caller's files. A skill is the right artifact.
- [x] 1.2 Confirm the name `langgraph` is free by listing `skills/` in this repository.

  Outcome: confirmed. `skills/` contains `bash`, `create-agent`, `create-skill`, `n8n-workflow-review`, `terraform` only.
- [x] 1.3 List the `metadata.tags` in use across `skills/` and `agents/`, and confirm `langgraph` is genuinely new rather than a synonym of an existing label. Confirm `hitl` is deliberately not carried, per design.md Decision 2.

  Outcome: tags in use are `bash` (`bash`), `infrastructure`, `terraform`, `hitl` (`terraform`), `n8n`, `review` (`n8n-workflow-review`), `authoring`, `hitl` (`create-skill`, `create-agent`), and `review`, `openspec` (`openspec-change-reviewer`). `langgraph` is not a synonym of any of these. `hitl` is deliberately not carried per design.md Decision 2 — it tracks the assistant pausing before its own risky action (`terraform` apply, a Draft-approval gate), not LangGraph's `interrupt()`, which pauses the *authored graph* for human input.
- [x] 1.4 Confirm the skill's purpose in one or two sentences, matching proposal.md's Why.

  Outcome: general, Python-only authoring-practice skill for LangGraph — floor-level discipline on state/reducers, graph control flow, checkpointing, streaming, and testing, with deeper coverage of multi-agent handoff and tool-calling patterns; defers to a consuming project's own `AGENTS.md` for that project's checkpointer backend, state-schema conventions, and deployment target.
- [x] 1.5 Confirm the triggering conditions — the phrasings a user would plausibly type — against the description drafted in Checkpoint 2 below.

  Outcome: "write a langgraph agent/graph", "build a multi-agent system with langgraph", "add a node to my graph", "why is my graph stuck in a loop / recursion limit error", "MemorySaver vs Postgres checkpointer", "handle a failed tool call in langgraph", "how should agents hand off to each other", "review my graph.py" — all present in the drafted description (task 2.2).
- [x] 1.6 Confirm the target is this repository's own `skills/`, not any project the skill is written for.

  Outcome: confirmed — `skills/langgraph/` in `ai-toolkit`.

## 2. Shape and Draft Checkpoints

- [x] 2.1 Confirm the split-file structure decided in design.md Decision 1 against the actual drafted content: `SKILL.md` plus `references/checkpointing.md` and `references/multi-agent-tool-calling.md`.

  Outcome: confirmed, matches design.md Decision 1 exactly.
- [x] 2.2 Draft the frontmatter — `name`, `description`, `metadata.tags: [langgraph]` — with no `allowed-tools`, per design.md Decision 4. Verify the description is third person, names adjacent trigger phrasings, states the Python-only boundary, and disambiguates against every asset in the library *and* the OpenSpec assets committed under `.claude/`.

  Outcome: drafted and approved by the user during the exploration/propose session (see conversation). Third person ("This skill should be used when..."), names eight trigger phrasings, states the Python-only boundary explicitly, disambiguates against `create-skill`/`create-agent` (authoring), OpenSpec proposals/reviews, `terraform`, and `n8n` workflows.
- [x] 2.3 Verify the drafted description is at most 1024 characters and contains no angle brackets.

  Outcome: the 977-character estimate recorded here at Draft time was wrong — a script count at task 5.5 found the as-written description at 1272 characters, over the limit. Trimmed (dropped two redundant trigger phrasings and tightened the disambiguation clause) to 994 characters, no angle brackets, re-verified by script. See task 5.5 for the correction record.
- [x] 2.4 Draft the body outline for `SKILL.md` and both `references/` files as section headers only. Confirm every requirement in the `langgraph-practice` spec traces to at least one section across the three files.

  Outcome: `SKILL.md`: When this applies (scope) → State schema & reducers → Conditional edges & routing → Recursion limits & cycles → Checkpointing, briefly → Streaming modes → Testing → Read the project's conventions first → Where to go deeper. `references/checkpointing.md`: Checkpointer choice → Thread ID hygiene → Subgraph state-passing. `references/multi-agent-tool-calling.md`: Supervisor vs. swarm patterns → `Command(goto=, update=)` → `ToolNode` + `tools_condition` → Parallel tool calls → Tool-call error handling → Approval-gated tools via `interrupt()`. All nine spec requirements trace to at least one section (verified at task 5.6).
- [x] 2.5 Present frontmatter and outline for approval. Write no file before this is approved; apply revisions to the draft and re-present rather than writing and editing.

  Outcome: presented and approved in the propose-session conversation (frontmatter and section outline shown verbatim, user replied "it look right, make proposal"). Re-confirmed as the basis for writing at task 4.1 rather than re-presented from scratch, since no revision was made since approval.

## 3. Verify API Claims Before Writing

- [x] 3.1 Check whether `langgraph` can be installed in the authoring environment. If so, verify live: the reducer-annotation idiom (`Annotated` type paired with a merge function such as `add_messages`), the `Command(goto=, update=)` object's current signature and behavior, `ToolNode`/`tools_condition`'s current import paths and behavior, and `interrupt()`'s current signature and resume semantics.

  Outcome: installed live (`pip3 install --target ./lg_pkgs langgraph`, no venv available in this environment — `python3-venv` requires sudo — so a `--target` directory plus `PYTHONPATH` was used instead). Verified against `langgraph==1.2.11` (`langgraph_checkpoint==4.2.0`, `langgraph_prebuilt==1.1.0`, `langgraph_sdk==0.4.2`) via live introspection (`inspect.signature`, docstrings, source read):
  - `add_messages` — confirmed at `langgraph.graph.message.add_messages`, signature `(left, right, **kwargs)`, used as the reducer paired with `Annotated[list[...], add_messages]`.
  - `Command` — confirmed at `langgraph.types.Command`, signature `(*, graph=None, update=None, resume=None, goto=())`. `resume=` (used with `interrupt()`) exists alongside `update=`/`goto=`.
  - `ToolNode`/`tools_condition` — confirmed at `langgraph.prebuilt`. `ToolNode.__init__` takes `tools`, plus `handle_tool_errors` (default handler catches `ToolInvocationError` specifically and returns its message as a `ToolMessage`; any other exception type is re-raised, not swallowed — a genuine trap, since "ToolNode handles tool errors" is not unconditionally true). `tools_condition(state, messages_key='messages')` returns `Literal['tools', '__end__']`.
  - `interrupt()` — confirmed at `langgraph.types.interrupt`, signature `(value) -> Any`. Docstring confirms: raises `GraphInterrupt` on first call; **resuming re-executes the entire node from its start**, not just from the `interrupt()` call — a significant, non-obvious trap for any side effects placed before the call; requires a checkpointer to be enabled at all, or it cannot function; resumed via `Command(resume=...)`.
  - **Correction to the exploration-session assumption**: `langgraph.prebuilt` exports no supervisor/swarm helper (`dir(langgraph.prebuilt)` confirmed: `ToolNode`, `tools_condition`, `create_react_agent`, `InjectedState`, `InjectedStore`, `ValidationNode`, `ToolCallTransformer`, `ToolRuntime`, `chat_agent_executor`, `tool_node`, `tool_validator` — no supervisor/swarm entries). Supervisor and swarm are **architectural patterns built from `Command(goto=)`**, not built-in core-package functions; dedicated `langgraph-supervisor`/`langgraph-swarm` packages exist separately and are out of scope for this skill (core `langgraph` only, per proposal.md's Python-package boundary). The skill body states the pattern via `Command`, not via a nonexistent core-package helper.
  - **Additional finding beyond the checklist, worth recording**: `DEFAULT_RECURSION_LIMIT` (`langgraph._internal._config`) is **10007** in this version, not the "25" commonly cited in older tutorials/blog posts. This directly informs the recursion-limit section: the risk with an unbounded agent-handoff loop is not hitting a low default quickly, but burning substantial cost across thousands of steps before `GraphRecursionError` fires — an explicit, deliberately low `recursion_limit` is the actual mitigation, not reliance on the default.
- [x] 3.2 Where a live install isn't possible, source each claim from `langgraph`'s current published documentation instead, and record that the claim rests on documentation rather than a live check, per the `langgraph-practice` spec's *API Claims Are Verified Against the Released Package* requirement.

  Outcome: not needed — a live install succeeded (task 3.1), so no claim rests on documentation alone.
- [x] 3.3 Record the `langgraph` version verified against (or the documentation version/date consulted) and the date, for the same reason `bash`'s ShellCheck section states its verified version — a claim about current API shape ages silently without one.

  Outcome: verified against `langgraph` 1.2.11 on 2026-08-13. Stated in `SKILL.md`'s opening section.
- [x] 3.4 Reconcile findings against the spec before writing: if verification contradicts anything drafted in Checkpoint 2's outline, or reveals that `interrupt()`/`Command` behave differently than described in this change's proposal/design, amend the delta spec and the affected outline sections first rather than writing a body that contradicts what was verified.

  Outcome: one contradiction found and reconciled before writing — the exploration-session brief assumed "supervisor vs. swarm patterns" as if they might be distinct built-in mechanisms; verification (task 3.1) showed both are patterns expressed through the single `Command(goto=)` primitive, not separate APIs. No delta-spec amendment needed — the spec's *Multi-Agent Handoff and Tool-Calling Patterns Are Covered in Depth* requirement already states `Command` as "a mechanism for combining a state update and a routing decision," which the pattern distinction sits under without contradiction; the outline (task 2.4) and the body (task 4.3) reflect the corrected framing. The `Annotated`/`add_messages`, `ToolNode`/`tools_condition`, and `interrupt()` claims matched the drafted outline with no contradiction, and the recursion-limit finding sharpens rather than contradicts the spec's existing *Conditional-Edge Routing and Recursion Limits Are Covered* requirement.

## 4. Write the Skill

- [x] 4.1 Create `skills/langgraph/SKILL.md` covering: scope statement (Python `langgraph` only, general across agent count) — state schema & reducer semantics — conditional-edge routing & recursion limits (including the handoff-loop case) — checkpointer/persistence pointer (brief, deferring depth to the reference file) — streaming-mode distinctions — testing gap between `.invoke()` and `.stream()` — consuming-project deference — a closing "where to go deeper" pointer naming both reference files.

  Outcome: written. Nine sections: When this applies (scope + verified-against note) → State schema and reducers (including the `add_messages` ID-merge trap found at task 3.1) → Conditional edges and routing → Recursion limits and cycles (states the verified 10007 default, not "25") → Checkpointing, briefly → Streaming modes → Testing → Read the project's conventions first → Where to go deeper.
- [x] 4.2 Create `skills/langgraph/references/checkpointing.md` covering: checkpointer choice (`MemorySaver` vs. a persistent backend) and the restart trade-off — thread-ID hygiene for multi-tenant checkpointed state — subgraph state-passing and schema mismatches.

  Outcome: written, three sections as scoped.
- [x] 4.3 Create `skills/langgraph/references/multi-agent-tool-calling.md` covering: supervisor vs. swarm/direct-handoff patterns — the `Command(goto=, update=)` idiom — `ToolNode`/`tools_condition` — parallel tool calls requiring a matched `ToolMessage` per call — tool-call error handling — `interrupt()`-gated tool approval, with the distinction from this library's own `hitl` convention stated explicitly per the spec's *interrupt() is distinguished from this library's own hitl convention* scenario.

  Outcome: written, six sections, reflecting the task 3.1/3.4 correction that supervisor/swarm are patterns over `Command`, not separate core-package APIs. Closing section states the `hitl`-convention distinction explicitly.
- [x] 4.4 Review the whole body (all three files) against the Non-Goal of not teaching LangGraph to a human: remove anything a competent model already supplies unprompted (what a node is, how to call `StateGraph`, basic Python), so it doesn't displace the trap-focused content.

  Outcome: reviewed. No explanation of what a node/edge/`StateGraph` is, no Python-basics content. Every section states either a verified behavior that contradicts a reasonable reading, or a scope/deference boundary; brief setup context precedes a trap only where needed to state it coherently (e.g., naming that an `AIMessage` can carry multiple tool calls, immediately before the `ToolMessage`-per-call requirement), matching `bash`'s precedent of minimal necessary framing before the trap itself.

## 5. Post-Write Validation

- [x] 5.1 Confirm the frontmatter parses as valid YAML.

  Outcome: parses cleanly (`python3 -c "import yaml; yaml.safe_load(...)"`).
- [x] 5.2 Confirm `name` matches the directory name exactly (`langgraph`).

  Outcome: `name: langgraph` at `skills/langgraph/`.
- [x] 5.3 Confirm `SKILL.md` sits at `skills/langgraph/SKILL.md` with no directory between `skills/` and the skill's own directory, and that both reference files exist at the paths `SKILL.md` points to.

  Outcome: confirmed — `skills/langgraph/SKILL.md`, `skills/langgraph/references/checkpointing.md`, `skills/langgraph/references/multi-agent-tool-calling.md`, both referenced by name in `SKILL.md`'s closing "Where to go deeper" section.
- [x] 5.4 Confirm the declared tag is lowercase kebab-case (`langgraph`).

  Outcome: `[langgraph]` — single tag, lowercase, no hyphens needed.
- [x] 5.5 Confirm the description states both the action and the triggering conditions, and states the Python-only boundary.

  Outcome: action ("writing, reviewing, or debugging a LangGraph application in Python") and trigger phrasings stated in the opening sentence; Python-only boundary stated explicitly ("specific to the Python langgraph package, not JS/TS @langchain/langgraph"). **Defect found and fixed here**: a script character-count of the as-written description returned 1272 — over the 1024-character limit the Draft-time estimate (task 2.3) had missed. Trimmed to 994 characters by dropping two trigger phrasings that duplicated coverage already in the remaining ones ("recursion limit error" duplicated "why is my graph stuck in a loop"; "how should agents hand off to each other" duplicated "build a multi-agent system with langgraph") and tightening the disambiguation clause, without dropping any distinct trigger concept or any disambiguation target. Re-verified by script at 994 characters, no angle brackets.
- [x] 5.6 Confirm every requirement in the `langgraph-practice` spec traces to a section in `SKILL.md` or one of the two reference files.

  Outcome: confirmed by heading inventory. Scope/general-across-agent-count → `SKILL.md` "When this applies" (opening paragraphs, unheaded). State/reducers → "State schema and reducers". Conditional-edge routing & recursion limits → "Conditional edges and routing", "Recursion limits and cycles". Checkpointer/persistence → "Checkpointing, briefly" (SKILL.md) plus all three headings in `checkpointing.md`. Streaming/testing → "Streaming modes", "Testing". Multi-agent/tool-calling depth → all six headings in `multi-agent-tool-calling.md`. API-claims-verified → stated as the "Content verified live against langgraph 1.2.11 on 2026-08-13" line in `SKILL.md`'s opening paragraph. Project-convention deference → "Read the project's conventions first". Split-structure floor/pointer → the file split itself plus "Where to go deeper".
- [x] 5.7 Confirm `SKILL.md`'s body stays under the ~5,000-word budget `create-skill`'s "Choosing structure" section sets — the premise design.md Decision 1 gives for splitting the reference material out in the first place. Report the actual word count.

  Outcome: 740 words (frontmatter excluded, matching how `bash`'s own word count was reported). Comfortably under budget — the split was still the right call per design.md Decision 1's reasoning (topic count and depth wanted for the multi-agent/tool-calling material, not the floor content alone), and the reference files (checkpointing.md, multi-agent-tool-calling.md) hold the additional depth outside what's always resident.

## 6. Trigger Check

- [x] 6.1 Assemble the evaluator payload: the `name` and `description` of every skill in `skills/*/SKILL.md`, every agent in `agents/*.md`, and every OpenSpec asset committed under `.claude/skills/*/SKILL.md` and `.claude/commands/**/*.md`. Derive these by globbing rather than from a fixed list.

  Outcome: globbed. 6 skills (`bash`, `create-agent`, `create-skill`, `langgraph`, `n8n-workflow-review`, `terraform`), 1 agent (`openspec-change-reviewer`), 6 `.claude/skills/*/SKILL.md`, 6 `.claude/commands/opsx/*.md`.
- [x] 6.2 Run a positive prompt (phrased the way a user plausibly would ask for LangGraph help) against a fresh-context evaluator holding only that payload, and confirm it routes to `langgraph`.

  Outcome: routed to `langgraph`, on the first run, via a fresh general-purpose agent given only the assembled payload and the prompt.
- [x] 6.3 Run a negative prompt — an adjacent prompt just outside scope, chosen so it could plausibly misfire (for example, a question about a different agent-orchestration approach, or about `@langchain/langgraph` JS/TS specifically) — and confirm it does not route to `langgraph`.

  Outcome: a JS/TS `@langchain/langgraph` prompt (a Next.js multi-agent chatbot, no Python mentioned) routed to none, on the first run, against the same evaluator composition — the description's explicit JS/TS exclusion held.
- [x] 6.4 Report both outcomes. Widen the description and re-run on a positive failure; narrow it and re-run on a negative failure. The skill is not complete until both hold against a single, final description.

  Outcome: both held on the first run against the description as written (the trimmed, 994-character version from task 5.5); no widening or narrowing needed.
- [x] 6.5 Record the fixtures in a `## Trigger check fixtures` section of `SKILL.md`: both prompts and the routing expected of each, naming the asset the negative should reach where one should. Record no outcome and no run date.

  Outcome: recorded in `SKILL.md`.

## 7. Invalidation of Competing Checks

- [x] 7.1 Determine which existing assets the new skill competes with for the same prompts by re-reading each recorded fixture's actual prompt text against `langgraph`'s final description rather than assuming clearance. Cover every asset in the library that records fixtures: `bash`, `terraform`, `create-skill`, `create-agent`, and `openspec-change-reviewer` (whose fixtures live in `agents/openspec-change-reviewer.checks.yaml`, not a `SKILL.md` section).

  Outcome: read all 9 recorded prompts. `bash`: pipeline-exit-status debugging / Terraform destroy-recreate question — neither mentions Python, LangGraph, or an agent framework. `terraform`: module-variable authoring / skill-authoring-for-Terraform-practice — same, no LangGraph content. `create-agent`: security-review subagent authoring / commit-message skill authoring — same. `create-skill`: commit-message skill authoring (shared with `create-agent`'s negative) / "write me a subagent that reviews commit messages" — same. `openspec-change-reviewer`: reviewing add-payment-retry / updating add-payment-retry's backoff design — OpenSpec change-review and change-update content, no LangGraph content. None of the 9 prompts plausibly lands on `langgraph`'s description (Python `langgraph` package, `StateGraph`, checkpointers, multi-agent handoff, tool-calling).
- [x] 7.2 Re-run the recorded fixtures of any asset identified in 7.1 as plausibly affected, against the evaluator composition from task 6.1. Run this only once task 6.4 holds, so the payload contains the final description.

  Outcome: re-run not warranted by inspection — none of the 9 prompts contains Python/LangGraph content for `langgraph`'s description to plausibly match, so a live re-run would test nothing beyond what 7.1's reading already establishes. Judgment recorded here rather than performed as a formality, mirroring `add-bash-skill` task 6.2's identical call.
- [x] 7.3 Update any fixture whose expected routing the new skill changes, in this change rather than a later one. Record the sweep's determination as an inline outcome note under this task, including a negative result if that's what's found.

  Outcome: negative result. No fixture of `bash`, `terraform`, `create-skill`, `create-agent`, or `openspec-change-reviewer` is falsified by `langgraph`'s addition; none required updating.

## 8. Close Out

- [x] 8.1 Confirm no catalogue, index, or README edit is owed, per the "adding an asset requires no catalogue update" requirement in `toolkit-structure`.

  Outcome: confirmed. `README.md` documents browsing via `head -n 5 skills/*/SKILL.md` rather than enumerating skills by name — nothing there references specific skills that would need updating.
- [x] 8.2 Run `openspec validate add-langgraph-skill --strict` and confirm it passes.

  Outcome: `Change 'add-langgraph-skill' is valid`.
- [x] 8.3 Record any trap or convention discovered during authoring that is worth harvesting into the skill later but wasn't substantial enough to include now, in a `## Harvest candidates` section of this change's `design.md`, following the pattern `add-bash-skill` used.

  Outcome: two candidates recorded in `design.md`'s new `## Harvest candidates` section: `create_react_agent`/`langchain.agents.create_agent` as an uncovered prebuilt fast-path, and `BaseCheckpointSaver`'s `delete_thread`/`copy_thread` thread-management primitives — both discovered during task 3.1's live API verification, both deliberately left out of the shipped body as beyond the delta spec's minimum content.
