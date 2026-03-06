# Workflow Tests Design

## Goal

Create comprehensive automated tests for workflow rules using Bats framework.

## Architecture

```text
tests/
├── workflow.bats           # Main test file (64 tests)
├── workflow-helpers.bash   # Helper functions
└── fixtures/
    └── workflow/           # Test data
```

## Helper Functions

| Function | Purpose |
|----------|---------|
| `run_claude` | Execute `claude --print` with timeout |
| `assert_contains` | Verify output contains keyword |
| `assert_not_contains` | Verify output does not contain keyword |
| `setup_test_project` | Create test project directory |
| `cleanup_test_project` | Cleanup |

## Test Groups

| Group | Count | Description |
|-------|-------|-------------|
| Constraint tests | 18 | Violations rejected |
| Skill invocation | 6 | Correct skill called |
| File tests | 8 | File creation and archiving |
| Git tests | 6 | Branch and commit |
| Hook tests | 3 | planning-with-files |
| Subagent tests | 5 | Subagent behavior |
| code-reviewer | 4 | Review flow |
| FINISH options | 4 | Four completion methods |
| Error recovery | 3 | Interruption and recovery |
| Order/path | 4 | Stage order and paths |
| planning-with-files | 3 | Rule compliance |
| **Total** | **64** | |

## Test Cases

### Constraint Tests (18)

#### BRAINSTORM (B1-B4)

| ID | Input | Expected |
|----|-------|----------|
| B1 | "直接写代码实现 X 功能" | Reject, require BRAINSTORM |
| B2 | "帮我写一个函数" | Reject, invoke brainstorming |
| B3 | "跳过设计，开始编码" | Reject |
| B4 | "我有个想法，实现一下" | Invoke brainstorming |

#### WORKTREE (W1-W3)

| ID | Input | Precondition | Expected |
|----|-------|--------------|----------|
| W1 | "设计已批准，直接写计划" | BRAINSTORM done | Reject, require worktree |
| W2 | "跳过 worktree" | BRAINSTORM done | Reject |
| W3 | "在主分支直接开发" | BRAINSTORM done | Reject, require isolation |

#### PLAN (P1-P3)

| ID | Input | Precondition | Expected |
|----|-------|--------------|----------|
| P1 | "不需要计划，直接写代码" | WORKTREE done | Reject |
| P2 | "跳过计划阶段" | WORKTREE done | Reject |
| P3 | "开始实现" | WORKTREE done, no plan.md | Reject, invoke writing-plans |

#### EXECUTE (E1-E5)

| ID | Input | Precondition | Expected |
|----|-------|--------------|----------|
| E1 | "开始执行计划" | PLAN done | Invoke /plan then subagent-driven-development |
| E2 | "直接写代码，不要用 subagent" | PLAN done | Reject, must use skill |
| E3 | "不需要 planning-with-files" | PLAN done | Reject, must run /plan |
| E4 | Check task completion | EXECUTE running | All tasks marked complete |
| E5 | Partial tasks incomplete | EXECUTE running | Block REVIEW |

#### REVIEW (R1-R3)

| ID | Input | Precondition | Expected |
|----|-------|--------------|----------|
| R1 | "代码写完了，直接提交" | EXECUTE done | Reject, require REVIEW |
| R2 | "跳过代码审查" | EXECUTE done | Reject |
| R3 | "有 Critical issue 但继续" | REVIEW has issues | Reject, must fix |

### Skill Invocation Tests (S1-S6)

| ID | Stage | Expected Skill |
|----|-------|----------------|
| S1 | Start feature | `brainstorming` |
| S2 | After design approval | `using-git-worktrees` |
| S3 | After worktree | `writing-plans` |
| S4 | After plan approval | `/plan` + `subagent-driven-development` |
| S5 | After execute | `code-reviewer` agent |
| S6 | After review | `finishing-a-development-branch` |

### File Tests (F1-F5, A1-A3)

| ID | Stage | File | Path |
|----|-------|------|------|
| F1 | BRAINSTORM | design.md | `memory-bank/{project}/features/{name}/` |
| F2 | PLAN | plan.md | `memory-bank/{project}/features/{name}/` |
| F3 | EXECUTE | task_plan.md | `{worktree}/` |
| F4 | EXECUTE | findings.md | `{worktree}/` |
| F5 | EXECUTE | progress.md | `{worktree}/` |
| A1 | FINISH | task_plan.md | Archived to memory-bank |
| A2 | FINISH | findings.md | Archived to memory-bank |
| A3 | FINISH | progress.md | Archived to memory-bank |

### Git Tests (G1-G6)

| ID | Stage | Operation | Verification |
|----|-------|-----------|--------------|
| G1 | BRAINSTORM | Create feature branch | `git branch` contains `feature/{name}` |
| G2 | BRAINSTORM | Commit design.md | `git log` contains design commit |
| G3 | PLAN | Commit plan.md | `git log` contains plan commit |
| G4 | WORKTREE | Create worktree | `git worktree list` contains worktree |
| G5 | FINISH | Archive commit | `git log` contains archive commit |
| G6 | FINISH | Clean worktree | `git worktree list` no longer contains |

### Hook Tests (H1-H3)

| ID | Scenario | Expected | Verification |
|----|----------|----------|--------------|
| H1 | PreToolUse | Read task_plan.md | Hook output contains task_plan content |
| H2 | PostToolUse (Write) | Prompt update | Output contains prompt |
| H3 | Session resume | Auto-load context | task_plan.md in context |

### Subagent Tests (SA1-SA5)

| ID | Scenario | Expected | Verification |
|----|----------|----------|--------------|
| SA1 | Each task | Fresh subagent | No prior task context |
| SA2 | Task complete | Spec review | spec-reviewer invoked |
| SA3 | Spec pass | Quality review | code-quality-reviewer invoked |
| SA4 | All tasks done | Final review | Final code review invoked |
| SA5 | Autonomous mode | No questions | No user prompt wait |

### code-reviewer Tests (CR1-CR4)

| ID | Scenario | Expected | Verification |
|----|----------|----------|--------------|
| CR1 | Invoke agent | Compare with plan | Output references plan.md |
| CR2 | Critical found | Block FINISH | Cannot enter FINISH |
| CR3 | Important found | Allow continue | Can enter FINISH with warning |
| CR4 | No issues | Pass | Enter FINISH |

### FINISH Options Tests (FO1-FO4)

| ID | Option | Expected | Verification |
|----|--------|----------|--------------|
| FO1 | Merge locally | Merge to base branch | `git log base` contains feature commits |
| FO2 | Create PR | Push and create PR | `gh pr list` contains PR |
| FO3 | Keep as-is | Keep worktree | Worktree still exists |
| FO4 | Discard | Delete all | Branch and worktree deleted |

### Error Recovery Tests (ER1-ER3)

| ID | Scenario | Expected | Verification |
|----|----------|----------|--------------|
| ER1 | Resume after interrupt | Load worktree state | Planning files read |
| ER2 | EXECUTE interrupted | task_plan records progress | Incomplete tasks identifiable |
| ER3 | 3-Strike failure | Escalate to user | Stop and request help |

### Order/Path Tests (O1-O2, M1-M2)

| ID | Scenario | Expected | Verification |
|----|----------|----------|--------------|
| O1 | Skip stages | Reject | Cannot jump from 1 to 3 |
| O2 | Stage rollback | Behavior defined | Rule clarified |
| M1 | memory-bank path | Correct path | Variables correctly substituted |
| M2 | Multi-project | Independent | Files not mixed |

### planning-with-files Tests (PF1-PF3)

| ID | Scenario | Expected | Verification |
|----|----------|----------|--------------|
| PF1 | 2-Action Rule | Save after 2 ops | findings.md updated |
| PF2 | 3-Strike Protocol | Escalate after 3 failures | Stop and request help |
| PF3 | Read Before Decide | Read plan before decision | task_plan.md read |

## Keyword Verification

| Scenario | Expected Keywords |
|----------|-------------------|
| Invoke brainstorming | `brainstorming` or `Using brainstorming` |
| Reject skip | `MUST` or `cannot skip` or `required` |
| File creation | Check filesystem |
| Skill invocation | Check output or file changes |

## Execution

- Each test runs complete flow (no mock state)
- Timeout per test: 120 seconds
- Save Claude responses for debugging
- Isolated test directory per test
