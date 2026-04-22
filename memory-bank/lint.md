# Linting Configuration

## Overview

This project uses **pre-commit** as the entry point for all code quality checks. The linting configuration covers four categories:

1. General file checks
2. Shell script checks
3. Markdown checks
4. Testing

## General File Checks

The following 11 hooks from `pre-commit-hooks` ensure basic file hygiene:

| Hook | Purpose |
|------|---------|
| `trailing-whitespace` | Remove trailing whitespace |
| `end-of-file-fixer` | Ensure files end with newline |
| `check-merge-conflict` | Detect unresolved merge conflicts |
| `check-added-large-files` | Block files larger than 500KB |
| `check-yaml` | Validate YAML syntax |
| `check-json` | Validate JSON syntax |
| `check-case-conflict` | Detect case-insensitive filename conflicts |
| `check-symlinks` | Check for broken symlinks |
| `check-executables-have-shebangs` | Ensure executables have shebangs |
| `check-shebang-scripts-are-executable` | Ensure shebang scripts are executable |
| `detect-private-key` | Prevent committing private keys |

## Shell Checks

### ShellCheck

Static analysis tool for shell scripts. Configuration in `.shellcheckrc`:

**Shell dialect**: Bash

**11 Optional Rules Enabled**:

| Rule | Description |
|------|-------------|
| `add-default-case` | Suggest default case in case statements |
| `avoid-negated-conditions` | Prefer positive conditions |
| `avoid-nullary-conditions` | Avoid empty test conditions |
| `check-extra-masked-returns` | Check masked return values |
| `check-set-e-suppressed` | Detect suppressed `set -e` |
| `check-unassigned-uppercase` | Check unassigned uppercase variables |
| `deprecate-which` | Suggest `command -v` over `which` |
| `quote-safe-variables` | Quote variables that are safe |
| `require-double-brackets` | Use `[[` over `[` |
| `require-variable-braces` | Use `${var}` over `$var` |
| `useless-use-of-cat` | Detect unnecessary `cat` usage |

**Source handling**: External sources enabled, follows SCRIPTDIR

**Disabled rules**:

- `SC1091` - Cannot follow dynamic source (runtime paths)
- `SC1003` - False positive for backslash escaping in case patterns

### shfmt

Shell script formatter. Configuration in `.editorconfig`:

| Setting | Value | Description |
|---------|-------|-------------|
| `indent_style` | space | Use spaces, not tabs |
| `indent_size` | 2 | 2-space indentation |
| `shell_variant` | bash | Bash dialect |
| `binary_next_line` | true | Binary operators on next line |
| `switch_case_indent` | true | Indent case bodies |
| `space_redirects` | true | Space around redirects |
| `keep_padding` | false | Remove extra padding |
| `function_next_line` | false | Opening brace on same line |
| `simplify` | true | Simplify code |

**Pre-commit args**: `-i 2 -ci -sr -bn -w`

For detailed shell style guidance, see [rules/shell/coding-style.md](../rules/shell/coding-style.md).

## Markdown Checks

### markdownlint

Markdown style checker. Configuration in `.markdownlint.json`:

**Rules enabled**: ~46 rules (default: true)

**Rules disabled**:

| Rule | Reason |
|------|--------|
| `MD013` | No line length limit |
| `MD043` | No required heading structure |
| `MD044` | No proper names enforcement |
| `MD060` | Table column count flexibility |

**Key rules configured**:

| Rule | Configuration | Purpose |
|------|--------------|---------|
| `MD003` | `atx` | ATX-style headers (`#`, `##`) |
| `MD004` | `dash` | Dash for unordered lists |
| `MD007` | `indent: 2` | 2-space list indentation |
| `MD024` | `siblings_only: true` | Allow duplicate headings in different sections |
| `MD029` | `ordered` | Ordered list numbering |
| `MD033` | `allowed_elements: []` | No HTML tags allowed |
| `MD035` | `---` | Horizontal rule style |
| `MD040` | `true` | Code blocks must specify language |
| `MD041` | `front_matter_title: ""` | First line must be h1 title |
| `MD046` | `fenced` | Fenced code blocks |
| `MD048` | `backtick` | Backtick code fence style |
| `MD049` | `underscore` | Underscore for emphasis |
| `MD050` | `asterisk` | Asterisk for strong |

For detailed markdown style guidance, see [.markdownlint.json](../.markdownlint.json).

## Testing

Tests run automatically via pre-commit hooks before each commit.

## npm Scripts

Available via `bun run`:

| Script | Command | Purpose |
|--------|---------|---------|
| `lint` | `pre-commit run --all-files` | Run all linters |
| `lint:shell` | `shellcheck scripts/**/*.sh` | Shell lint only |
| `lint:markdown` | `npx markdownlint-cli2 '**/*.md'` | Markdown lint only |
| `lint:format` | `shfmt -d scripts/**/*.sh` | Check shell formatting |

## Quick Reference

```bash
# Run all checks (same as pre-commit)
bun run lint

# Individual checks
bun run lint:shell      # ShellCheck
bun run lint:markdown   # markdownlint
bun run lint:format     # shfmt (diff mode)
```

## Related Documentation

| Document | Content |
|----------|---------|
| [rules/shell/coding-style.md](../rules/shell/coding-style.md) | Shell script style guide |
