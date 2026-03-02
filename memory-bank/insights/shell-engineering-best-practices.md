# Shell/Plugin Project Engineering Best Practices - Insights

**Source**: Cross-comparison analysis of 13 excellent projects
**Applicable**: claude-me and similar Shell + Claude Code plugin projects

---

## Core Findings

### 1. Layered Configuration Architecture is Optimal

```
Common Layer (common/) → Language Layer (typescript/, shell/) → Project Layer (local/)
```

**Effect**: 50%+ reduction in duplication, easy to maintain and extend

### 2. Hook-Driven Automation > Manual Memory

All top-tier projects use hook automation:
- Shell: pre-commit hooks
- Claude Code: SessionStart, PreToolUse, PostToolUse

**Effect**: Zero manual operations, quality gates enforced

### 3. TDD is Non-Negotiable

| Project | Coverage Target | Enforcement |
|---------|-----------------|-------------|
| everything-claude-code | 80% | Rule-enforced |
| superpowers | N/A | Skill-enforced |
| asdf | N/A | CI failure |

---

## Recommended Tool Stack for claude-me

| Category | Tool | Version | Config File |
|----------|------|---------|-------------|
| **Linting** | ShellCheck | 0.9.0+ | `.shellcheckrc` |
| **Formatting** | shfmt | 3.7.0+ | `.editorconfig` |
| **Testing** | Bats-core | 1.13.0+ | `tests/*.bats` |
| **Pre-commit** | pre-commit | 3.5.0+ | `.pre-commit-config.yaml` |
| **Markdown** | markdownlint | 0.39.0+ | `.markdownlint.json` |
| **Commits** | Commitlint | 19.0+ | `commitlint.config.js` |
| **CI/CD** | GitHub Actions | - | `.github/workflows/` |
| **Release** | Release-Please | - | `release-please.yml` |

---

## Recommended Configurations

### .shellcheckrc

```bash
# Specify shell dialect
shell=bash

# Disable specific warnings (as needed)
disable=SC2086,SC2046

# Enable external sources
external-sources=true

# Source path
source-path=.
```

### .editorconfig

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.sh]
indent_style = space
indent_size = 2

[*.md]
indent_style = space
indent_size = 2
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
```

### .markdownlint.json

```json
{
  "default": true,
  "MD013": false,
  "MD033": false,
  "MD041": false,
  "MD024": { "siblings_only": true }
}
```

### .pre-commit-config.yaml

```yaml
repos:
  - repo: https://github.com/koalaman/shellcheck-py
    rev: v0.9.0.2
    hooks:
      - id: shellcheck
        args: [-x]

  - repo: https://github.com/scop/pre-commit-shfmt
    rev: v3.7.0-1
    hooks:
      - id: shfmt
        args: [-i, '2', -ci, -w]

  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.39.0
    hooks:
      - id: markdownlint
        args: [--fix]

  - repo: local
    hooks:
      - id: bats-tests
        name: Run Bats Tests
        entry: bash -c 'bats tests/*.bats'
        language: system
        pass_filenames: false
        stages: [commit]
```

### commitlint.config.js

```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'chore', 'ci', 'build', 'revert']
    ],
    'subject-case': [2, 'never', ['sentence-case', 'start-case', 'pascal-case', 'upper-case']],
    'header-max-length': [2, 'always', 100]
  }
}
```

---

## Recommended Project Structure

```
claude-me/
├── .github/
│   └── workflows/
│       └── ci.yml              # CI/CD
├── hooks/                      # Claude Code hooks
│   ├── hooks.json
│   └── *.sh
├── skills/                     # Skills (Markdown)
│   └── {name}/SKILL.md
├── agents/                     # Agents (Markdown)
├── rules/                      # Coding standards
│   └── shell.md
├── scripts/                    # Utility scripts
├── tests/                      # Bats tests
│   ├── *.bats
│   └── run-all.sh
├── memory-bank/               # Project knowledge
│   └── research/
├── workspace/                 # Child projects
│
├── .editorconfig              # Editor config
├── .shellcheckrc              # ShellCheck config
├── .markdownlint.json         # Markdownlint config
├── .pre-commit-config.yaml    # Pre-commit hooks
├── commitlint.config.js       # Commit lint
├── Makefile                   # Build commands
├── CLAUDE.md                  # AI instructions
├── CONTRIBUTING.md            # Contribution guide
└── README.md                  # Documentation
```

---

## Makefile Template

```makefile
.PHONY: install lint format test check all

# Install dependencies
install:
	brew install shellcheck shfmt bats-core pre-commit
	pre-commit install
	pre-commit install --hook-type commit-msg

# Lint code
lint:
	shellcheck -x hooks/*.sh scripts/*.sh tests/*.sh

# Format code
format:
	shfmt -i 2 -ci -w hooks/*.sh scripts/*.sh

# Format check (for CI)
format-check:
	shfmt -i 2 -ci -d hooks/*.sh scripts/*.sh

# Run tests
test:
	bats tests/*.bats

# Markdown lint
lint-md:
	markdownlint "**/*.md"

# Full check
check: lint format-check lint-md test
	@echo "All checks passed!"

# Default target
all: check
```

---

## GitHub Actions CI

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install ShellCheck
        run: sudo apt-get install -y shellcheck

      - name: ShellCheck
        run: shellcheck -x hooks/*.sh scripts/*.sh tests/*.sh

  format:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install shfmt
        run: |
          GO111MODULE=on go install mvdan.cc/sh/v3/cmd/shfmt@latest
          echo "$(go env GOPATH)/bin" >> $GITHUB_PATH

      - name: Check formatting
        run: shfmt -i 2 -ci -d hooks/*.sh scripts/*.sh

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Bats
        run: |
          git clone https://github.com/bats-core/bats-core.git
          cd bats-core && sudo ./install.sh /usr/local

      - name: Run tests
        run: bats tests/*.bats

  markdown:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Markdownlint
        uses: articulate/actions-markdownlint@v1
        with:
          config: .markdownlint.json
          files: '**/*.md'
```

---

## Implementation Plan

### Week 1: Basic Tools

1. Install tools: `brew install shellcheck shfmt bats-core pre-commit`
2. Add config files: `.shellcheckrc`, `.editorconfig`
3. Run initial check: `shellcheck hooks/*.sh`
4. Fix warnings

### Week 2: Automation

1. Add `.pre-commit-config.yaml`
2. Install hooks: `pre-commit install`
3. Add Makefile
4. Test complete workflow

### Week 3: Testing

1. Migrate existing tests to Bats format
2. Add new test cases
3. Target: 80% coverage

### Week 4: CI/CD

1. Add GitHub Actions
2. Configure Commitlint
3. Optional: Release-Please

---

## Expected Improvements

| Aspect | Expected Improvement |
|--------|---------------------|
| Code Quality | ↑ 50-70% |
| Development Speed | ↑ 20-30% |
| Maintainability | ↑ 60-80% |
| Bug Detection | ↑ 80%+ |

---

## Reference Projects

| Project | Stars | Learning Focus |
|---------|-------|----------------|
| oh-my-zsh | 171k | Modular architecture |
| nvm | 77k | Cross-platform compatibility |
| asdf | 21k | Testing framework |
| everything-claude-code | 55k | Layered rules |
| superpowers | 64k | Workflow enforcement |
