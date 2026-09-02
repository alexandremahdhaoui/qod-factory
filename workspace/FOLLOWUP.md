# FOLLOWUP

An overlay that removes the boring clicks from Dofus 3 so the player spends time
on fights, economy and gearing. Not a bot.

## Now

`qod-factory`, `qod-register` and `qod-state` are pushed. The register holds 20
admitted tracks, one per pinned package. Next is the checkpoint: `forge clone`
into a clean directory.

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

1. `forge clone git@github.com:alexandremahdhaoui/qod-factory.git .` into a
   clean directory. **The checkpoint.**
2. Supply `FORGE_CI_GITHUB_TOKEN` and `FORGE_CI_DISPATCH_TOKEN`, run
   `forge-ci apply`, confirm `ci.yaml` and `release.yaml` generate.
3. Move `docs/` and `notes.md` into `qod-factory/workspace/`.
4. `qod-engines` with `flatbuffers-rust`. Then `qod-core`, `qod-spec`,
   `qod-configgen`, `qod-app`.
5. Spike: do Dofus 3 bundles carry a Unity type tree? Half a day. Go or no-go for
   the whole data extractor.
6. Build the extractor.

Later: the overlay itself, then the collaboration webpage.

## Waiting on a human

- **Toolchain members.** The factory lists `forge-ci`, `forge-factory`,
  `forge-register`, `forge-dev-codegen` and the three spec repos as members,
  exactly as golden does. It is not verified which of them the pipeline needs.
  The `forge clone` checkpoint tells.
- **Ankama terms.** `account.ankama.com/fr/tou` 403s bots. Read it in a browser.
- **Sequenced group travel.** Highest value feature, highest ban risk.
  `docs/research/06-multi-account.md`.

## Deferred

- LZMA support. Only if the spike shows the bundles need it.
- `ci-artifact-release` assets. Declared, but nothing declares `platforms:` yet
  so no binary is distributed.
- `jre` and `openapi-generator` runtimes. Only if a REST surface appears.

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
binaries, every sha256 checked against the release `index.json`. Old binaries
sit in `~/go/bin/*.bak`.

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
minted revision as provenance. The pipeline is its only writer.

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
