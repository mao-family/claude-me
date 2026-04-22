# Rules

Coding standards auto-loaded every Claude Code session.

## Structure

```text
rules/
├── common/           # Language-agnostic principles (always loaded)
│   ├── coding-style.md
│   ├── performance.md
│   ├── security.md
│   ├── using-lint.md
├── shell/            # Shell script specific
├── typescript/       # TypeScript/JavaScript specific
├── python/           # Python specific
└── swift/            # Swift specific
```

## How Rules Work

- **common/** contains universal principles with no language-specific code
- **Language directories** extend common rules with framework-specific patterns and tools
- Each language-specific file references its common counterpart

## Rule Priority

When language-specific rules and common rules conflict, **language-specific rules take precedence**.

## Related Documentation

| Document | Content |
|----------|---------|
| [common/coding-style.md](common/coding-style.md) | Universal coding principles |
| [common/security.md](common/security.md) | Security checklist |
| [common/performance.md](common/performance.md) | Performance guidelines |
