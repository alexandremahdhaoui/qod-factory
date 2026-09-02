# qod-factory

qod is quality of life for Dofus 3. This repo owns the qod workspace files
under `workspace/`. Everything a workspace needs is generated from them.

Bootstrap from nothing:

```sh
forge clone git@github.com:alexandremahdhaoui/qod-factory.git
```

Members: `qod-core`, `qod-app`, `qod-spec`, `qod-engines`, `qod-configgen`,
`qod-register`, `qod-state`, and the forge toolchain repos so a minted revision
pins their shas.

Versions come from `qod-register`. The pipeline is its only writer.

The two tests here protect the workspace from two silent failures. `factory`
checks that the files in play are the files here and that a repo never tracks a
file it also ignores. `no-stubs` checks that no committed config points a data
source at a local stand-in.
