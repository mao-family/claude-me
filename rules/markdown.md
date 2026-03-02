# Markdown Style Rules

## Language

**All Markdown files in this repository MUST be written in English.**

- No Chinese, Japanese, Korean, or other non-English content
- Comments in code blocks may be in English only
- Variable names and identifiers should use English

## File Structure

- Use ATX-style headers (`#`, `##`, `###`)
- One blank line before and after headers
- One blank line before and after code blocks
- One blank line before and after lists

## Formatting

- Use `**bold**` for emphasis
- Use `\`code\`` for inline code
- Use fenced code blocks with language specifier:
  ```bash
  # Good
  echo "Hello"
  ```

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

## Line Length

- No strict line length limit (MD013 disabled)
- Break long lines at natural points for readability

## Enforcement

These rules are checked by:
- `markdownlint` with `.markdownlint.json` config
- Pre-commit hooks
- CI pipeline
