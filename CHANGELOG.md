# Changelog

All notable changes to RoleCall Classic will be documented in this file.

## [0.3.1] - 2026-01-20

### Maintenance

- Forced tag to trigger the CurseForge webhook while debugging CI/webhook behavior
- No code changes; same source as 0.3.0

## [0.3.0] - 2026-01-19

### Fixed

- Miscellaneous bug fixes and stability improvements
- Minor polish for Classic Anniversary compatibility

## [0.2.0] - 2026-01-18

### Changed

- **TBC Classic Anniversary Support** — Updated interface version to 20505 for Burning Crusade Classic Anniversary
- Version bumped to 0.2.0 for TBC Classic Anniversary release

### Notes

- This version targets TBC Classic Anniversary only (Interface 20505)
- For original Classic Anniversary (1.15), use version 0.1.0

## [0.1.0] - 2026-01-17

### Initial Release

First stable release of RoleCall Classic addon for World of Warcraft Classic Anniversary servers.

#### Features

- **Chat Parsing Engine** — Extracts dungeon, roles, level, and LFM/LFG intent from chat messages
- **LFG Board UI** — Clean, scrollable board with Dungeon, Roles, Player, Level, and Time columns
- **Smart De-Duplication** — Collapses reposts by the same player with repost counter
- **Whisper Templates** — Click any entry to prefill a contextual whisper
- **Event Monitoring** — Listens to LookingForGroup and Trade channels
- **Zero Configuration** — Works immediately after loading
- **Minimap Button** — Quick access to toggle the RoleCall board
- **Sortable Columns** — Click headers to sort by Dungeon, Roles, Player, Level, or Time
- **Resizable & Draggable** — Position and size the board to your preference
- **Notify/Mute Toggle** — Control chat notifications while board continues to populate
- **Auto-Pruning** — Entries older than 10 minutes are automatically removed every 60 seconds
- **Manual Clearing** — Clear Board button for instant clearing of all entries

#### Supported Dungeons

- Blackrock Depths (BRD)
- Stratholme (Strat, Strat Live, Strat UD)
- Scholomance (Scholo)
- Upper Blackrock Spire (UBRS)
- Dire Maul (DM, DM-N, DM-E, DM-W)
- Scarlet Monastery (SM Cath, SM Armory, SM Library, SM Graveyard)
- Blackfathom Deeps (BFD)
- Wailing Caverns
- Uldaman
- Ragefire Chasm

#### Classic Compliance

- No automation or auto-invite
- No matchmaking or group creation
- Fully manual, fully legal
- API compliant with TBC Classic Anniversary (Interface 20504)
- No external dependencies
