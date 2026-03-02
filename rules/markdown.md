# Markdown Style Rules

## Language

**All Markdown files in this repository MUST be written in English.**

- No Chinese, Japanese, Korean, or other non-English content
- Comments in code blocks may be in English only
- Variable names and identifiers should use English

## Headings

**Every file MUST start with a h1 title:**

```markdown
# Document Title

Content here...
```

**Exception:** Files with YAML frontmatter (like `SKILL.md`) should have h1 after the frontmatter.

**Use ATX-style headers (`#`, `##`, `###`)**

- One blank line before and after headers
- Never use bold text as headings

```markdown
# Good
### Section Name

Content here

# Bad
**Section Name**

Content here
```

**Maintain heading hierarchy (no skipping levels):**

```markdown
# Good
## Section
### Subsection
#### Detail

# Bad
## Section
#### Detail (skipped h3)
```

**Structure guidelines:**

- Use `##` for main sections
- Use `###` for subsections
- Use `####` sparingly for deep nesting
- Prefer flat structure over deep nesting

## Code Blocks

**ALWAYS specify language for code blocks:**

```bash
# Good
echo "hello"
```

```text
# Good for plain text/output
Some output here
```

NOT:

<!-- markdownlint-disable MD040 -->
```
# Bad - no language specified
echo "hello"
```
<!-- markdownlint-enable MD040 -->

**Common language specifiers:** `bash`, `text`, `yaml`, `json`, `markdown`

## Formatting

- Use `**bold**` for emphasis
- Use `` `code` `` for inline code
- One blank line before and after code blocks
- One blank line before and after lists

## Tables

- Align columns for readability
- Use header separator row

```markdown
| Column 1 | Column 2 |
|----------|----------|
| Value 1  | Value 2  |
```

## Links

- Use relative paths for internal links
- Use descriptive link text (not "click here")

```markdown
# Good
See [CLAUDE.md](CLAUDE.md) for details.

# Bad
Click [here](CLAUDE.md).
```

## Line Breaks

- **NEVER use trailing spaces for line breaks**
- Use blank lines for paragraph separation
- **Do NOT use HTML tags** (MD033 enabled)

```markdown
# Bad - trailing spaces (invisible, fragile)
This is line one.
This is line two.

# Good - blank line
This is line one.

This is line two.
```

## Line Length

- No strict line length limit (MD013 disabled)
- Break long lines at natural points for readability

## Quick Reference

| Element | Format |
|---------|--------|
| Code block | ` ```bash ` or ` ```text ` |
| Section heading | `### Name` (NOT `**Name**`) |
| Hierarchy | No skipping levels (h2 → h3 → h4) |
| Line break | Blank line (NOT trailing spaces) |

## Enforcement

These rules are checked by:

- `markdownlint` with `.markdownlint.json` config
- Pre-commit hooks
- CI pipeline
