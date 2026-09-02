# CLAUDE.md

Rules for this workspace. They override defaults.

## 1. Never decide alone

Ask the user with AskUserQuestion. Every time.

- Give options. Never one.
- Each option states the tradeoff and the benefit to the user.
- Step back first. Look at the whole picture, not the next line of code.

Ask before adding a dependency. Ask before changing the shape of a `forge.yaml`.
Ask before touching a shell rc file.

## 2. When you ask or present

- Give context first.
- Context is short, crisp, simple.
- Assume the reader knows nothing about the subject.
- Step back. Say why it matters before you say what it is.

## 3. Writing

Start with the conclusion. Then the reason. Nothing else.

Banned characters in all prose: parenthesis, dash, em dash, semicolon. Do not
swap a banned character for a comma. That is cheating. Split the sentence
instead.

Banned words: robust, seamless, leverage, comprehensive, powerful, simply,
just, basically, essentially, various, several, appropriate.

No passive voice. No intro. No summary. No apology.

Short words. Short sentences. Simple US English.

If text sits inside a parenthesis it is filler. Delete it.

## 4. Comments are banned

**Write zero comments. Ever.**

No line comments. No block comments. No doc comments. No module headers. No
section banners. No SAFETY notes. No TODO. No FIXME.

A comment is a confession that the code is unreadable. Fix the code.

- Rename the thing so the name is the comment.
- Extract a function so the signature is the comment.
- Name the test so the test is the comment.

A reason worth keeping goes in a test name or in `docs/`. Never in source.

Two exceptions. Generated files belong to their generator. License headers are
written by the license engine.

When you touch a file that has comments, delete them.

## 5. Architecture

Four layers. Knowledge flows one way.

```
main -> driver -> controller -> adapter
                       |            |
                       +--- types --+
```

| Layer | Job | Never |
|---|---|---|
| `main` | build adapters, inject into controllers, inject into drivers, start | hold logic |
| `driver` | take input, validate, call a controller | touch an adapter |
| `controller` | business logic, orchestrate adapters | touch a driver |
| `adapter` | talk to the outside world | hold logic |
| `types` | plain data | hold behaviour or traits |

Rules:

- Declare a trait in the module that implements it. Never in `types`. Never in
  a shared bag.
- Inject through the constructor. No globals. No service locator. No DI
  framework.
- An adapter never imports another adapter.
- Code is flat. Early return. Shallow nesting.
- `util` holds pure helpers. A util that grows logic becomes a controller. A
  util that does I/O becomes an adapter.

Generated code follows the same layering. A generated client is an adapter. A
generated server is a driver. **Generated wire types are not internal types.**
Map at the boundary or the generator's choices leak into controllers.

Read `opends-app` for the Rust shape. Read `golden-rust` for the layer split.
Ignore their comments. They predate this rule.

### Prove the architecture with tests

Do not trust review. Gate it.

| Test | What it blocks |
|---|---|
| `hack/architecture.sh 0` | a public function nobody calls |
| `hack/purity.sh` | I/O crates or `std::fs`, `std::net`, `std::process`, `Instant::now` in a pure crate |
| `hack/coverage.sh 95` | coverage below the floor |
| `hack/generated-check.sh` | committed generated code that drifted from its source |

Copy these from `opends-app` and `opends-core`.

## 6. Errors

Wrap every error with the action you were attempting. Present participle. Name
the identifier. No `error:` prefix.

- Library: `thiserror`. Nest the cause with `#[source]`.
- Binary: `anyhow`. Use `.with_context()`.

`thiserror` Display prints the outer message only. `main` must walk `.source()`
and join the chain. Copy `error_chain` from `golden-rust/src/bin/golden-rust.rs`.

Never swallow an error. Never panic on an expected failure.

## 7. Generated code

Most non business code is generated. Generation makes the output deterministic.

- Every generated file is named `zz_generated*`.
- Never hand edit one. Change the spec and regenerate.
- Exclude generated files from coverage and lint. Apply the exclusion in the
  generator, never in the output.
- Config is declared in `config/config.yaml`. The loader is generated. `main`
  only calls load.
- API code is generated from a spec in `api/`. The spec is the source of truth.
  Rust uses `openapi-generator` for client and server. `progenitor` cannot parse
  OpenAPI 3.1.
- Mocks come from `mockall`. Put `#[cfg_attr(test, mockall::automock)]` above
  the trait. It expands in place. There is no mock file and no mock directory.

Read `golden-spec/docs/openapi-matrix/divergences.md` before designing an API.
`format: int64` does not survive JSON in TypeScript. It travels as a string
everywhere.

## 8. Testing

Target near 100 percent coverage of hand written code. Generated files and mocks
do not count.

The layering makes this cheap.

- Test a controller with mocked adapter traits.
- Test a driver with mocked controller traits.
- Test an adapter against a fake or a container in an integration stage.

It builds is never done. A task is done when `forge test-all` passes.

## 9. Forge

Build and test only through forge. Never write a Makefile. Never write an ad hoc
script that forge should own.

```sh
forge build              # every artifact, lazy
forge test run <stage>   # one stage, verb before stage
forge test-all           # everything, fail fast
forge config validate    # check forge.yaml before trusting it
forge list               # what this repo can build and test
```

Forge runs as an MCP server with `forge --mcp`. Prefer the MCP tools when they
are available.

Every repo needs a `forge.yaml` and a `.envrc`. Forge sources `.envrc` and fails
without it. `.envrc` is generated by the factory and gitignored.

Rust has no native forge engine. Wrap cargo.

```yaml
test:
  - name: lint
    runner: forge://generic-test-runner
    spec:
      command: cargo
      args: ["clippy", "-p", "<crate>", "--all-targets", "--", "-D", "warnings"]
  - name: format-check
    runner: forge://generic-test-runner
    spec:
      command: cargo
      args: ["fmt", "-p", "<crate>", "--", "--check"]
  - name: unit
    runner: forge://generic-test-runner
    spec:
      command: cargo
      args: ["test", "-p", "<crate>"]
```

Scope clippy and fmt with `-p <crate>`. A workspace wide run drags generated
crates into the lint gate.

Windows builds are a `generic-builder` step targeting `x86_64-pc-windows-gnu`.
Copy the exe into `$WIN_OUTPUT_PATH`. Never use `go://go-build` for a Windows
target. It cross compiles its own dependency detector and fails.

## 10. Factory

The factory owns the workspace. One file lists every member and every version.

**A repo cannot be built alone.** `Cargo.toml`, `go.work`, every manifest and
every `.envrc` are generated and gitignored. A lone checkout has none of them.

- Edit workspace files only in the factory repo under `workspace/`.
- `forge clone <factory url> <dir>` stands the whole workspace up from nothing.
- `forge-factory sync` writes the manifests. `lock` resolves the dependency
  closure and is its own verb.
- Never hand write `Cargo.toml`, `go.work` or `.envrc`.
- A member with no language generates no manifest. Spec, state and register
  repos stay plain.

Dependencies live in `forge-factory.yaml` under `dependencies.rust`. A crate that
needs features carries a `wraps` inline table. `Cargo.toml` then says
`dep.workspace = true`.

## 11. CI

The pipeline is the CI. It lives in the factory repo.

- Member repos never build. They send `repository_dispatch` on push.
- `ci-trigger-watch` declares the watch list and the notify workflow together.
- Never hand write a workflow. Declare it in `forge-ci.yaml` and run
  `forge-ci apply`. A hand edit drifts back.
- Jobs run inside the toolchain container. CI installs nothing. The tag comes
  from `.forge/toolchain-image` and is typed nowhere.

Stage order:

1. `check` runs `forge config validate` in every member. A typo is reported
   where it was made.
2. `build` sets `sync: true` then runs the suites. `mint: true` here. A multi
   repo pipeline that never syncs is refused.
3. `publish` enters the register with the minted revision as provenance.

Mint after the gate. Minting first gives a broken build a revision that spreads.

There is no `self` stage. Apply converges itself.

Repos the pipeline writes stay out of the watch list. Watching them never
settles.

A repo must not track a file it also ignores. Such a repo never settles.

## 12. Repo layout

```
src/bin/<name>.rs
src/adapter/<name>_adapter.rs
src/controller/<name>_controller.rs
src/driver/<name>_driver.rs
src/types/<name>.rs
src/util/<name>.rs
api/<name>.<version>.yaml
config/config.yaml
hack/
docs/
forge.yaml
Cargo.toml
```

One repo per language and per domain. Keep repos small. Prefer more repos over
one large repo.

Specs live in a `-spec` repo. Consumers resolve them with `hack/resolve-spec.sh`
into `.forge/spec-cache`. Never copy a spec.

## 13. Workflow gates

Any non trivial goal follows three gates. Each one waits for user review.

1. `docs/<feature>/scope.md`. Problem, goals, non goals.
2. `docs/<feature>/design.md`. System design plus mermaid diagrams for design,
   data flow and sequence. Name every adapter, controller, driver and type.
3. `docs/<feature>/plan.yaml`. Tasks with `status: PLANNED | IMPLEMENTED |
   VERIFIED`.

`PLANNED` becomes `IMPLEMENTED` when code is written and `forge build` passes.
`IMPLEMENTED` becomes `VERIFIED` when unit tests pass through forge and coverage
holds.

Every status change waits for user review. `plan.yaml` is the single source of
truth.

## 14. FOLLOWUP.md

The workspace root keeps a `FOLLOWUP.md`. Read it at the start of a session.

Headings: **Now**, **Next**, **Waiting on a human**, **Deferred**, **Decided**.

- One line per entry. Same writing rules as everything else.
- Update it when work changes state. Not at the end.
- An entry moves to **Waiting on a human** when the code is done and the gates
  pass. Delete it only after the user confirms it works for real.
- Tests passing is not confirmation. Never mark something done because tests
  pass.
- **Decided** holds closed questions so nobody reopens them. Give the date.
- It holds state. Learnings go in a `CLAUDE.md`.

## 15. Git

- Read only git is always safe. `status`, `log`, `diff`, `show`.
- **Banned**: `checkout`, `restore`, `stash`, `reset`, `revert`, `clean`, `rm`,
  `commit --amend`, `rebase`. They destroy work with no undo.
- To see an old version use `git show <ref>:<path>`.
- To restore content use Write or Edit.
- Read the user's other repos at `origin/main` with `git show`. Local checkouts
  run far behind.
- If a file needs reverting, say so. Let the user do it.
- Never sign a commit as an assistant. No `Co-Authored-By`. No tool branding.
- Never commit secrets. `.envrc` stays untracked.
- Commits are focused. The subject starts with one emoji. The pipeline reads
  it to bump the release version.

| Emoji | Use | Bump |
|---|---|---|
| ⚠ | breaking change | major |
| ✨ | new feature | minor |
| 🐛 | fix | patch |
| 🌱 | bump, update, clean up | patch |
| 📖 | docs | none |
| 🧹 | tests only, formatting, cosmetics | none |

No emoji still bumps patch. `cap: v0` holds the major at 0 until lifted.

## 16. Tooling

- Never edit a file with python, awk, sed, `cp` or a shell heredoc. Use Write
  and Edit. Shell edits cannot be audited or reverted.
- Read a file before you overwrite it.
- Redirect every command to a file under `/tmp` then grep the file. A wrong grep
  should cost one grep and not a rerun.
