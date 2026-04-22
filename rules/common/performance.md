# Performance Rules

Guidelines for efficient Claude Code usage and code performance.

## Model Selection

Choose the right model for the task:

| Model | Use Case | Cost |
|-------|----------|------|
| **Haiku** | Lightweight agents, simple code generation, quick lookups | $ |
| **Sonnet** | Main development, complex coding, orchestration | $$ |
| **Opus** | Architectural decisions, deep reasoning, research | $$$ |

**Guidelines:**

- Default to Sonnet for general development
- Use Haiku for high-frequency, simple tasks (formatting, linting agents)
- Reserve Opus for complex decisions requiring deep analysis

## Context Window Management

| Task Type | Context Usage | Recommendation |
|-----------|---------------|----------------|
| Large refactoring | High | Avoid using final 20% of context |
| Multi-file features | High | Split into smaller chunks |
| Single-file edits | Low | Full context OK |
| Documentation | Low | Full context OK |

**When context is filling up:**

1. Complete current subtask
2. Commit progress
3. Start fresh session with focused scope

## Extended Thinking

Extended thinking allocates internal reasoning tokens (up to 31,999).

**When to enable:**

- Complex architectural decisions
- Multi-step debugging
- Code review analysis
- Research synthesis

**Configuration:**

- Toggle: `Option+T` (macOS) / `Alt+T` (Windows/Linux)
- Adjust budget via environment variable or settings.json

## Structured Problem-Solving

For complex tasks:

1. **Enable Plan Mode** - Design before implementation
2. **Use Extended Thinking** - Deep analysis for decisions
3. **Multiple Review Rounds** - Iterate on complex solutions
4. **Spawn Sub-agents** - Parallel analysis from different angles

## Build Performance

**Incremental fixes over wholesale changes:**

1. Analyze specific error message
2. Make minimal targeted fix
3. Verify fix resolves error
4. Move to next error

Avoid "fix everything at once" approaches.

## Code Performance

General performance principles:

| Practice | Benefit |
|----------|---------|
| Lazy loading | Reduce startup time |
| Caching | Avoid redundant computation |
| Batch operations | Reduce I/O overhead |
| Early returns | Avoid unnecessary work |
| Appropriate data structures | O(1) vs O(n) lookups |

> **Language note**: Specific optimization techniques vary by language. See language-specific rules.
