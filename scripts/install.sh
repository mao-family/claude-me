#!/bin/bash

# Claude Me - Installation Script
# Sets up symlinks and installs the plugin

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${HOME}/.claude"
HOME_DIR="${HOME}"

echo "🔧 Claude Me - Installing..."
echo "   Source: ${REPO_DIR}"
echo "   Target: ${CLAUDE_DIR}"
echo ""

# Ensure ~/.claude exists
mkdir -p "${CLAUDE_DIR}"

# Backup existing files if they're not symlinks
backup_if_exists() {
  local file="${1}"
  if [[ -e "${CLAUDE_DIR}/${file}" ]] && [[ ! -L "${CLAUDE_DIR}/${file}" ]]; then
    echo "   📦 Backing up existing ${file}..."
    mv "${CLAUDE_DIR}/${file}" "${CLAUDE_DIR}/${file}.backup.$(date +%Y%m%d%H%M%S)" || true
  fi
}

# Create symlink (for files in ~/.claude/)
create_symlink() {
  local source="${1}"
  local target="${2}"

  # Remove existing symlink or backup existing file
  if [[ -L "${CLAUDE_DIR}/${target}" ]]; then
    rm "${CLAUDE_DIR}/${target}"
  elif [[ -e "${CLAUDE_DIR}/${target}" ]]; then
    backup_if_exists "${target}"
  fi

  ln -sf "${REPO_DIR}/${source}" "${CLAUDE_DIR}/${target}"
  echo "   ✅ ${target} → ${source}"
}

# Create symlink in home directory (for files like ~/.mcp.json)
create_home_symlink() {
  local source="${1}"
  local target="${2}"

  if [[ -L "${HOME_DIR}/${target}" ]]; then
    rm "${HOME_DIR}/${target}"
  elif [[ -e "${HOME_DIR}/${target}" ]]; then
    echo "   📦 Backing up existing ~/${target}..."
    mv "${HOME_DIR}/${target}" "${HOME_DIR}/${target}.backup.$(date +%Y%m%d%H%M%S)" || true
  fi

  ln -sf "${REPO_DIR}/${source}" "${HOME_DIR}/${target}"
  echo "   ✅ ~/${target} → ${source}"
}

echo "📎 Creating symlinks..."

# Symlinks in ~/.claude/ (4 items)
create_symlink "CLAUDE.md" "CLAUDE.md"
create_symlink "settings.json" "settings.json"
create_symlink "rules" "rules"
create_symlink "memory-bank" "memory-bank"

# Symlinks in home directory
# Note: Claude Code reads MCP config from ~/.mcp.json, NOT ~/.claude/mcp.json
create_home_symlink "mcp.json" ".mcp.json"

echo ""

# Create settings.local.json if not exists
if [[ ! -f "${CLAUDE_DIR}/settings.local.json" ]]; then
  echo '{}' > "${CLAUDE_DIR}/settings.local.json"
  echo "✅ Created settings.local.json (add your secrets here)"
fi

echo ""
echo "🔌 Installing claude-me plugin..."

# Check if plugin is already installed
if claude plugin list 2> /dev/null | grep -q "claude-me"; then
  echo "   Plugin already installed, updating..."
  claude plugin uninstall claude-me 2> /dev/null || true
fi

# Try to add as local marketplace and install
# Note: Claude Code plugin system requires marketplace-based installation
echo "   ⚠️  Local plugin installation requires manual setup."
echo "   To use claude-me as a plugin, add it as a local marketplace:"
echo ""
echo "   claude plugin marketplace add ${REPO_DIR}"
echo "   claude plugin install claude-me@claude-me"
echo ""

echo ""
echo "🎉 Claude Me installation complete!"
echo ""
echo "📁 Repository: ${REPO_DIR}"
echo "📎 Symlinks created in: ${CLAUDE_DIR}"
echo "🔌 Plugin: see instructions above to enable hooks, skills, agents"
echo ""
echo "📝 Edit ${CLAUDE_DIR}/settings.local.json to add secrets"
echo ""
echo "🔄 Restart Claude Code to apply changes."
