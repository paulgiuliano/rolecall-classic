# RoleCall Classic

**"See the groups. Skip the spam."**

RoleCall Classic is a World of Warcraft Classic addon that parses LFG-related chat messages into a clean, readable board — without automation, without breaking Classic rules, and without clutter.

Designed for **Classic Anniversary servers** (e.g. Dreamscythe) with a clear transition path into **The Burning Crusade**.

## Quick Start

1. Copy this folder to your WoW Classic `Addons` directory
2. Reload UI or restart WoW
3. Type `/rc` to toggle the RoleCall board

## Features

### Core MVP Features (Implemented)

- ✅ **Chat Parsing Engine** — Extracts dungeon, roles, level, LFM/LFG intent from chat messages
- ✅ **LFG Board UI** — Clean, scrollable board with Dungeon, Roles, Player, Level, and Time columns
- ✅ **Smart De-Duplication** — Collapses reposts by the same player, increments counter, refreshes timestamp
- ✅ **Whisper Templates** — Click any entry to prefill a contextual whisper (fully manual, Classic-compliant)
- ✅ **Event Monitoring** — Listens to LookingForGroup and Trade channels
- ✅ **Zero Configuration** — Works immediately after loading

### Dungeon Support

Recognized dungeons with aliases:

- BRD (Blackrock Depths)
- Strat / Strat Live / Strat UD (Stratholme)
- Scholo (Scholomance)
- UBRS (Upper Blackrock Spire)
- DM / DM-N / DM-E / DM-W (Dire Maul)
- SM Cath / SM Armory / SM Library / SM Graveyard (Scarlet Monastery)
- BFD (Blackfathom Deeps)
- Wailing Caverns
- Uldaman
- Ragefire Chasm

## Project Structure

```
RoleCall/
  RoleCall.toc      -- Addon manifest
  Core.lua          -- Event handling, chat capture
  Parser.lua        -- Message parsing and intent extraction
  UI.lua            -- Board frame, entry rows, rendering
  Whisper.lua       -- Whisper template generation
  Data.lua          -- In-memory session storage
  README.md         -- This file
```

## TODO

### MVP Completion ✅

- [x] Chat listener for LookingForGroup and Trade channels
- [x] Dungeon name normalization and parsing
- [x] Role extraction (Tank, Healer, DPS)
- [x] Player level detection
- [x] LFM vs LFG classification
- [x] Basic UI frame with scrollable entry list
- [x] De-duplication by player name with repost counter
- [x] Timestamp tracking and "time ago" display
- [x] Row highlighting on hover
- [x] Click-to-whisper with contextual templates
- [x] Debug chat output
- [x] `/rc` slash command

### Phase 2: TBC-Specific Features 🔜

- [ ] Normal / Heroic / Attunement tags in parser
- [ ] Role scarcity highlighting (highlight high-demand roles)
- [ ] Dungeon-specific role presets
- [ ] TBC dungeon aliases (Blood Furnace, Shattered Halls, Slave Pens, etc.)

### Quality-of-Life Enhancements 🔜

- [ ] Optional role filter (show only Tank, Healer, DPS posts)
- [ ] Optional dungeon filter (dropdown or checkboxes)
- [ ] Age-based fading of entries (older = more transparent)
- [ ] Compact vs expanded UI modes
- [ ] Configurable max entry age before auto-pruning
- [ ] Option to auto-hide boosting/selling messages

### Whisper Template Improvements 🔜

- [ ] Smart template context (e.g., "have key" for BRD)
- [ ] Remember recent whisper templates
- [ ] Customizable template presets per role

### Performance & Stability 🔜

- [ ] Entry pruning on excessive backlog (prevent memory bloat)
- [ ] Better error handling for malformed messages
- [ ] Unit tests for parser regex patterns
- [ ] Performance optimization for high chat volume

### CurseForge Release 🔜

- [ ] Generate/collect screenshots:
  1. Raw LFG chat spam
  2. Clean RoleCall board
  3. Whisper template preview
- [ ] Create release notes and changelog
- [ ] Upload to CurseForge with proper versioning

### Open Design Questions

- How aggressive should repost collapsing be? (Current: any re-message = +1 repost)
- Should boosting/selling messages be auto-hidden or flagged?
- Should dungeon abbreviations be user-extensible?

## API Compliance

- ✅ Classic API compliant (Interface 11500)
- ✅ No external dependencies
- ✅ No automation (fully manual, fully legal)

## Development Notes

### Data Model

Entries stored in-memory with the following structure:

```lua
entry = {
  player = "Grimgar",
  dungeon = "BRD",
  roles = {
    tank = true,
    healer = false,
    dps = false
  },
  level = 58,
  lfm = true,
  timestamp = time(),
  reposts = 2
}
```

### Monitored Events

- `CHAT_MSG_CHANNEL` — Trade, LookingForGroup
- `CHAT_MSG_SAY` — Local say
- `CHAT_MSG_YELL` — Local yell
- `ADDON_LOADED` — Initialization

### Slash Commands

- `/rc` — Toggle board visibility

## Design Philosophy

- **Reduce spam, not replace chat** — Board is supplementary, not authoritative
- **Zero configuration** — Works out-of-the-box
- **Fully Classic-legal** — No automation, no matchmaking, fully manual
- **Minimal visual noise** — Clean columns, no unnecessary UI chrome
- **Scales to TBC** — Extensible design for heroics and attunements

## Contributing

Issues and PRs welcome! Please maintain the design philosophy and Classic-compliance.

## License

TBD — Pending CurseForge submission
