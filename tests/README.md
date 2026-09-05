# tests/

Exercises `scripts/project-init` — the repository's only executable and the first thing in this library verified by running code rather than by review.

## Why these cases are written directly, not dispatched

The development workflow this change ships requires tests be derived from a change's specification by an independent author (`ai-toolkit:change-test-writer`) before implementation. This suite does not follow that path. The agent's dispatch contract requires a test command and a test-path glob as essential inputs — and neither exists until this harness creates them. Deriving this suite's own tests from a dispatch that needs this suite to already exist is circular, the same structural bootstrap problem `rules/project-foundation.md` records for the foundation change's test-authoring exemption. This is recorded as a stated exemption for this one suite, not a precedent: the very next change to this repository has a real test command (`bash tests/run.sh`) and a real test-path glob (`tests/cases/**`), and `change-test-writer` applies normally to it.

## The exemption's second use, and why

`revise-development-workflow` added three cases to this suite (`fragment-role-before-tool.sh`, `inlined-body-matches-fragment.sh`, and the `fragment_version` helper the version-coupled cases now use) without dispatching `ai-toolkit:change-test-writer`. That is a second stated exemption, recorded here rather than decided silently, because the paragraph above forecloses the silent option.

The reason is not the circularity that excused the first use — this suite has a real test command and a real test-path glob now. It is that the agent's own dispatch contract requires a change that "has passed review and is ready for implementation", and this change had no such verdict: its review returned `CHANGES REQUIRED` on its third round — the verdict set of the day, quoted as it was recorded — and implementation proceeded on the maintainer's explicit direction instead. Dispatching a test author against a plan no verdict had cleared is the precondition failure the workflow rules this very change introduces forbid. The exemption is therefore narrower than the first: it does not say test authoring was impossible, only that its stated precondition was not met, and it expires with the verdict.

What this costs is real and worth stating: these three cases were written by whoever wrote the change, so they carry that author's blind spots. Two are guarded against the usual failure of a test that cannot fail — each was run against a deliberately violating fixture and observed to fail, and each carries a vacuity guard that fails rather than passes when its extraction comes back empty.

## Running

```
bash tests/run.sh
```

Each file in `tests/cases/*.sh` runs as its own subprocess in a fresh `mktemp -d` temporary directory (`$TESTDIR`), so no case can observe another's filesystem state. `tests/lib.sh` supplies `assert_exit`, `assert_file`, `assert_file_absent`, `assert_unchanged`, and `assert_contains` — sourced via `$TESTLIB`, which `run.sh` exports. A failed assertion prints to stderr and exits the case non-zero immediately. `run.sh` itself exits non-zero if any case failed.

## The report contract

`scripts/project-init` prints a fixed, greppable report to stdout. Cases assert against these tokens, so the script and this suite must agree on them — this is the normative form, written before the script, and section 5 implements against it rather than inventing wording independently.

Each applicable line, in order:

```
Target: <absolute path>
repository: created | already present
specification tooling: created via `openspec init --tools <value>` | already present
ignore file: created | already present
conventions file: created with block (version N)
           | block appended (version N)
           | block already present (version N, matches)
           | block already present (existing version N, tool carries version M)
Import needed: add `@AGENTS.md` to CLAUDE.md for the rules to take effect   [only when CLAUDE.md does not already import AGENTS.md]
Outcome: SUCCESS | BLOCKED | ERROR
Reason: <text>   [BLOCKED or ERROR only]
Next step: foundation discovery — run /project-foundation to establish this project's foundation.   [new-project SUCCESS only]
Next step: none required — foundation discovery is available if you want to record this project's decisions; run /project-foundation.   [adoption SUCCESS only]
```

`Target:` is printed before any filesystem change, per the target-directory requirement. A `BLOCKED` outcome prints `Target:` and `Reason:` and nothing else that implies a change was made.

## CLI contract

```
project-init [--tools <value>] [--help|-h] [TARGET_DIR]
```

- No arguments: operates on the current working directory, `--tools` defaults to `claude`.
- `TARGET_DIR`: optional positional argument, initializes that directory instead of the current one.
- `--tools <value>`: passthrough to `openspec init --tools <value>`.
- `--help` / `-h`: prints usage covering modes, arguments, flags, outcomes, and exit codes; makes no filesystem change; exits 0.
- Exit codes: `0` SUCCESS, `1` ERROR, `2` BLOCKED.

See `coverage.md` for which specification scenario each case (or its absence) accounts for.
