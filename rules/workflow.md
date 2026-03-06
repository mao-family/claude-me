# Workflow Rules

## Mandatory Workflow

**ALL feature development MUST follow this exact sequence:**

```text
BRAINSTORM → WORKTREE → PLAN → EXECUTE → FINISH
     1           2         3        4         5
```

## Stage Requirements

| # | Stage | Skill | Gate |
|---|-------|-------|------|
| 1 | BRAINSTORM | `brainstorming` | Design doc saved |
| 2 | WORKTREE | `using-git-worktrees` | Worktree created |
| 3 | PLAN | `writing-plans` | plan.md saved |
| 4 | EXECUTE | `subagent-driven-development` | All tasks complete |
| 5 | FINISH | `finishing-a-development-branch` | Merge/PR done |

**Gate = Must be satisfied before proceeding to next stage.**

## Forbidden Actions

| Action | Why Forbidden |
|--------|---------------|
| Code before PLAN complete | No plan.md = no coding |
| Skip WORKTREE | Must isolate feature work |
| Execute without skill | Must invoke `subagent-driven-development` |
| Commit without FINISH skill | Must use `finishing-a-development-branch` |
| Skip any stage | All 5 stages are mandatory |

## Context Management (Before EXECUTE)

**MUST** run `/plan` before EXECUTE stage:

1. Run `/plan` to initialize planning-with-files
2. Creates: `task_plan.md`, `findings.md`, `progress.md`
3. Ask user: **Supervised or Autonomous?**

## Execution Mode (Stage 4)

| Mode | How | When |
|------|-----|------|
| **Supervised** | Invoke `subagent-driven-development` directly | User present |
| **Autonomous** | Use `/ralph-loop` (see below) | User away |

### Autonomous Mode Command

```text
/ralph-loop "Execute the plan using subagent-driven-development skill. Do NOT ask questions - make reasonable decisions and proceed. When ALL tasks complete, output: <promise>ALL_TASKS_COMPLETE</promise>" --max-iterations 50 --completion-promise "ALL_TASKS_COMPLETE"
```

## Stage Checklist

Before proceeding to next stage, verify:

- [ ] **BRAINSTORM**: Design doc committed to `docs/plans/`
- [ ] **WORKTREE**: Working in isolated worktree
- [ ] **PLAN**: plan.md committed to `docs/plans/`
- [ ] **EXECUTE**: All tasks in plan.md marked complete
- [ ] **FINISH**: Merge/PR complete, worktree cleaned up
