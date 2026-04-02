# Skills

Workflow guides loaded on-demand by Claude Code.

## Structure

```text
skills/
├── README.md                      # This file
├── find-skills/
│   └── SKILL.md                   # Discover and install skills
├── labs-content-update/
│   └── SKILL.md                   # Copilot Labs content management
├── managing-workspace/
│   └── SKILL.md                   # Workspace repo management
├── notebooklm/
│   └── SKILL.md                   # NotebookLM automation (requires external CLI)
├── research/
│   └── SKILL.md                   # Systematic research workflow
├── writing-claude-md/
│   └── SKILL.md                   # CLAUDE.md file creation
└── zork/
    ├── SKILL.md                   # Zork text adventure game
    └── bin/
        ├── zork.sh                # Shell wrapper
        ├── zork1.z3               # Game file
        └── dfrotz/                # Platform binaries
```

## Changelog

### notebooklm

| Date | Change |
|------|--------|
| 2026-03-07 | Initial setup - full programmatic access to Google NotebookLM |

**Dependencies:** Requires `notebooklm-py` CLI tool.

```bash
pipx install "notebooklm-py[browser]"
notebooklm login  # First-time authentication
```

### labs-content-update

| Date | Change |
|------|--------|
| 2026-03-04 | Added: Check Progress / Resume workflow - detect state from GitHub PRs and workflows |
| 2026-03-04 | Added: List experiments - structured table view of all experiments |
| 2026-03-04 | Added: View experiment details - full metadata, covers, links, and landing page |
| 2026-03-04 | Fixed: Production workflow creates both picasso PR and studio PR simultaneously |
| 2026-03-04 | Fixed: Distinguish staging vs production PRs by checking changed files |
| 2026-03-04 | Updated: State Detection Matrix with more granular states |
| 2026-03-04 | Updated: Progress Report format with complete pipeline status |

### find-skills

| Date | Change |
|------|--------|
| 2026-02-XX | Initial setup |

### managing-workspace

| Date | Change |
|------|--------|
| 2026-02-XX | Initial setup |

### research

| Date | Change |
|------|--------|
| 2026-02-XX | Initial setup |

### writing-claude-md

| Date | Change |
|------|--------|
| 2026-02-XX | Initial setup |

### zork

| Date | Change |
|------|--------|
| 2026-04-02 | Initial release - Zork I text adventure with cross-platform support |

## Todo

### labs-content-update

- [ ] Add batch operations (update multiple experiments at once)
- [ ] Add experiment archiving workflow
- [ ] Add schema diff viewer (compare local vs Studio schema)
- [ ] Add Slack notifications for pipeline status changes
- [ ] Add rollback workflow (revert to previous config)
- [ ] Create HTML preview page for landing page content (user edits markdown, sees live preview)
- [ ] Add landing page content optimization skill (improve copy, SEO, accessibility)

### find-skills

- [ ] (none)

### managing-workspace

- [ ] (none)

### research

- [ ] (none)

### writing-claude-md

- [ ] (none)

### zork

- [ ] Add more Z-machine games (Zork II, Hitchhiker's Guide)
- [ ] Build dfrotz binaries for all platforms (darwin-x64, linux-arm64, linux-x64, win32-x64)
