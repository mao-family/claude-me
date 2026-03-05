# Claude Me

Personal AI digital worker / AI clone powered by Claude Code.

See [CLAUDE.md](CLAUDE.md) for architecture and directory structure.

## Quick Start

**Prerequisites:** macOS, zsh, Homebrew

```bash
# Install dependencies
brew install fnm gh
brew tap oven-sh/bun && brew install oven-sh/bun/bun
echo 'eval "$(fnm env)"' >> ~/.zshrc && source ~/.zshrc
fnm install --lts && fnm use --lts
npm install -g @anthropic-ai/claude-code

# Configure GitHub tokens in ~/.zshrc
gh auth login
export GITHUB_TOKEN_PERSONAL=""  # https://github.com/settings/tokens
export GITHUB_TOKEN_WORK=$(gh auth token)

# Install
git clone https://github.com/mao-family/claude-me.git ~/Repos/claude-me
cd ~/Repos/claude-me && bun run install
claude plugin marketplace update claude-me-marketplace
```

Restart Claude Code. Done!

## Updating

```bash
cd ~/Repos/claude-me && git pull
claude plugin marketplace update claude-me-marketplace
claude plugin install claude-me@claude-me-marketplace
```

> **Note:** `marketplace update` pulls the latest code, `plugin install` updates the cached version. Restart Claude Code after updating.

## Development

```bash
# Prerequisites
brew install bats-core shellcheck shfmt pre-commit
pre-commit install

# Lint & Test
bun run lint   # All checks (shellcheck, markdownlint, shfmt)
bun run test   # Bats tests
```

> **Tip:** During development, bump the version in `.claude-plugin/plugin.json` and run the update commands to test changes.

See [memory-bank/lint.md](memory-bank/lint.md) for lint configuration details.
