# Workflow Rules

## Mandatory Workflow

**ALL feature development MUST follow superpowers workflow:**

```text
BRAINSTORM → WORKTREE → PLAN → EXECUTE → REVIEW → FINISH
     1           2         3        4         5        6
```

## Key Constraints

### Stage 1: BRAINSTORM

- **MUST** invoke `brainstorming` skill
- **Gate**: Design approved, feature branch created
- After approval: Create `feature/{name}` branch, save design.md to `memory-bank/{project}/features/{name}/`

### Stage 2: WORKTREE

- **MUST** invoke `using-git-worktrees` skill
- **Gate**: Worktree created

### Stage 3: PLAN

- **MUST** invoke `writing-plans` skill
- **Gate**: plan.md saved
- After approval: Save plan.md to `memory-bank/{project}/features/{name}/`

### Stage 4: EXECUTE

- **MUST** run `/plan` to initialize planning-with-files
- **MUST** invoke `subagent-driven-development` skill
- **Gate**: All tasks complete

| Mode | How |
|------|-----|
| Supervised | Invoke `subagent-driven-development` directly |
| Autonomous | `/ralph-loop` with `subagent-driven-development` |

### Stage 5: REVIEW

- **MUST** invoke `code-reviewer` agent
- **Gate**: All Critical issues fixed

### Stage 6: FINISH

- **MUST** invoke `finishing-a-development-branch` skill
- **MUST** archive planning-with-files to `memory-bank/{project}/features/{name}/`
- **Gate**: Merge/PR done, files archived, worktree cleaned

## Stage Checklist

- [ ] **BRAINSTORM**: Design approved, feature branch created
- [ ] **WORKTREE**: Working in isolated worktree
- [ ] **PLAN**: Plan approved, plan.md saved
- [ ] **EXECUTE**: All tasks complete
- [ ] **REVIEW**: No Critical issues
- [ ] **FINISH**: Merge/PR done, files archived, worktree cleaned

## Related Documentation

See [memory-bank/workflow.md](../memory-bank/workflow.md) for detailed stage descriptions.
