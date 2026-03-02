# claude-me

Personal AI digital worker / AI clone powered by Claude Code.

## Core Principles

1. **Human Plans, AI Executes** - You plan, I execute
2. **Design Before Code** - Think before you code
3. **Repository = Single Source of Truth** - Everything lives in the repo
4. **Test First, Always** - TDD by default
5. **Encode Taste into Tooling** - Codify preferences into skills, agents, hooks
6. **Progressive Disclosure** - Docs link to details, never duplicate

## Knowledge Locations

### claude-me

- `CLAUDE.md` - Global instructions (auto-loaded by Claude Code)
- `memory-bank/` - Project knowledge:
  - [architecture.md](memory-bank/architecture.md) - Project structure
  - [stack.md](memory-bank/stack.md) - Technology stack
  - [lint.md](memory-bank/lint.md) - Linting configuration

### Child Projects (workspace/repos/* only)

**CRITICAL: When working in `workspace/repos/{project}/`, NEVER create CLAUDE.md inside the project directory.**

| File | Location | Action |
|------|----------|--------|
| Project CLAUDE.md | `workspace/memory-bank/{project}/CLAUDE.md` | **CREATE here**, not in `workspace/repos/{project}/` |
| Feature docs | `workspace/memory-bank/{project}/features/{name}/*.md` | Create when on `feature/{name}` branch |

**Why:** Child projects are git submodules. Their knowledge files live in `workspace/memory-bank/` to keep repos clean.

## Directory Structure

### Repository

```text
https://github.com/mao-family/claude-me
~/Repos/claude-me/
├── .claude-plugin/          # Plugin metadata
├── skills/                  # Workflow guides (on-demand loading)
├── agents/                  # Specialized sub-agents
├── hooks/                   # Hook configuration (hooks.json)
├── rules/                   # Coding standards (auto-loaded)
├── scripts/                 # Utility scripts
│   ├── hooks/               # Hook implementation scripts
│   └── lint/                # Lint helper scripts
├── tests/                   # Bats test files
├── memory-bank/             # Project knowledge
├── workspace/
│   ├── repos/{project}/     # Child project repositories
│   └── memory-bank/{project}/ # Child project knowledge
├── CLAUDE.md                # Global instructions
├── mcp.json                 # MCP server config
└── settings.json            # Claude Code settings
```

### Runtime

```text
~/.claude/
├── CLAUDE.md → claude-me
├── settings.json → claude-me
├── rules/ → claude-me
├── workspace/ → claude-me
├── memory-bank/ → claude-me
├── settings.local.json      # Local secrets (not in repo)
└── plugins/                 # Plugin: claude-me@claude-me-marketplace

~/.mcp.json → claude-me/mcp.json
```

## Commands

```bash
# Install (create symlinks + setup plugin)
bun run install

# Update plugin cache
claude plugin marketplace update claude-me-marketplace
```

## Development

See README.md for setup instructions.
