---
name: zork
description: Play the classic Zork I text adventure game. Use /zork to start or resume, type commands directly during session, /zork quit to exit, /zork restart to start over.
---

# Zork Text Adventure

Play the classic 1980 Zork I text adventure in Claude Code.

## Commands

| Command | Action |
|---------|--------|
| `/zork` | Start or resume game session |
| `/zork quit` | Save and exit game session |
| `/zork restart` | Delete save and start new game |

## Session Mode

After `/zork`, you enter game session mode:

- Type game commands directly (e.g., "open mailbox", "go north")
- No prefix needed during session
- Type `/zork quit` to exit session

## Instructions for Claude

When user invokes `/zork`:

### 1. Start Session

Run:

```bash
$SKILL_DIR/bin/zork.sh start
```

Display output and enter session mode.

### 2. During Session

For each user message (unless it starts with `/zork`):

```bash
$SKILL_DIR/bin/zork.sh cmd "USER_INPUT"
```

Display game output only. Do not add commentary or interpretation.

### 3. Quit Session

When user types `/zork quit`:

- Say "Game saved. Exiting Zork."
- Exit session mode, return to normal conversation

### 4. Restart Game

When user types `/zork restart`:

```bash
$SKILL_DIR/bin/zork.sh restart
```

Display output and continue session.

## Example Session

```
User: /zork
Claude: [Displays Zork intro and starting location]

User: open mailbox
Claude: Opening the small mailbox reveals a leaflet.

User: read leaflet
Claude: "WELCOME TO ZORK!
ZORK is a game of adventure, danger, and low cunning..."

User: /zork quit
Claude: Game saved. Exiting Zork.
```

## Technical Details

- **Save location:** `~/.zork/save.qzl`
- **Game engine:** dfrotz (Z-machine interpreter)
- **Game file:** Zork I (zork1.z3)
- **Platforms:** macOS (arm64, x64), Linux (arm64, x64), Windows (x64)
