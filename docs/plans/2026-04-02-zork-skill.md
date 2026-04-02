# Zork Skill Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a Zork text adventure skill in claude-me that runs in Claude Code with zero dependencies.

**Architecture:** Shell script wraps embedded dfrotz binaries (cross-platform) to execute Zork I game. Skill definition handles session state, user commands flow through shell to Z-machine interpreter.

**Tech Stack:** Bash, dfrotz (Z-machine interpreter), Zork I game file (.z3)

---

## Task 1: Create Skill Directory Structure

**Files:**

- Create: `skills/zork/SKILL.md`
- Create: `skills/zork/bin/` (directory)

**Step 1: Create directory structure**

```bash
mkdir -p skills/zork/bin/dfrotz
```

**Step 2: Commit structure**

```bash
git add skills/zork/
git commit -m "chore(zork): create skill directory structure"
```

---

## Task 2: Download Game File

**Files:**

- Create: `skills/zork/bin/zork1.z3`

**Step 1: Download Zork I game file**

Zork I is freely available from Infocom's release:

```bash
curl -L -o skills/zork/bin/zork1.z3 \
  "https://github.com/the-infocom-files/zork1/raw/master/zork1.z3"
```

**Step 2: Verify file**

```bash
file skills/zork/bin/zork1.z3
# Expected: data (Z-machine bytecode)

ls -lh skills/zork/bin/zork1.z3
# Expected: ~92KB
```

**Step 3: Commit**

```bash
git add skills/zork/bin/zork1.z3
git commit -m "feat(zork): add Zork I game file"
```

---

## Task 3: Add dfrotz Binary

**Files:**

- Create: `skills/zork/bin/dfrotz/darwin-arm64`
- Create: `skills/zork/bin/dfrotz/darwin-x64` (placeholder)
- Create: `skills/zork/bin/dfrotz/linux-arm64` (placeholder)
- Create: `skills/zork/bin/dfrotz/linux-x64` (placeholder)
- Create: `skills/zork/bin/dfrotz/win32-x64.exe` (placeholder)

**Step 1: Copy local dfrotz (macOS arm64)**

```bash
cp /opt/homebrew/Cellar/frotz/2.55/bin/dfrotz \
   skills/zork/bin/dfrotz/darwin-arm64
chmod +x skills/zork/bin/dfrotz/darwin-arm64
```

**Step 2: Create placeholder for other platforms**

```bash
# Create README for missing platforms
cat > skills/zork/bin/dfrotz/README.md << 'EOF'
# dfrotz Binaries

Pre-compiled dfrotz binaries for each platform.

## Available

- `darwin-arm64` - macOS Apple Silicon

## TODO

Build and add:
- `darwin-x64` - macOS Intel
- `linux-arm64` - Linux ARM64
- `linux-x64` - Linux x86_64
- `win32-x64.exe` - Windows x64

## Building

1. Clone frotz: `git clone https://gitlab.com/DavidGriffith/frotz.git`
2. Build dumb terminal version: `make dumb`
3. Copy `dfrotz` binary to this directory with platform name
EOF
```

**Step 3: Commit**

```bash
git add skills/zork/bin/dfrotz/
git commit -m "feat(zork): add dfrotz binary for macOS arm64"
```

---

## Task 4: Create Shell Wrapper

**Files:**

- Create: `skills/zork/bin/zork.sh`

**Step 1: Write the shell script**

```bash
#!/usr/bin/env bash
#
# Zork game wrapper script
# Manages dfrotz execution and save files
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZORK_DIR="$HOME/.zork"
SAVE_FILE="$ZORK_DIR/save.qzl"
GAME_FILE="$SCRIPT_DIR/zork1.z3"

# Detect platform and select dfrotz binary
detect_dfrotz() {
    local os arch
    os="$(uname -s)"
    arch="$(uname -m)"

    case "$os-$arch" in
        Darwin-arm64)
            echo "$SCRIPT_DIR/dfrotz/darwin-arm64"
            ;;
        Darwin-x86_64)
            echo "$SCRIPT_DIR/dfrotz/darwin-x64"
            ;;
        Linux-aarch64)
            echo "$SCRIPT_DIR/dfrotz/linux-arm64"
            ;;
        Linux-x86_64)
            echo "$SCRIPT_DIR/dfrotz/linux-x64"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "$SCRIPT_DIR/dfrotz/win32-x64.exe"
            ;;
        *)
            echo "Unsupported platform: $os-$arch" >&2
            exit 1
            ;;
    esac
}

# Ensure user data directory exists
ensure_zork_dir() {
    mkdir -p "$ZORK_DIR"
}

# Parse dfrotz output to clean it up
parse_output() {
    sed -E \
        -e '/^>save$/d' \
        -e '/^Please enter a filename/d' \
        -e '/^Ok\.$/d' \
        -e 's/^>//' \
        | grep -v '^\s*$' || true
}

# Start new game or show current state
cmd_start() {
    ensure_zork_dir
    local dfrotz
    dfrotz="$(detect_dfrotz)"

    if [[ ! -x "$dfrotz" ]]; then
        echo "Error: dfrotz binary not found or not executable: $dfrotz" >&2
        echo "Platform: $(uname -s)-$(uname -m)" >&2
        exit 1
    fi

    if [[ -f "$SAVE_FILE" ]]; then
        # Load existing save and show current state with "look"
        (echo "look"; echo "save"; echo "$SAVE_FILE"; echo "y") \
            | "$dfrotz" -L "$SAVE_FILE" "$GAME_FILE" 2>&1 \
            | parse_output
    else
        # New game - just show intro
        (echo "save"; echo "$SAVE_FILE"; echo "y") \
            | "$dfrotz" "$GAME_FILE" 2>&1 \
            | parse_output
    fi
}

# Execute a game command
cmd_exec() {
    local command="$1"
    ensure_zork_dir
    local dfrotz
    dfrotz="$(detect_dfrotz)"

    if [[ ! -x "$dfrotz" ]]; then
        echo "Error: dfrotz binary not found or not executable: $dfrotz" >&2
        exit 1
    fi

    if [[ -f "$SAVE_FILE" ]]; then
        # Load save, execute command, save again
        (echo "$command"; echo "save"; echo "$SAVE_FILE"; echo "y") \
            | "$dfrotz" -L "$SAVE_FILE" "$GAME_FILE" 2>&1 \
            | parse_output
    else
        # New game - execute command then save
        (echo "$command"; echo "save"; echo "$SAVE_FILE"; echo "y") \
            | "$dfrotz" "$GAME_FILE" 2>&1 \
            | parse_output
    fi
}

# Restart game (delete save)
cmd_restart() {
    if [[ -f "$SAVE_FILE" ]]; then
        rm "$SAVE_FILE"
        echo "Save file deleted. Starting new game..."
        echo ""
    fi
    cmd_start
}

# Show usage
usage() {
    cat << 'EOF'
Usage: zork.sh <command> [args]

Commands:
  start           Start or resume game
  cmd "command"   Execute a game command
  restart         Delete save and start new game

Examples:
  zork.sh start
  zork.sh cmd "open mailbox"
  zork.sh cmd "go north"
  zork.sh restart
EOF
}

# Main
main() {
    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi

    local subcmd="$1"
    shift

    case "$subcmd" in
        start)
            cmd_start
            ;;
        cmd)
            if [[ $# -lt 1 ]]; then
                echo "Error: cmd requires a command argument" >&2
                exit 1
            fi
            cmd_exec "$1"
            ;;
        restart)
            cmd_restart
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            echo "Unknown command: $subcmd" >&2
            usage
            exit 1
            ;;
    esac
}

main "$@"
```

**Step 2: Make executable**

```bash
chmod +x skills/zork/bin/zork.sh
```

**Step 3: Commit**

```bash
git add skills/zork/bin/zork.sh
git commit -m "feat(zork): add shell wrapper script"
```

---

## Task 5: Create Skill Definition

**Files:**

- Create: `skills/zork/SKILL.md`

**Step 1: Write skill definition**

```markdown
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
```

**Step 2: Commit**

```bash
git add skills/zork/SKILL.md
git commit -m "feat(zork): add skill definition"
```

---

## Task 6: Test End-to-End

**Step 1: Clean slate**

```bash
rm -f ~/.zork/save.qzl
```

**Step 2: Test start command**

```bash
./skills/zork/bin/zork.sh start
```

Expected: Zork intro text with "West of House" description.

**Step 3: Test game commands**

```bash
./skills/zork/bin/zork.sh cmd "open mailbox"
# Expected: "Opening the small mailbox reveals a leaflet."

./skills/zork/bin/zork.sh cmd "take leaflet"
# Expected: "Taken."

./skills/zork/bin/zork.sh cmd "inventory"
# Expected: Shows leaflet in inventory
```

**Step 4: Test save persistence**

```bash
./skills/zork/bin/zork.sh cmd "go north"
# Expected: North of House description

# Verify save exists
ls -la ~/.zork/save.qzl

# Test restore
./skills/zork/bin/zork.sh start
# Expected: Should show "North of House" (restored state)
```

**Step 5: Test restart**

```bash
./skills/zork/bin/zork.sh restart
# Expected: Clean intro, back at West of House
```

---

## Task 7: Update Documentation

**Files:**

- Modify: `skills/README.md` (add zork entry)

**Step 1: Add to skills README**

Add zork to the skills list in `skills/README.md`.

**Step 2: Commit**

```bash
git add skills/README.md
git commit -m "docs: add zork skill to README"
```

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | Directory structure | `skills/zork/` |
| 2 | Game file | `bin/zork1.z3` |
| 3 | dfrotz binary | `bin/dfrotz/darwin-arm64` |
| 4 | Shell wrapper | `bin/zork.sh` |
| 5 | Skill definition | `SKILL.md` |
| 6 | End-to-end testing | (manual verification) |
| 7 | Documentation | `skills/README.md` |

**Total estimated time:** 20-30 minutes
