# Lint Rules

Rules for using and configuring lint tools in this project.

## Never Disable Lint Rules Without Justification

**Do NOT casually disable lint rules.** Every disable must have:

1. A clear reason in a comment
2. The narrowest possible scope

```bash
# Bad - global disable without reason
# shellcheck disable=SC2034

# Bad - disable entire file
# shellcheck disable=all

# Good - inline disable with reason
# shellcheck disable=SC2034  # Variable used by sourced script
readonly MY_VAR="value"
```

```markdown
<!-- Bad - no reason -->
<!-- markdownlint-disable MD040 -->

<!-- Good - with reason and re-enable -->
<!-- markdownlint-disable MD040 -- Example of bad code -->
\`\`\`
bad example
\`\`\`
<!-- markdownlint-enable MD040 -->
```

## Allowed Disables

Only these disables are pre-approved:

| Tool | Rule | Reason |
|------|------|--------|
| ShellCheck | SC1091 | Cannot follow dynamic source paths |
| ShellCheck | SC1003 | False positive in case patterns |
| markdownlint | MD013 | Line length not suitable for Markdown |
| markdownlint | MD043/44 | Heading templates too strict |
| markdownlint | MD060 | Table alignment too strict |

## Adding New Disables

To add a new global disable:

1. Discuss with the team
2. Document the reason in `.shellcheckrc` or `.markdownlint.json`
3. Update this file

## Never Skip Pre-commit

```bash
# NEVER do this
git commit --no-verify

# If a check fails, FIX the issue
```

## Prefer Auto-fix Over Disable

```bash
# Bad - disable formatting check
# shfmt: ignore

# Good - let shfmt fix it
shfmt -w script.sh
```

```bash
# Bad - disable markdownlint
<!-- markdownlint-disable -->

# Good - let markdownlint fix it
bun run lint:markdown  # uses --fix
```

## Report False Positives

If a lint rule consistently produces false positives:

1. Create an issue documenting the problem
2. Add a targeted disable with reference to the issue
3. Consider updating the global config if appropriate
