# Zork Skill Design

Play classic Zork I text adventure in Claude Code / OpenClaw.

## Overview

| Aspect | Decision |
|--------|----------|
| **Game Mode** | Pure text mode (classic experience) |
| **Save Management** | Single save file, auto save/load |
| **Interaction** | `/zork` to enter session, direct commands, `/zork quit` to exit |
| **Dependencies** | Embedded precompiled binaries (zero dependencies) |
| **Save Location** | `~/.zork/` |
| **Marketplace** | `labs-gaming` (experimental games collection) |
| **Package Size** | ~800KB - 1MB |
| **Platforms** | macOS (arm64/x64), Linux (arm64/x64), Windows (x64) |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Zork Skill Architecture                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  User input: "open mailbox"                                 │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐ │
│  │ zork skill  │───▶│  zork.sh    │───▶│     dfrotz      │ │
│  │   (.md)     │    │  (shell)    │    │  (Z-machine)    │ │
│  └─────────────┘    └─────────────┘    └────────┬────────┘ │
│                                                  │          │
│                                                  ▼          │
│  ┌─────────────┐                        ┌─────────────────┐ │
│  │  ~/.zork/   │◀───────────────────────│   zork1.z3      │ │
│  │  save.qzl   │     auto save          │  (game file)    │ │
│  └─────────────┘                        └─────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Directory Structure

### Marketplace

```
labs-gaming/
├── .claude-plugin/
│   └── manifest.json           # Plugin metadata
├── skills/
│   └── zork/
│       ├── zork.md             # Skill definition
│       └── bin/
│           ├── zork.sh         # Shell wrapper
│           ├── zork1.z3        # Game file (84KB)
│           └── dfrotz/         # Precompiled binaries (~700KB)
│               ├── darwin-arm64
│               ├── darwin-x64
│               ├── linux-arm64
│               ├── linux-x64
│               └── win32-x64.exe
└── README.md
```

### User Data

```
~/.zork/
└── save.qzl                    # Game save file
```

---

## Skill Definition (zork.md)

**Triggers:**

| Command | Behavior |
|---------|----------|
| `/zork` or `/zork start` | Enter game session, load save (or new game) |
| `/zork quit` | Exit game session, return to normal conversation |
| `/zork restart` | Delete save, start new game |

**Session Flow:**

```
User: /zork
Claude: Entering Zork game session...
        [Display game intro text]

User: open mailbox
Claude: [Call zork.sh "open mailbox"]
        Opening the small mailbox reveals a leaflet.

User: read leaflet
Claude: [Call zork.sh "read leaflet"]
        "WELCOME TO ZORK!"...

User: /zork quit
Claude: Game saved. Exiting Zork.
```

**Key Points:**

- After entering session, user input is treated as game commands (no prefix needed)
- Auto-save after each command
- Claude only forwards commands and output, no interpretation

---

## Shell Script (zork.sh)

**Interface:**

| Usage | Description |
|-------|-------------|
| `zork.sh start` | Start new game or load save, display current scene |
| `zork.sh cmd "open mailbox"` | Execute game command |
| `zork.sh restart` | Delete save, restart game |

**Platform Detection:**

```bash
case "$(uname -s)-$(uname -m)" in
    Darwin-arm64)  DFROTZ="$BIN_DIR/dfrotz/darwin-arm64" ;;
    Darwin-x86_64) DFROTZ="$BIN_DIR/dfrotz/darwin-x64" ;;
    Linux-aarch64) DFROTZ="$BIN_DIR/dfrotz/linux-arm64" ;;
    Linux-x86_64)  DFROTZ="$BIN_DIR/dfrotz/linux-x64" ;;
    MINGW*|MSYS*)  DFROTZ="$BIN_DIR/dfrotz/win32-x64.exe" ;;
    *)             echo "Unsupported platform"; exit 1 ;;
esac
```

**Execution Flow:**

1. Detect platform, select correct binary
2. Create `~/.zork/` if not exists
3. If save exists: load → execute command → save
4. If no save: execute command → save
5. Parse and return output

---

## Future Expansion

```
labs-gaming/
├── skills/
│   ├── zork/           # Zork I (done)
│   ├── zork2/          # Zork II (future)
│   ├── hitchhiker/     # Hitchhiker's Guide (future)
│   └── adventure/      # Colossal Cave Adventure (future)
```

---

## References

- [ZORK_ENGINE.md](https://github.com/gim-home/gaming/blob/main/ZorkGPT/docs/ZORK_ENGINE.md) - Original ZorkGPT engine documentation
- [Frotz](https://gitlab.com/DavidGriffith/frotz) - Z-machine interpreter
- [Z-machine](https://inform-fiction.org/zmachine/standards/z1point1/) - Virtual machine specification
