# FOLLOWUP

An overlay that removes the boring clicks from Dofus 3 so the player spends time
on fights, economy and gearing. Not a bot.

## Now

**The pipeline is green.** Run 33633061790 on 2026-09-02: `check`, `build` with
every gate on all four language members, `publish` into `qod-register`, release
`v0.1.0` in `qod-factory`, `v0.1.0` tags on the members. The factory phase is
done. The research and factory docs live in `qod-factory/docs/`. Next is the
first engine.

The real workspace is `~/workspaces/qod`. The tokens live in its root `.envrc`.
`~/workspaces/dofus-overlay` is retired.

## The project

Name is **qod**. Quality of life for Dofus. Eight repos under
`alexandremahdhaoui`.

| Repo | Lang | Holds | Gate |
|---|---|---|---|
| `qod-core` | rust | pure parsing and planning. FlatBuffers, LZ4, UnityFS, type tree, quest model, routes | `hack/purity.sh` |
| `qod-app` | rust | adapters, controllers, drivers, generated cells | `architecture.sh 0`, `coverage.sh 95` |
| `qod-spec` | none | specs and test vectors | `no-network-keys.sh` |
| `qod-engines` | go | forge-dev generator engines, one `cmd/` per engine. First: `flatbuffers-rust` | `generated-check.sh` |
| `qod-configgen` | go | config generator, Rust only | `generated-check.sh` |
| `qod-factory` | none | workspace files | `factory-check.sh`, `no-stubs.sh` |
| `qod-state` | none | revisions and runs | none |
| `qod-register` | none | version tracks, seeded by `hack/seed.sh` | `process`, `evaluate`, `canary`, `publish-members` |

`qod-engines` and `qod-configgen` set `factory: manifest: committed` so
`forge://` can resolve them standalone. Same as `forge-dev-codegen`.

`qod-app` starts with five generated cells from `forge-dev-codegen`:
`cli-rust-clap`, `logging-gen`, `telemetry-gen`, `resilience-gen`,
`delivery-gen`. Each is a directory with a `forge-dev.yaml` plus one build step
using `engine: forge://forge-dev`.

## Next

1. `qod-engines` with `flatbuffers-rust`. Then `qod-core`, `qod-spec`,
   `qod-configgen`, `qod-app`.
3. Spike: do Dofus 3 bundles carry a Unity type tree? Half a day. Go or no-go for
   the whole data extractor.
4. Build the extractor.

Later: the overlay itself, then the collaboration webpage.

## Waiting on a human

- **Ankama terms.** `account.ankama.com/fr/tou` 403s bots. Read it in a browser.
- **Sequenced group travel.** Highest value feature, highest ban risk.
  `docs/research/06-multi-account.md`.

## Deferred

- LZMA support. Only if the spike shows the bundles need it.
- `ci-artifact-release` assets. Declared, but nothing declares `platforms:` yet
  so no binary is distributed.
- `jre` and `openapi-generator` runtimes. Only if a REST surface appears.
- `hack/coverage.sh 95` in `qod-app`. It runs `cargo llvm-cov`, which is not a
  provisioned runtime. Add once there is code to cover and a way to provision
  the tool.

## Decided

**Product.** OS level only: window management, screen capture, `SendInput` on the
focused window. No client injection, no MITM, no protocol-level client. All three
are banned and detected. `/travel X Y` is the movement mechanism, not pathfinding
clicks. Every automated sequence starts with a human keypress and then stops.
Nothing with an economic outcome.

**Shape.** Name is `qod`. Eight repos, listed above. Mirror opends: a pure core
gated by `purity.sh`, an app holding all I/O, a spec repo. Both purity and
`mockall`: pure functions need no mocks, app adapters get mocked. No hardcoded
config or CLI. Every surface is declared and generated through `forge-dev`.
Generators come from `forge-dev-codegen`. Config generation is the one gap, so
`qod-configgen` reimplements it for Rust only. Our own generators live in
`qod-engines`, one `cmd/` per engine. `qod-configgen` stays its own repo.

**FlatBuffers.** No flatc. `qod-engines/cmd/flatbuffers-rust` parses
`manifest.fbs` itself and emits `zz_generated_manifest.rs`. The emitted code
calls the `flatbuffers` crate runtime API, the same calls flatc's output makes.

**Engineering.** Apache-2.0. Factory before product code. Crates are vetted one
by one, never added on my judgement. Approved: `reqwest`, `rustls`, `serde`,
`serde_json`, `clap`, `thiserror`, `anyhow`, `lz4_flex`, `flatbuffers`,
`mockall` dev-only. The UnityFS parser is reimplemented; the only Rust option has
11 stars. Workspace directory stays `~/workspaces/dofus-overlay`.

**Toolchain.** Installed from the `forge-self-factory` aggregated release, never
`go install`. A `go install` build is a dev build with no companion revision,
so `forge factory` and `forge ci` fall through to whatever is on PATH. A
released `forge` resolves its siblings pinned. Current: `v0.45.38`, four
binaries, every sha256 checked against the release `index.json`. Every other
forge engine in `~/go/bin` was deleted. An engine resolves as `./cmd/<name>`,
then PATH, then pinned `go run`, so a stale engine on PATH silently shadows the
release. That is what broke the first sync. Always go through `forge factory`
and `forge ci`, which put `.forge/bin` first on PATH.

**Bootstrap before apply.** `forge ci bootstrap` seals the Actions secrets.
`forge ci apply` pushes the generated workflows, and a push fires them at once.
Apply first means every first run fails for a missing secret. Done in the wrong
order on 2026-09-02, five notify runs re-run by hand.

**Sync appends `/.envrc` to every member's `.gitignore`.** A member whose
ignore file lacks that exact block comes out of sync modified, the revision
reads `-dirty`, and the release refuses. Commit the block sync writes, comment
included. It is generated content.

**Versions come from emoji subjects.** `versioning.strategy: semantic` with the
six emoji vocabulary, `cap: v0`. Subjects are read since the last tag from the
pipeline `repos:` only, so `qod-factory` is listed there. It stays out of
`releaseRepos` and the watch list.

**The release engine needs `tokenEnv`.** `ci-artifact-release` reads
`GITHUB_TOKEN` by default and the generated workflow exports only
`FORGE_CI_GITHUB_TOKEN`, so the first CI run passed `check` and `build` and
died on `publish` with 401. golden's config has the same hole.

**Engine URIs carry no version pin.** Not `@v0.1.0`, not anything. A pinned URI
skips `.forge/bin` and goes straight to `go run module@version`, which is how
`ci-state-git@v0.1.0` failed. Bare URI or `@latest` only.

**Working rules.** Read the forge and golden repos at `origin/main` with
`git show`; local checkouts run up to 90 commits stale. Never write a file
through a heredoc, `cp`, `sed`, `awk` or python. Write and Edit only.

## Key facts

**Forge.** A repo cannot be built alone: every manifest, and each member's
`.envrc`, is generated and gitignored. Member CI notifies, it never builds. The
workflows themselves are generated by `forge-ci apply` from `forge-ci.yaml`. Jobs
run inside the toolchain container, so CI installs nothing. Order is check, then
build with `sync: true`, then publish. Mint after the gate. There is no `self`
stage. Detail: `docs/factory/00-forge-model.md`.

**Engines.** A forge-dev generator is one `cmd/` directory: `forge-dev.yaml`,
`spec.openapi.yaml`, `handlers.go`, generated MCP wiring. Two build steps, one
`forge://forge-dev` then one `forge://go-build`. Pure function from a model to
files. Detail: `docs/factory/01-target-setup.md`.

**Register.** Not empty. `forge-register.yaml` with policy params, a `forge.yaml`
whose stages are the `forge-register` CLI, `hack/seed.sh` filing one admission
request per package, `hack/publish-members.sh` publishing each member with the
minted revision as provenance. The pipeline is its only writer. The toolchain
image track `internal:ghcr.io/alexandremahdhaoui/forge` is published by hand
once, with the release revision from `index.json` as provenance, or sync cannot
resolve `toolchain.image`.

**Dofus 3.** Unity IL2CPP, obfuscated symbols, protobuf protocol. Ankama detects
behaviour, not software, and bans in waves. Multi-accounting and window
organizers are fine; macros are the grey zone. Unity ignores `PostMessage`, so
only the focused window can be driven. Detail: `docs/research/`.

**The data.** Two layers. Ankama's cytrus CDN is three URLs and byte slicing, no
compression. Unity is the real work: UnityFS, LZ4 blocks, SerializedFile, type
tree walk. Detail: `docs/research/08-rebuilding-in-rust.md`.

## Still to study

`ci-compute-github` and `ci-trigger-watch` Go source, the unused engines
`ci-artifact-container`, `ci-gate-manual`, `ci-manager-dryrun`, and
`forge-register`'s `add`, `apply`, `publish` verbs before seeding the register.
