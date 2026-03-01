---
name: writing-claude-md
description: Guide for creating or updating CLAUDE.md files. Use this skill when the user wants to create a new CLAUDE.md, update an existing one, set up a new project's instructions, or asks about what should go in CLAUDE.md. Also use when starting a new project or repository that needs Claude Code configuration.
---

# Writing CLAUDE.md

CLAUDE.md is the instruction file for Claude Code. There are two types:

1. **Global CLAUDE.md** (`~/.claude/CLAUDE.md`) - auto-loaded on every session
2. **Project CLAUDE.md** (`memory-bank/{project}/CLAUDE.md`) - read when working on that project

## Key Insight

> LLMs are stateless functions. The only thing the model knows about your codebase is the tokens you put into it.

CLAUDE.md is the **highest-leverage configuration point** — treat it with care.

## File Locations

| Type | Location | When Loaded |
|------|----------|-------------|
| Global | `~/.claude/CLAUDE.md` | Every session |
| Child Project | `workspace/memory-bank/{project}/CLAUDE.md` | When in that project |

## Three Dimensions Framework

Structure your CLAUDE.md around:

| Dimension | Description | Example |
|-----------|-------------|---------|
| **WHAT** | Technical stack and architecture | Apps, packages, monorepo structure |
| **WHY** | Project purpose | What different sections accomplish |
| **HOW** | Practical working instructions | Use `bun` not `node`, how to test |

## Structure

A good CLAUDE.md should be **concise** and **universally applicable**.

- **Target: < 100 lines** (some teams use < 60 lines)
- Task-specific details belong in `memory-bank/`, `rules/`, or separate files

### Required Sections

```markdown
# {project-name}

{One-line description.}

## Core Principles

{3-5 guiding principles for decision-making.}

## Directory Structure

{Tree view of key directories.}

## Commands

{Essential commands for build, test, run.}
```

### Optional Sections

```markdown
## Knowledge Locations

{Pointers to memory-bank/, features/, etc.}

## Development

{Link to README.md.}
```

## Best Practices

### 1. Only Universally Applicable Content

Claude's system prompt says: "this context may or may not be relevant to your tasks."

**Implication:** Task-specific content gets ignored. Only put content that applies to EVERY session.

### 2. Progressive Disclosure

Instead of stuffing everything into CLAUDE.md, use pointers:

```markdown
## Architecture
See `memory-bank/architecture.md` for details.
```

Create separate files in `memory-bank/`:
- `architecture.md`
- `conventions.md`
- `testing.md`

**Key principle:** "Prefer pointers to copies" — file references don't get outdated.

### 3. Minimize Instructions

- Frontier LLMs reliably follow ~150-200 instructions
- Claude Code's system prompt already has ~50 instructions
- Keep your CLAUDE.md instructions minimal

### 4. Claude Isn't a Linter

Never use CLAUDE.md for code style enforcement. Use:
- Biome, ESLint, Prettier
- Pre-commit hooks
- `rules/` directory

### 5. Auto-Analyze Existing Repos

When creating CLAUDE.md for an **existing repository**, auto-analyze instead of asking questions:

```bash
# Gather info automatically
cat package.json          # Project name, description, scripts
ls -la                    # Directory structure
cat README.md | head -50  # Existing docs
```

Extract:
- **WHAT**: From `package.json`, directory structure
- **WHY**: From README.md description
- **HOW**: From `package.json` scripts

Only ask user for **Core Principles** if not obvious from existing docs.

### 6. Don't Use /init

Don't use `/init` to auto-generate CLAUDE.md. Manual crafting is worth it.

## Anti-patterns

- Long prose (use bullet points)
- Implementation details (put in `rules/`)
- Duplicating README (link instead)
- Task-specific instructions (put in `memory-bank/`)
- Code snippets that get outdated (use file references)
- Using LLM for linting (use tools)

## Checklist

Before finishing a CLAUDE.md:

- [ ] Project name and description at top
- [ ] Covers WHAT/WHY/HOW
- [ ] Core principles are decision-focused
- [ ] Directory structure matches reality
- [ ] Commands are tested
- [ ] Under 100 lines
- [ ] English only
- [ ] All content is universally applicable
- [ ] Task-specific details are in separate files
