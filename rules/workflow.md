# Workflow Rules

## Mandatory Workflow

**ALL feature development MUST follow superpowers workflow:**

```text
BRAINSTORM → WORKTREE → PLAN → EXECUTE → REVIEW → FINISH
     1           2         3        4         5        6
```

## Stage Requirements

| # | Stage | Skill/Agent | Gate |
|---|-------|-------------|------|
| 1 | BRAINSTORM | `brainstorming` | Design approved, feature branch created |
| 2 | WORKTREE | `using-git-worktrees` | Worktree created |
| 3 | PLAN | `writing-plans` | plan.md saved |
| 4 | EXECUTE | `subagent-driven-development` | All tasks complete |
| 5 | REVIEW | `code-reviewer` agent | Review passed |
| 6 | FINISH | `finishing-a-development-branch` | Merge/PR done, files archived |

**Gate = Must be satisfied before proceeding to next stage.**

## After BRAINSTORM Approval

**When user approves the design, BEFORE proceeding to WORKTREE:**

1. Create feature branch: `git checkout -b feature/{name}`
2. Save design doc to: `workspace/memory-bank/{project}/features/{name}/design.md`
3. Commit the design doc

**Why:** SessionStart hook loads feature context from this location.

## After PLAN Approval

**When user approves the plan, BEFORE proceeding to EXECUTE:**

1. Save plan to: `workspace/memory-bank/{project}/features/{name}/plan.md`
2. Commit the plan

**Why:** Plan becomes part of feature context for subagents.

## Forbidden Actions

| Action | Why Forbidden |
|--------|---------------|
| Code before PLAN complete | No plan.md = no coding |
| Skip feature branch | Must create feature branch after BRAINSTORM |
| Skip WORKTREE | Must isolate feature work |
| Execute without skill | Must invoke `subagent-driven-development` |
| Skip REVIEW | Must use `code-reviewer` agent after EXECUTE |
| Commit without FINISH skill | Must use `finishing-a-development-branch` |
| Skip any stage | All 6 stages are mandatory |

## Context Management (Before EXECUTE)

**MUST** run `/plan` before EXECUTE stage:

1. Run `/plan` to initialize planning-with-files
2. Creates in worktree root: `task_plan.md`, `findings.md`, `progress.md`
3. Ask user: **Supervised or Autonomous?**

**planning-with-files** provides runtime context management:

| File | Purpose | Hook |
|------|---------|------|
| `task_plan.md` | Phase tracking, decisions | PreToolUse auto-reads |
| `findings.md` | Research, discoveries | Manual update |
| `progress.md` | Session log | Manual update |

## Execution Mode (Stage 4)

| Mode | How | When |
|------|-----|------|
| **Supervised** | Invoke `subagent-driven-development` directly | User present |
| **Autonomous** | Use `/ralph-loop` (see below) | User away |

### Autonomous Mode Command

```text
/ralph-loop "Execute the plan using subagent-driven-development skill. Do NOT ask questions - make reasonable decisions and proceed. When ALL tasks complete, output: <promise>ALL_TASKS_COMPLETE</promise>" --max-iterations 50 --completion-promise "ALL_TASKS_COMPLETE"
```

## Code Review (Stage 5)

**MUST** invoke `code-reviewer` agent after EXECUTE completes:

- Compares implementation against original plan
- Checks code quality, architecture, documentation
- Classifies issues: Critical / Important / Suggestions
- **Gate**: All Critical issues must be fixed before FINISH

## FINISH Stage

**After REVIEW passes, invoke `finishing-a-development-branch`:**

1. Verify tests pass
2. Choose: Merge locally / Create PR / Keep as-is / Discard
3. Archive planning-with-files to memory-bank
4. Clean up worktree (handled by skill)

**Archive command:**

```bash
# Archive runtime context files
cp task_plan.md workspace/memory-bank/{project}/features/{name}/
cp findings.md workspace/memory-bank/{project}/features/{name}/
cp progress.md workspace/memory-bank/{project}/features/{name}/
git add workspace/memory-bank/{project}/features/{name}/
git commit -m "docs: archive {name} feature context"
```

## File Locations Summary

| File | Location During Work | Final Location |
|------|---------------------|----------------|
| design.md | `memory-bank/{project}/features/{name}/` | Same (persistent) |
| plan.md | `memory-bank/{project}/features/{name}/` | Same (persistent) |
| task_plan.md | worktree root | Archived to `memory-bank/` |
| findings.md | worktree root | Archived to `memory-bank/` |
| progress.md | worktree root | Archived to `memory-bank/` |

## Stage Checklist

Before proceeding to next stage, verify:

- [ ] **BRAINSTORM**: Design approved, feature branch created, design.md in `features/{name}/`
- [ ] **WORKTREE**: Working in isolated worktree
- [ ] **PLAN**: Plan approved, plan.md in `features/{name}/`
- [ ] **EXECUTE**: All tasks in plan.md marked complete
- [ ] **REVIEW**: `code-reviewer` agent passed, no Critical issues
- [ ] **FINISH**: Merge/PR complete, planning files archived, worktree cleaned up
