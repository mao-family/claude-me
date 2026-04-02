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
    sed -E 's/^>//' | grep -v -E \
        -e '^Using .* formatting\.$' \
        -e '^Loading .*\.z3\.$' \
        -e '^save$' \
        -e '^Please enter a filename' \
        -e '^Overwrite existing file\?' \
        -e '^Ok\.$' \
        -e '^Failed\.$' \
        -e '^There was no verb in that sentence!$' \
        -e '^EOT$' \
        -e '^ .* Score:' \
        -e '^\s*$' \
        || true
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
