#!/bin/bash

# Claude Me - Workspace Setup Script
# Interactively select and clone repos to ~/.claude/workspace/repos

set -euo pipefail

WORKSPACE_DIR="${HOME}/.claude/workspace/repos"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Claude Me - Workspace Setup${NC}"
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
  echo -e "${RED}Error: GitHub CLI (gh) is not installed.${NC}"
  echo ""
  echo "Install it with:"
  echo "  macOS:   brew install gh"
  echo "  Ubuntu:  sudo apt install gh"
  echo "  Windows: winget install GitHub.cli"
  echo ""
  echo "Then login with: gh auth login"
  exit 1
fi

# Check if gh is authenticated
if ! gh auth status &> /dev/null; then
  echo -e "${RED}Error: GitHub CLI is not authenticated.${NC}"
  echo ""
  echo "Run: gh auth login"
  exit 1
fi

# Get available gh accounts
get_gh_accounts() {
  gh auth status 2>&1 | grep "Logged in to github.com account" | sed 's/.*account \([^ ]*\).*/\1/'
}

# Create workspace directory
mkdir -p "${WORKSPACE_DIR}"

# Function to select repos interactively
select_repos() {
  local org="${1}"
  local gh_account="${2:-}"

  # Switch to correct gh account if specified and available
  if [[ -n "${gh_account}" ]]; then
    if gh auth switch --user "${gh_account}" 2> /dev/null; then
      echo -e "${GREEN}Switched to account: ${gh_account}${NC}"
    else
      echo -e "${YELLOW}Warning: Could not switch to ${gh_account}, using current account${NC}"
    fi
  fi

  echo -e "${YELLOW}Fetching repos from ${org}...${NC}"

  # Get repo list
  local repos
  repos=$(gh repo list "${org}" --limit 100 --json name,description --jq '.[] | "\(.name)|\(.description)"' 2> /dev/null) || true

  if [[ -z "${repos}" ]]; then
    echo -e "${RED}No repos found or no access to ${org}${NC}"
    echo "Make sure you have access and are logged in with the correct account."
    return
  fi

  echo ""
  echo -e "${BLUE}Select repos to clone from ${org}:${NC}"
  echo ""

  local selected
  # Use gum for interactive selection if available, otherwise use simple menu
  if command -v gum &> /dev/null; then
    selected=$(echo "${repos}" | cut -d'|' -f1 | gum choose --no-limit)
  else
    # Simple numbered menu
    echo "${repos}" | nl -w3 -s') '
    echo ""
    echo "Enter repo numbers (comma-separated), 'all', or 'none':"
    echo -n "> "
    local selection
    read -r selection

    if [[ "${selection}" == "all" ]]; then
      selected=$(echo "${repos}" | cut -d'|' -f1)
    elif [[ "${selection}" == "none" ]] || [[ -z "${selection}" ]]; then
      selected=""
    else
      selected=""
      local nums
      IFS=',' read -ra nums <<< "${selection}"
      for num in "${nums[@]}"; do
        num=$(echo "${num}" | tr -d ' ')
        local repo
        repo=$(echo "${repos}" | sed -n "${num}p" | cut -d'|' -f1)
        if [[ -n "${repo}" ]]; then
          selected="${selected} ${repo}"
        fi
      done
    fi
  fi

  # Clone selected repos
  local repo
  for repo in ${selected}; do
    local repo_path="${WORKSPACE_DIR}/${org}/${repo}"
    if [[ -d "${repo_path}" ]]; then
      echo -e "${GREEN}✓${NC} ${repo} (already exists)"
    else
      echo -e "${BLUE}Cloning${NC} ${org}/${repo}..."
      mkdir -p "${WORKSPACE_DIR}/${org}"
      if gh repo clone "${org}/${repo}" "${repo_path}" -- --depth=1 2> /dev/null; then
        echo -e "${GREEN}✓${NC} ${repo}"
      else
        echo -e "${YELLOW}⚠${NC} Failed to clone ${repo}"
      fi
    fi
  done
}

# Show current gh auth status
echo "Current GitHub accounts:"
gh auth status 2>&1 | grep -E "(Logged in|Active)" | head -10 || true
echo ""

# Main menu
echo "Options:"
echo "1) Clone from infinity-microsoft (Microsoft org)"
echo "2) Clone from mao-family (Personal org)"
echo "3) Clone from custom organization"
echo "4) Exit"
echo ""
echo -n "Select option: "
read -r org_choice

case "${org_choice}" in
  1)
    select_repos "infinity-microsoft" "shuyumao_microsoft"
    ;;
  2)
    select_repos "mao-family" "maoshuyu"
    ;;
  3)
    echo -n "Enter organization name: "
    read -r custom_org
    echo -n "Enter gh account to use (leave empty for current): "
    read -r custom_account
    select_repos "${custom_org}" "${custom_account}"
    ;;
  4)
    echo "Bye!"
    exit 0
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

echo ""
echo -e "${GREEN}🎉 Workspace setup complete!${NC}"
echo "Repos cloned to: ${WORKSPACE_DIR}"
