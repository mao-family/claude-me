# Architecture

## Overview

claude-me is a personal AI digital worker / AI clone powered by Claude Code. It provides a structured environment for AI-assisted development with custom hooks, skills, agents, and rules.

## Development Workflow

All feature development follows a mandatory 6-stage workflow:

```text
BRAINSTORM → WORKTREE → PLAN → EXECUTE → REVIEW → FINISH
```

## Core Principles

1. **Human Plans, AI Executes** - You plan, I execute
2. **Design Before Code** - Think before you code
3. **Repository = Single Source of Truth** - Everything lives in the repo
4. **Test First, Always** - TDD by default
5. **Encode Taste into Tooling** - Codify preferences into skills, agents, hooks
6. **Progressive Disclosure** - Docs link to details, never duplicate

## Core Components

### Hooks

Located in `hooks/` (configuration) and `scripts/hooks/` (implementation):

- **hooks.json** - Hook configuration for Claude Code

### Skills

Located in `skills/`, workflow guides loaded on-demand:

- **find-skills** - Guide for discovering and installing skills
- **research** - Systematic pre-development research
- **using-lint** - Rules for using lint tools correctly
- **writing-claude-md** - Guide for creating CLAUDE.md files

### Agents

Located in `agents/`, specialized sub-agents for specific tasks or domains:

- **Purpose**: Agents are autonomous Claude instances configured for specific workflows or domains
- **Structure**: Each agent is a markdown file containing:
  - Role and persona definition
  - Specific capabilities and constraints
  - Tool permissions and restrictions
  - Domain knowledge and context
- **Usage**: Invoked via `/agent {name}` or programmatically through multi-agent orchestration
- **Examples**: Code reviewer agent, documentation writer agent, test generator agent

### Rules

Located in `rules/`, coding standards auto-loaded every session:

```text
rules/
├── common/           # Language-agnostic rules
│   ├── coding-style.md
│   ├── performance.md
│   ├── security.md
│   ├── using-lint.md
├── shell/            # Shell script rules
│   └── coding-style.md
├── typescript/       # TypeScript/JavaScript rules
│   ├── coding-style.md
│   ├── hooks.md
│   ├── patterns.md
│   ├── security.md
│   └── testing.md
├── python/           # Python rules
│   ├── coding-style.md
│   ├── hooks.md
│   ├── patterns.md
│   ├── security.md
│   └── testing.md
└── swift/            # Swift rules
    ├── coding-style.md
    ├── hooks.md
    ├── patterns.md
    ├── security.md
    └── testing.md
```

Language-specific rules extend `common/` rules with language-specific content.

### Scripts

Located in `scripts/`:

- **install.sh** - Creates symlinks and sets up the plugin
- **hooks/** - Hook implementation scripts
- **lint/** - Lint helper scripts

### Tests

Located in `tests/`, Bats test files:

- **hooks.bats** - Tests for hook functionality
- **skills.bats** - Tests for skill loading

## Plugin System

claude-me integrates with Claude Code's plugin system:

- Plugin metadata stored in `.claude-plugin/`
- Plugin registration via `claude plugin marketplace`
- Update with: `claude plugin marketplace update claude-me-marketplace`

## Related Documentation

| Document | Content |
|----------|---------|
| [stack.md](stack.md) | Technology stack overview |
| [lint.md](lint.md) | Detailed linting configuration |
