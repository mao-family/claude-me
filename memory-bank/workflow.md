# Development Workflow

## Overview

All feature development follows a mandatory 6-stage workflow powered by superpowers plugin.

## The Workflow

```text
BRAINSTORM → WORKTREE → PLAN → EXECUTE → REVIEW → FINISH
     1           2         3        4         5        6
```

## Stage Details

### Stage 1: BRAINSTORM

**Skill:** `brainstorming`

**Purpose:** Turn ideas into fully formed designs through collaborative dialogue.

**Process:**

1. Claude checks project context (files, docs, recent commits)
2. Asks questions one at a time (prefer multiple choice)
3. Proposes 2-3 approaches with trade-offs
4. Presents design in 200-300 word sections, validating each
5. User approves the design

**Output:** `design.md` saved to `memory-bank/{project}/features/{name}/`

**Gate:** Design approved, feature branch created (`git checkout -b feature/{name}`)

### Stage 2: WORKTREE

**Skill:** `using-git-worktrees`

**Purpose:** Create isolated workspace for feature development.

**Process:**

1. Create git worktree for the feature branch
2. Switch to worktree directory

**Output:** Isolated workspace at worktree path

**Gate:** Working in isolated worktree

### Stage 3: PLAN

**Skill:** `writing-plans`

**Purpose:** Create detailed implementation plan with bite-sized TDD tasks.

**Process:**

1. Write comprehensive plan assuming zero codebase context
2. Each task is one action (2-5 minutes)
3. Include exact file paths, complete code, exact commands
4. Follow DRY, YAGNI, TDD principles

**Task Structure:**

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**
**Step 2: Run test to verify it fails**
**Step 3: Write minimal implementation**
**Step 4: Run test to verify it passes**
**Step 5: Commit**
```

**Output:** `plan.md` saved to `memory-bank/{project}/features/{name}/`

**Gate:** Plan approved by user

### Stage 4: EXECUTE

**Skill:** `subagent-driven-development`

**Purpose:** Execute plan with fresh subagent per task and two-stage review.

**Before Starting:**

1. Run `/plan` to initialize planning-with-files
2. Creates `task_plan.md`, `findings.md`, `progress.md` in worktree root
3. Choose mode: Supervised or Autonomous

**Per Task Process:**

```text
Dispatch Implementer Subagent
         ↓
Answer questions if any
         ↓
Implementer: implement + test + commit + self-review
         ↓
Dispatch Spec Reviewer Subagent
         ↓
Spec compliant? → No → Implementer fixes → Re-review
         ↓ Yes
Dispatch Code Quality Reviewer Subagent
         ↓
Quality approved? → No → Implementer fixes → Re-review
         ↓ Yes
Mark task complete
```

**After All Tasks:**

- Dispatch final code reviewer for entire implementation

**Execution Modes:**

| Mode | How | When |
|------|-----|------|
| Supervised | Invoke `subagent-driven-development` directly | User present |
| Autonomous | `/ralph-loop` (see below) | User away |

**Autonomous Command:**

```text
/ralph-loop "Execute the plan using subagent-driven-development skill. Do NOT ask questions - make reasonable decisions and proceed. When ALL tasks complete, output: <promise>ALL_TASKS_COMPLETE</promise>" --max-iterations 50 --completion-promise "ALL_TASKS_COMPLETE"
```

**Gate:** All tasks in plan.md marked complete

### Stage 5: REVIEW

**Agent:** `code-reviewer`

**Purpose:** Review completed implementation against original plan.

**Process:**

1. Compare implementation against plan
2. Check code quality, architecture, documentation
3. Classify issues: Critical / Important / Suggestions

**Issue Categories:**

| Category | Action |
|----------|--------|
| Critical | Must fix before FINISH |
| Important | Should fix |
| Suggestions | Nice to have |

**Gate:** All Critical issues resolved

### Stage 6: FINISH

**Skill:** `finishing-a-development-branch`

**Purpose:** Complete development work with structured options.

**Process:**

1. Verify tests pass
2. Present 4 options:
   - Merge back to base branch locally
   - Push and create Pull Request
   - Keep branch as-is
   - Discard work
3. Execute chosen option
4. Archive planning-with-files to memory-bank
5. Clean up worktree

**Archive Command:**

```bash
cp task_plan.md memory-bank/features/{name}/
cp findings.md memory-bank/features/{name}/
cp progress.md memory-bank/features/{name}/
git add memory-bank/features/{name}/
git commit -m "docs: archive {name} feature context"
```

**Gate:** Merge/PR complete, planning files archived, worktree cleaned up

## Key Integrations

### superpowers

Core workflow engine providing all stage skills:

- `brainstorming` - Collaborative design exploration
- `using-git-worktrees` - Isolated workspace management
- `writing-plans` - Bite-sized TDD task planning
- `subagent-driven-development` - Fresh subagent per task + two-stage review
- `code-reviewer` agent - Plan alignment and quality review
- `finishing-a-development-branch` - Structured completion options

### planning-with-files

Runtime context management during EXECUTE stage:

| File | Purpose | Hook |
|------|---------|------|
| `task_plan.md` | Phase tracking, decisions | PreToolUse auto-reads first 30 lines |
| `findings.md` | Research discoveries | Manual update (2-Action Rule) |
| `progress.md` | Session log | Manual update |

**Key Rules:**

- **2-Action Rule:** After every 2 operations, save key findings
- **3-Strike Protocol:** After 3 failures on same issue, escalate to user
- **Never Repeat Failures:** Track attempts, mutate approach

### ralph-wiggum

Autonomous execution mode:

- Stop hook mechanism for auto-continue loops
- Wraps `subagent-driven-development` in unattended execution
- Use completion promise to signal when done

## File Locations

| File | During Work | After FINISH |
|------|-------------|--------------|
| design.md | `memory-bank/{project}/features/{name}/` | Same (persistent) |
| plan.md | `memory-bank/{project}/features/{name}/` | Same (persistent) |
| task_plan.md | worktree root | Archived to memory-bank |
| findings.md | worktree root | Archived to memory-bank |
| progress.md | worktree root | Archived to memory-bank |

## Recovery Scenarios

### Session Interrupted

Worktree and all files persist. On resume:

1. `cd` to worktree
2. planning-with-files hook auto-reads `task_plan.md`
3. Continue from last state

### Feature Abandoned

If user decides not to continue:

1. `git worktree remove <path>` to clean up
2. Optionally delete feature branch
3. planning-with-files files are lost (not archived)

## Related Documentation

| Document | Content |
|----------|---------|
| [../rules/common/workflow.md](../rules/common/workflow.md) | Mandatory rules and gates |
| [architecture.md](architecture.md) | System architecture |
