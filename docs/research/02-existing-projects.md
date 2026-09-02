# What already exists

Checked 2026-09-02. "Last update" is what GitHub showed on that date.

## Live and relevant to Dofus 3

| Project | What it does | Stack | Last update | Why it matters |
|---|---|---|---|---|
| [Loulouw/ROrganizer](https://github.com/Loulouw/ROrganizer) | Multi-account window switcher, hotkey per character | **Rust** | 2026-08-17 | Closest thing to your stack. Reference for the safe integration model. |
| [dofusdude/doduda](https://github.com/dofusdude/doduda) | CLI that downloads and unpacks Dofus 3 assets to JSON | Go, GPL-3.0 | 2026-07-06 | Your quest and map data pipeline. |
| [dofusdude/dofus3-main](https://github.com/dofusdude/dofus3-main) | Auto-updating Dofus 3 data releases | data | live | Pre-built JSON so you never run the extractor. |
| [dofusdude/doduapi](https://github.com/dofusdude/doduapi) | Open Dofus encyclopedia API, versioned per Dofus 3 build | Go | live | Hosted alternative to shipping your own data. |
| [GanymedeTeam/ganymede-app](https://github.com/GanymedeTeam/ganymede-app) | Community guides in a window beside the game, one-click copy of travel routes, treasure hunt tool | **Tauri + React + TS + Rust** | 2026-03 | Direct prior art for your idea, and the exact stack you want. 31 stars, 16 forks. |
| [krm35/dofus-multi](https://github.com/krm35/dofus-multi) | Multi-account on mono servers, no-anim, HDV bot, hunt bot, FM bot | Node back + browser front | 2026-09-01 | 209 stars, most popular. **It is a protocol-level custom client. Out of scope, but see `06`.** |
| [Kiyozz/dofus-db-treasure-hunt-overlay](https://github.com/Kiyozz/dofus-db-treasure-hunt-overlay) | DofusDB treasure hunt as an overlay for single-monitor players | Electron | active | Simplest overlay pattern: embed a website over the game. |
| [Sato-Isolated/DofusHuntHelper](https://github.com/Sato-Isolated/DofusHuntHelper) | Partial treasure hunt automation on Dofus 3, clipboard to `/travel` | C# .NET 9 | 2025-09-24, paused | Shows the clipboard-to-chat trick end to end. |
| [Dofus-Batteries-Included/DDC](https://github.com/Dofus-Batteries-Included/DDC) | Data extracted from the client via BepInEx, published as JSON + REST API | C#, MIT | 2025-06-17 | Data source with different coverage than doduda. |
| [Dofus-Batteries-Included/DBI.Api](https://github.com/Dofus-Batteries-Included/DBI.Api) | Data Center, Path Finder (map graph, routes) and Treasure Solver APIs | C#, MIT | 2026-08-28 | **A hosted pathfinder between maps.** Saves you building a world graph. |
| [AnthoB-Dev/GPODofus3](https://github.com/AnthoB-Dev/GPODofus3) | Progression guide for Dofus 3, based on the Skyzio spreadsheet | — | 2026-02-19 | Existing structured quest ordering data. |

## Live, multi-account only

`valyriaa/DofusOrganizer`, `kihw/dorganize`, `Madgique/dofus-multi-organizer`
(WinUI 3), `Ducrosr/Dofus-Unity-Retro-Window-Manager-StreamDeck-Overlay`,
`MinutesBack/multi-tofu` (macOS), `Leidvor/SquadMaster`, `Sehyn/Multifus`,
`Slyker/MultiTool`, plus a long tail of AutoHotkey scripts
(`Yokani/DofusHeroes`, `phoegasus/DofusMultiUtility`, `itorterat/Doktool-2.0`).

They all do the same three things: enumerate Dofus windows, bind a hotkey per
character, bring the right one forward. Some add window renaming and icons.

## Closed source, notable

- **DofusGuide** (dofusguide.fr). Free, Windows, in-game overlay, 13 tools:
  level 1-200 progression guide, builds, professions, dungeons, achievements,
  treasure hunt, Almanax, group finder. It claims to be **officially affiliated
  with Ankama Games** and "100% legal and authorized". This is the strongest
  evidence that an overlay of this exact shape is acceptable to Ankama.
- **Dofus Console** (dofus-console.com). Rust, native Windows API, organizes
  windows, autofocus, and **broadcasts inputs across a multi-account team**.
- **Blitzkrieg**, **Dofixed**. Non-official overlays, no source.

## Dead or Dofus 2 only

- `Dofus-Batteries-Included/DBI.Plugins` — discontinued, Ankama bans BepInEx.
- `bot4dofus/Datafus` — deprecated at the Dofus 3 release.
- `louisabraham/LaBot`, `JustNao/Karrelage`, `viclew1/VLDofusBot`,
  `MojoCC/dofus-packet-sniffer`, `AxelConceicao/dofus-sniffer` — Dofus 2 protocol.
- `LuaxY/dofus-unity-protocol-builder` — self-declared outdated.
- `jordanamr/DivaZaap` — Go emulator of the Dofus Unity to Ankama Launcher
  Thrift protocol. Built for private servers, not for live play.

## Web data sources

- **DofusDB** (api.dofusdb.fr). Community JSON API covering items, monsters,
  maps, treasure hunts, and **quests with their conditions, steps and rewards**.
  Reused across the whole ecosystem. Not official.
- **Dofapi** (dofapi.fr). Items, resources, professions.
- **DofusLab** (`dofuslab/dofuslab`). Open source set builder.

## Reading of the landscape

Two gaps stand out.

1. **Nobody joins the pieces.** Guides live in Ganymede, pathfinding lives in a
   DBI API, quest data lives in doduda, input lives in the organizers. No tool
   reads your current quest step, plans the route, and hands you the keystroke.
2. **Nothing is written for the quest loop specifically.** Treasure hunts are
   solved five times over. Quest travel and dialogue is untouched territory.

That is where this project's value is.
