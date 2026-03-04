# Using Lint Tools

## Fix First, Disable Last

**Priority order when lint fails:**

1. **Auto-fix** - Check `package.json` for scripts with `fix` in the name
2. **Manual fix** - Refactor code to satisfy the rule
3. **Disable** - Only as last resort, with justification

**Every disable must have:**

1. A clear reason in a comment
2. The narrowest possible scope (prefer `next-line` over `disable`)

## Disable Syntax by Tool

### Shell (ShellCheck)

```bash
# Bad
# shellcheck disable=SC2034

# Good
# shellcheck disable=SC2034  # Variable used by sourced script
readonly MY_VAR="value"
```

### Markdown (markdownlint)

```markdown
<!-- Bad -->
<!-- markdownlint-disable MD040 -->

<!-- Good -->
<!-- markdownlint-disable MD040 -- Example of bad code -->
```

### TypeScript/ESLint

```typescript
// Bad - no rule, no reason
// eslint-disable-next-line

// Bad - no reason
// eslint-disable-next-line @typescript-eslint/naming-convention

// Good - specific rule and reason
// eslint-disable-next-line @typescript-eslint/naming-convention -- OAuth spec requires snake_case
const access_token = response.access_token;
```

### TypeScript Type Errors

Use `@ts-expect-error` (not `@ts-ignore`) with a reason:

```typescript
// Bad - silently ignores forever
// @ts-ignore

// Good - self-cleaning, will error when type is fixed
// @ts-expect-error -- MSAL scopes is undocumented internal property
const scopes = token.scopes;
```

## Pre-approved Disables

These rules can be disabled without additional justification:

| Tool | Rule | Reason |
|------|------|--------|
| ShellCheck | SC1091 | Cannot follow dynamic source paths |
| ShellCheck | SC1003 | False positive in case patterns |
| markdownlint | MD013 | Line length not suitable for Markdown |
| markdownlint | MD043/44 | Heading templates too strict |
| markdownlint | MD060 | Table alignment too strict |

## Never Skip Pre-commit

```bash
# NEVER do this
git commit --no-verify

# If a check fails, FIX the issue
```
