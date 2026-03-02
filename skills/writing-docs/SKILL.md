---
name: writing-docs
description: Guide for writing documentation with Markdown style and progressive disclosure. Use when creating or editing any .md file including README, CLAUDE.md, memory-bank/, or rules/. Ensures proper formatting, hierarchy, and no content duplication.
---

# Writing Documentation

## Progressive Disclosure

**All documentation MUST follow progressive disclosure:**

1. **Entry points stay concise** - CLAUDE.md, README.md should be overview only
2. **Link to details, don't repeat** - Use links instead of duplicating content
3. **Each file has one depth level** - Overview → Structure → Details → Rules
4. **Simplest viable content** - Remove anything that exists elsewhere

## Document Hierarchy

| Level | Location | Max Lines | Content |
|-------|----------|-----------|---------|
| 1 | CLAUDE.md, README.md | ~100 | What + Where (links) |
| 2 | memory-bank/architecture.md, stack.md | ~100 | How (structure) |
| 3 | memory-bank/lint.md | ~150 | Why (configuration) |
| 4 | rules/*.md | ~200 | Constraints (MUST follow) |

## Markdown Style

### Language

**All Markdown files MUST be written in English.**

### Headings

- Every file MUST start with h1 title
- Use ATX-style headers (`#`, `##`, `###`)
- No skipping levels (h2 → h3 → h4)
- Never use bold text as headings

### Code Blocks

**ALWAYS specify language:**

```bash
echo "good"
```

Common specifiers: `bash`, `text`, `yaml`, `json`, `markdown`

### Links

- Use relative paths for internal links
- Use descriptive link text (not "click here")
- Add "Related Documentation" section at end

```markdown
## Related Documentation

| Document | Content |
|----------|---------|
| [parent.md](../parent.md) | Parent context |
```

### Line Breaks

- **NEVER use trailing spaces** for line breaks
- Use blank lines for paragraph separation
- **No HTML tags** (MD033 enabled)

## Checklist

Before finishing any documentation:

- [ ] Identified document level (1-4)
- [ ] Content matches level's depth
- [ ] Not exceeding line limit
- [ ] No duplication (link instead)
- [ ] Links UP and DOWN to related docs
- [ ] English only
- [ ] Code blocks have language specified
- [ ] Headings use proper hierarchy

## Quick Reference

| Element | Format |
|---------|--------|
| Code block | ` ```bash ` or ` ```text ` |
| Section heading | `### Name` (NOT `**Name**`) |
| Hierarchy | No skipping levels |
| Line break | Blank line (NOT trailing spaces) |
| Duplication | Link, don't copy |
