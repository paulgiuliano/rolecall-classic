# RoleCall Classic

**Design & Development Notes**

## Tagline

**“See the groups. Skip the spam.”**

RoleCall Classic is a World of Warcraft Classic addon that parses LFG-related chat messages into a clean, readable board — without automation, without breaking Classic rules, and without clutter.

Designed for **Classic Anniversary servers** (e.g. Dreamscythe) with a clear transition path into **The Burning Crusade**.

---

## Project Goals

* Reduce LFG chat spam without replacing chat
* Improve dungeon group visibility and readability
* Stay fully Classic-legal (no auto-invite, no matchmaking)
* Require zero configuration to be useful
* Scale naturally into TBC (heroics, attunements)

---

## Explicit Non-Goals

* No automated group creation
* No queue or matchmaking system
* No cross-server features
* No shared/global reputation database
* No forced announcements or chat spam

---

## Target Audience

### Phase 1 — Classic Anniversary

* Leveling dungeon groups
* Endgame dungeon runners (BRD, Strat, UBRS)
* Tanks and healers reacting to LFG spam

### Phase 2 — TBC Transition

* Normal and Heroic dungeon groups
* Attunement runs (Kara, SSC, TK)
* Role-scarce content (especially tanks)

---

## Core MVP Features

### 1. Chat Parsing Engine

Parse common LFG messages such as:

```
LFM UBRS need tank + healer  
LF2M DPS Strat Live 58+  
Tank LFG SM Cath  
```

Extract structured intent:

* Dungeon (normalized name)
* Role(s) requested or offered
* Group intent (LFM vs LFG)
* Player level (explicit or inferred)
* Timestamp
* Player name

---

### 2. LFG Board UI

Scrollable, minimal board presenting parsed entries:

| Dungeon | Roles Needed | Player  | Level | Age |
| ------- | ------------ | ------- | ----- | --- |
| BRD     | Tank + Heal  | Grimgar | 58    | 1m  |
| SM Cath | DPS          | Elowyn  | 36    | 30s |

Design principles:

* Minimal visual noise
* Readable at a glance
* Mouse interaction only
* No automation buttons

---

### 3. Smart De-Duplication

If the same player reposts:

* Collapse into a single entry
* Refresh timestamp
* Increment a repost counter

Purpose:

* Prevent spam dominance
* Improve signal-to-noise ratio
* Highlight genuinely new requests

---

### 4. Whisper Templates

Clicking an entry opens a **prefilled whisper**, editable before sending.

Example:

```
Hey! 60 resto druid healer for BRD, have key.
```

Manual send only (fully Classic-compliant).

---

## Differentiation from Existing Addons

### Compared to LFG Group Bulletin Board

* Smarter intent parsing
* Built-in repost de-duplication
* Cleaner, lighter UI
* Designed explicitly for TBC scaling

### Compared to ClassicLFG

* No pseudo-automation
* Faster onboarding
* Lower cognitive load

---

## Planned Post-MVP Enhancements

### TBC-Specific

* Normal / Heroic / Attunement tags
* Role scarcity highlighting
* Dungeon-specific role presets

### Quality-of-Life

* Optional role and dungeon filters
* Age-based fading of old entries
* Compact vs expanded UI modes

---

## Technical Architecture

### File Structure

```
RoleCall/
  RoleCall.toc
  Core.lua        -- event handling, chat capture
  Parser.lua     -- message → structured intent
  UI.lua         -- board, filters, rows
  Whisper.lua    -- whisper templates
  Data.lua       -- in-memory store
```

---

### Events Listened To

* CHAT_MSG_CHANNEL
* CHAT_MSG_SAY
* CHAT_MSG_YELL

Filtered by channel name:

* LookingForGroup
* Trade
* General (optional)

---

### Data Model (Session-Only)

Lua table structure:

```
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

No persistence in early versions.

---

## Suggested Development Plan

### Days 1–2

* Chat listener
* Dungeon and role parsing
* Debug output to chat frame

### Day 3

* Basic UI frame
* Scrollable entry list

### Day 4

* De-duplication logic
* Timestamp refresh

### Day 5

* Whisper templates
* Live server testing
* Polish and release prep

---

## CurseForge Release Strategy

* Addon name: **RoleCall Classic**
* Screenshots:

  1. Raw LFG chat spam
  2. Clean RoleCall board
  3. Whisper template preview
* Messaging focus:

  * Zero configuration
  * Immediate usefulness
  * Classic-friendly design

---

## Open Design Questions

* How aggressive should repost collapsing be?
* Should boosting/selling messages be hidden or flagged?
* Should dungeon abbreviations be user-extensible?

---

## Notes

* Classic API compliant
* No external dependencies
* Designed for longevity into TBC
