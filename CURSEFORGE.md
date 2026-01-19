# RoleCall Classic

**"See the groups. Skip the spam."**

RoleCall Classic is a World of Warcraft Classic addon that parses LFG-related chat messages into a clean, readable board — without automation, without breaking Classic rules, and without clutter.

Designed for **The Burning Crusade Classic Anniversary** servers.

## Features

- **Smart Chat Parsing** — Automatically detects dungeon names, roles needed, player levels, and LFM/LFG intent from chat
- **Clean LFG Board** — Scrollable board showing all active groups with Dungeon, Roles, Player, Level, and Time posted
- **Auto De-Duplication** — When someone reposts, it updates their entry instead of spamming your board
- **Click-to-Whisper** — Click any entry to prefill a contextual whisper (fully manual, no automation)
- **Quiet Mode** — Toggle chat notifications on/off while entries still populate the board
- **Minimap Button** — Quick access to toggle the board
- **Zero Configuration** — Works immediately after installation

## Installation

1. Download RoleCall Classic from CurseForge
2. Extract to your WoW Classic AddOns folder:
   ```
   C:/Program Files (x86)/World of Warcraft/_classic_/Interface/AddOns/
   ```
3. Ensure the folder is named `RoleCall` (not `rolecall-classic`)
4. Reload UI or restart WoW
5. Type `/rolecall` (or `/rcc`) to open the board

**Note:** If the addon doesn't appear, enable "Load out of date AddOns" on the character select screen.

## How to Use

### Opening the Board

- Type `/rolecall` or `/rcc` in chat to toggle the board
- Click the minimap button to toggle the board
- Drag the title bar to move the board anywhere on screen
- Drag the bottom-right corner to resize

### Board Controls

- **Notify/Mute** — Toggle chat notifications; new entries still appear on the board
- **Clear** — Remove all entries from the board instantly
- **Click any entry** — Prefills a whisper to that player (you must press Enter to send)
- **Click column headers** — Sort by Dungeon, Roles, Player, Level, or Time

### What Gets Parsed

RoleCall monitors the LookingForGroup and Trade channels and automatically detects:
- Dungeon/raid names and abbreviations
- Roles needed (Tank, Healer, DPS)
- Player names and levels
- Whether it's LFM (looking for more) or LFG (looking for group)

## Supported Dungeons & Raids

- **BRD** (Blackrock Depths)
- **Strat** / Strat Live / Strat UD (Stratholme)
- **Scholo** (Scholomance)
- **UBRS** (Upper Blackrock Spire)
- **DM** / DM-N / DM-E / DM-W (Dire Maul)
- **SM** / SM Cath / SM Armory / SM Library / SM Graveyard (Scarlet Monastery)
- **SFK** (Shadowfang Keep)
- **BFD** (Blackfathom Deeps)
- **Wailing Caverns**
- **Uldaman**
- **Ragefire Chasm** (RFC)
- **Zul'Farrak** (ZF)
- **MC** (Molten Core)
- **BWL** (Blackwing Lair)
- **ZG** (Zul'Gurub)
- **AQ20** / AQ40 (Ahn'Qiraj)
- **NAXX** (Naxxramas)

And many more! RoleCall recognizes common abbreviations and full dungeon names.

## Classic Compliance

RoleCall is **fully Classic-legal**:
- ✅ No automation — All whispers are manual
- ✅ No matchmaking — Just a read-only board
- ✅ No external dependencies
- ✅ TBC Classic Anniversary API compliant

## Support

Found a bug or have a suggestion? Visit the [GitHub repository](https://github.com/paulgiuliano/rolecall-classic) to report issues or request features.

Enjoying RoleCall Classic? In-game gold tips are appreciated!
- **Contact:** laz0rviking#1397
- **Character:** Dunemule (Dreamscythe)

## License

RoleCall Classic is free and open-source under the MIT License.
