---
name: labs-content-update
description: Use when updating labs-content experiment configs, syncing schema changes from Studio PRs, publishing to staging/production, checking progress, or listing/viewing experiments. Triggers on "update labs content", "sync schema from studio", "publish staging", "publish production", "check labs progress", "resume labs update", "list experiments", "show experiment", "experiment details".
---

# Labs Content Update

## Overview

Workflow for updating Copilot Labs experiment configurations, syncing schema changes from Studio repository, and publishing through the pipeline.

## When to Use

- Updating experiment metadata (title, description, links, covers)
- Syncing schema changes from `infinity-microsoft/studio` PRs
- Adding new experiments
- Disabling/enabling experiments
- Publishing content to staging or production
- **Check progress** of an in-flight update and resume from current step
- **List experiments** or **view experiment details**

## First: Ask What Type of Update

**ALWAYS ask the user which operation they need:**

| Operation | Files to Modify | Special Steps |
|-----------|-----------------|---------------|
| **Add new experiment** | Create `content/original/{name}/` with metadata.json + landing-page.md, update `settings.json` | Allocate new ID |
| **Modify experiment** | Edit `content/original/{name}/metadata.json` or `landing-page.md` | None |
| **Graduate experiment** | Set `status: "GRADUATED"` in metadata.json | Experiment graduates from Labs |
| **Sync schema from Studio** | Update `config.schema.json` + `metadata.schema.json` | Read via `gh api` |
| **Disable/Enable experiment** | Set `enabled` in `settings.json` | Content stays intact |
| **Update covers/media** | Edit `covers` array in metadata.json | Use predictable CDN URL |
| **Check progress / Resume** | N/A | Detect state from GitHub |
| **List experiments** | N/A | Read settings.json + metadata |
| **View experiment details** | N/A | Read metadata.json + landing-page.md |

## Content Pipeline

```text
original/ → generated/ → dist/ → publish
```

| Stage | Directory | Description |
|-------|-----------|-------------|
| Source | `content/original/{experiment}/` | metadata.json + landing-page.md |
| Build | `content/generated/` | Intermediate configs |
| Release | `content/dist/` | Merged configs by locale |
| Publish | picasso-assets / studio | CDN and frontend repos |

## Complete Workflow

| Step | Action | State Indicator |
|------|--------|-----------------|
| 0 | Check if Studio schema needs sync | - |
| 1 | Collect info: what to update, new values | - |
| 2 | Sync schema if needed | Local files changed |
| 3 | Edit files based on user input | Local files changed |
| 4 | Run `npm run test:integration` | Tests pass |
| 5 | Update baselines if needed | Tests pass |
| 6 | Create branch, commit, push, create PR | PR open in labs-content |
| 7 | Tell user PR URL, remind to merge | PR open |
| 8 | Watch PR until merged (poll every 1 hour, auto-merge if approved) | PR merged |
| 9 | Watch Release workflow until complete | Release branch exists |
| **Staging** | | |
| 10 | Trigger Publish: Staging | Staging workflow running |
| 11 | Watch Staging workflow, tell user picasso-assets PR URL | Staging workflow done |
| 12 | Watch picasso-assets PR until merged | picasso PR merged |
| 13 | Tell user to verify at <https://www.copilot-stg.com/labs> | User confirms |
| 14 | Ask: "Staging verified. Publish to Production?" | User confirms |
| **Production** | | |
| 15 | Trigger Publish: Production | Production workflow running |
| 16 | Watch Production workflow (creates BOTH picasso PR + studio PR) | Production workflow done |
| 17 | Watch picasso-assets PR (production) until merged | picasso PR merged -> **Live** |
| 18 | Tell user to verify at <https://www.copilot.microsoft.com/labs> | User confirms |
| 19 | Remind user to merge studio PR (i18n + fallback, can be async) | studio PR merged |

### Watch PR / Workflow Commands

```bash
# Check PR state and auto-merge if ready
gh pr view <pr-number> --repo <repo> --json state,mergedAt,reviewDecision,mergeable
gh pr merge <pr-number> --repo <repo> --merge  # If approved + mergeable

# Watch workflow until complete
gh run list --repo <repo> --workflow "<workflow-name>" --limit 1 --json databaseId --jq '.[0].databaseId'
gh run watch <run-id> --repo <repo>
```

## Operations Reference

### List Experiments

```bash
# Read settings.json for IDs and enabled status
gh api repos/infinity-microsoft/labs-content/contents/settings.json \
  --jq '.content' | base64 -d | jq '.experiments'

# List all experiment directories
gh api repos/infinity-microsoft/labs-content/contents/content/original \
  --jq '.[].name'

# Read a specific experiment's metadata
gh api repos/infinity-microsoft/labs-content/contents/content/original/{alias}/metadata.json \
  --jq '.content' | base64 -d | jq .
```

#### List View Format

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Copilot Labs Experiments                           │
├────┬───────────────────────────┬─────────┬───────────┬─────────┬────────────┤
│ ID │ Alias                     │ Type    │ Status    │ Enabled │ Name       │
├────┼───────────────────────────┼─────────┼───────────┼─────────┼────────────┤
│  0 │ copilot-vision            │ FEATURE │ LIVE      │ ✅      │ Copilot... │
│  1 │ copilot-gaming-experiences│ PROJECT │ LIVE      │ ✅      │ Copilot... │
└────┴───────────────────────────┴─────────┴───────────┴─────────┴────────────┘

Summary: N experiments (X enabled, Y disabled)
         FEATURE: X | PROJECT: Y
         LIVE: X | GRADUATED: Y | NOTSET: Z
```

### View Experiment Details

```bash
# Read metadata.json
gh api repos/infinity-microsoft/labs-content/contents/content/original/{alias}/metadata.json \
  --jq '.content' | base64 -d | jq .

# Read landing page
gh api repos/infinity-microsoft/labs-content/contents/content/original/{alias}/landing-page.md \
  --jq '.content' | base64 -d
```

#### Detail View Format

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│ {alias}                                                                     │
├─────────────┬───────────────────────────────────────────────────────────────┤
│ ID          │ {id}                                                          │
│ Enabled     │ ✅/❌                                                          │
│ Name        │ {name}                                                        │
│ Type        │ FEATURE/PROJECT                                               │
│ Status      │ LIVE/GRADUATED/NOTSET/...                                     │
│ Order       │ {order}                                                       │
│ isMaster    │ true/false                                                    │
└─────────────┴───────────────────────────────────────────────────────────────┘

Description:
┌───────┬─────────────────────────────────────────────────────────────────────┐
│ Title │ {title}                                                             │
│ Short │ {short description}                                                 │
│ Long  │ {filename} (see Landing Page below)                                 │
└───────┴─────────────────────────────────────────────────────────────────────┘

Covers:
┌───────┬───────────┬──────────────┬──────────────────────────────────────────┐
│ Type  │ Size      │ Consumers    │ URL                                      │
├───────┼───────────┼──────────────┼──────────────────────────────────────────┤
│ IMAGE │ 643×360   │ HOMEPAGE     │ https://...                              │
│ VIDEO │ 1920×930  │ LANDING_PAGE │ https://...                              │
└───────┴───────────┴──────────────┴──────────────────────────────────────────┘

Links:
┌──────────────┬────────────────┬───────────────────────┬────────┐
│ Type         │ Trigger        │ Target                │ Scopes │
├──────────────┼────────────────┼───────────────────────┼────────┤
│ PROJECT_LINK │ TRY_NOW_BUTTON │ /labs/{alias}         │ ALL    │
└──────────────┴────────────────┴───────────────────────┴────────┘

Files:
content/original/{alias}/
├── metadata.json
└── landing-page.md

Landing Page:
{content of landing-page.md in markdown code block}
```

### Check Progress / Resume Workflow

**CRITICAL: Track ALL in-flight updates, not just the latest one.**

#### Step 1: Collect All Recent Release Branches

```bash
# Get all release branches
gh api repos/infinity-microsoft/labs-content/branches --paginate \
  --jq '.[] | select(.name | startswith("release/")) | .name' | tail -10
```

#### Step 2: For Each Release Branch, Build Complete Tracking Chain

Each release branch represents one update. Track its full pipeline:

```bash
# 1. Find the labs-content PR that created this release
#    Release branch timestamp indicates when PR was merged
#    Example: release/2026-02-26-091642 -> PR merged around 2026-02-26 09:16

# 2. Find associated picasso-assets PRs by searching title and checking files
gh pr list --repo infinity-microsoft/picasso-assets --state all --search "labs" --limit 20 \
  --json number,title,state,mergedAt,createdAt

# 3. For each picasso PR, check if it's staging or production
gh pr view <pr-number> --repo infinity-microsoft/picasso-assets --json files --jq '.files[].path'
# staging.config.json -> Staging PR
# prod.config.json -> Production PR

# 4. Find associated studio PRs (created by Production workflow)
gh pr list --repo infinity-microsoft/studio --state all --search "labs markdown" --limit 10 \
  --json number,title,state,mergedAt,createdAt
```

#### Step 3: Correlate PRs to Release Branches by Timestamp

| Release Branch | Staging PR | Production PR | Studio PR |
|----------------|------------|---------------|-----------|
| release/2026-02-26-... | Created ~same day | Created after staging merged | Created by prod workflow |
| release/2026-03-02-... | Created ~same day | Created after staging merged | Created by prod workflow |

**Key insight:** PRs are created sequentially:

1. Release branch created (auto, on PR merge)
2. Staging workflow triggered -> picasso staging PR
3. After staging merged -> Production workflow triggered -> picasso prod PR + studio PR

#### Step 4: Determine Status for Each Update

For each release branch, check:

| Check | Command | Status |
|-------|---------|--------|
| Staging PR exists? | Search picasso PRs by date | Yes/No |
| Staging PR merged? | `gh pr view --json state` | Open/Merged |
| Production PR exists? | Search picasso PRs by date | Yes/No |
| Production PR merged? | `gh pr view --json state` | Open/Merged -> **Live** |
| Studio PR merged? | `gh pr view --json state` | Open/Merged |

#### Progress Report Format

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                       Labs Content Update Progress                          │
└─────────────────────────────────────────────────────────────────────────────┘

Update 1: [Description from PR title]
Release: release/2026-02-26-091642
Status: ✅ Complete

┌──────────────────────┬────────┬──────────────────┐
│ Stage                │ PR     │ Status           │
├──────────────────────┼────────┼──────────────────┤
│ labs-content         │ #39    │ ✅ Merged        │
│ picasso (staging)    │ #141   │ ✅ Merged        │
│ picasso (production) │ #143   │ ✅ Merged -> Live│
│ studio               │ #23000 │ ✅ Merged        │
└──────────────────────┴────────┴──────────────────┘

---

Update 2: [Description from PR title]
Release: release/2026-03-02-155350
Status: ⏳ In Progress (Step 17/19)

┌──────────────────────┬────────┬──────────────────┐
│ Stage                │ PR     │ Status           │
├──────────────────────┼────────┼──────────────────┤
│ labs-content         │ #40    │ ✅ Merged        │
│ picasso (staging)    │ #147   │ ✅ Merged        │
│ picasso (production) │ #156   │ ⏳ Open          │
│ studio               │ #23024 │ ⏳ Open          │
└──────────────────────┴────────┴──────────────────┘

Next: Merge picasso PR #156 -> goes live immediately

---

Summary: 1 complete, 1 pending
```

### Add New Experiment

**Ask user for:**

1. Experiment name (e.g., "Copilot Vision")
2. Alias (URL slug, e.g., "copilot-vision")
3. Type: FEATURE or PROJECT
4. Status: UPCOMING, LIVE, GRADUATED, etc.
5. Short description (1-2 sentences)
6. Landing page content (can be placeholder)
7. Cover image URL
8. Try Now button URL

**Then:**

1. Create `content/original/{alias}/metadata.json` and `landing-page.md`
2. Register in `settings.json` with new ID (highest + 1), `enabled: true`
3. Run tests and update baselines

#### metadata.json Template

```json
{
  "name": "Experiment Display Name",
  "alias": "experiment-alias",
  "type": "FEATURE",
  "status": "UPCOMING",
  "assets": {
    "descriptions": {
      "title": { "stringValue": "Display Name", "i18nKey": "labs.experimentsAssets.experimentAlias.title" },
      "short": { "stringValue": "Brief description.", "i18nKey": "labs.experimentsAssets.experimentAlias.shortDescription" },
      "long": { "filename": "labs-exp-experiment-alias" }
    },
    "covers": [{ "type": "IMAGE", "url": "https://copilot.microsoft.com/static/copilotlabs/cover.jpg", "consumers": ["HOMEPAGE"] }],
    "links": [{ "type": "EXTERNAL_LINK", "trigger": "TRY_NOW_BUTTON", "url": "https://example.com", "stringValue": "Try now", "i18nKey": "labs.experimentsAssets.experimentAlias.tryNowButton" }],
    "layouts": { "order": 10 }
  }
}
```

| Field | Values |
|-------|--------|
| `type` | `FEATURE`, `PROJECT` |
| `status` | `NOTSET`, `REGISTERED`, `UPCOMING`, `LIVE`, `GRADUATED`, `SUNSETTED` |

### Modify Experiment

| Change | File |
|--------|------|
| Title, description, links, status | `metadata.json` |
| Landing page content | `landing-page.md` |

### Graduate Experiment

Set `status: "GRADUATED"` in `metadata.json`. The experiment will be marked as graduated from Labs.

### Disable/Enable Experiment

Edit `settings.json`: set `"enabled": false` (or `true`). Content stays intact, just excluded from dist.

### Update Covers/Media

Place media in `content/original/{exp}/`, update `covers` array with predictable CDN URL:

```text
https://copilot.microsoft.com/static/copilotlabs/{filename}
```

Use `--sync-media` flag with Publish: Staging to sync media files.

| Type | Fields | Consumers |
|------|--------|-----------|
| IMAGE | `type`, `url`, `consumers` | HOMEPAGE, LANDING_PAGE |
| VIDEO | `type`, `url`, `width`, `height`, `consumers` | HOMEPAGE, LANDING_PAGE |

Supported: .png, .jpg, .jpeg, .gif, .webp, .svg, .mp4, .webm, .mov

### Schema Sync from Studio

```bash
# Read schema file directly
gh api repos/infinity-microsoft/studio/contents/src/schemas/labs-schemas.ts \
  --jq '.content' | base64 -d
```

**Zod to JSON Schema mapping:**

- `z.enum([...])` → `"enum": [...]`
- `z.literal("X")` → `"const": "X"`
- `z.union([A, B])` → `"oneOf": [{...}, {...}]`
- `z.object({...}).extend({...})` → `"allOf": [{...}, {...}]`

Update both `config.schema.json` and `metadata.schema.json`, then update affected experiments.

### Publishing

*_CRITICAL: Use release/_ branch, NOT main**

```bash
# Find latest release branch
gh api repos/infinity-microsoft/labs-content/branches --paginate \
  --jq '.[] | select(.name | startswith("release/")) | .name' | tail -1

# Trigger workflows
gh workflow run "Publish: Staging" --repo infinity-microsoft/labs-content --ref release/YYYY-MM-DD-HHMMSS
gh workflow run "Publish: Production" --repo infinity-microsoft/labs-content --ref release/YYYY-MM-DD-HHMMSS
```

| Environment | Publishes To |
|-------------|--------------|
| Staging | picasso-assets (`staging.config.json` + media with `--sync-media`) |
| Production | picasso-assets (`prod.config.json`) + studio (markdown, strings, fallback) |

## Repositories and Workflows

| Repo | Purpose |
|------|---------|
| `infinity-microsoft/labs-content` | Content source |
| `infinity-microsoft/picasso-assets` | CDN assets |
| `infinity-microsoft/studio` | Frontend (schema source + production target) |

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `Release` | Auto on push to main | Creates release branch with dist/ |
| `Publish: Staging` | Manual on release/* | Syncs to picasso-assets staging |
| `Publish: Production` | Manual on release/* | Syncs to picasso-assets + studio prod |

## Quick Reference

| File | Purpose |
|------|---------|
| `content/original/{exp}/metadata.json` | Experiment configuration |
| `content/original/{exp}/landing-page.md` | Landing page content |
| `content/config.schema.json` | Schema for generated configs |
| `content/metadata.schema.json` | Schema for source metadata |
| `settings.json` | Experiment IDs and enabled flags |

```bash
npm run test:integration                    # Run tests
npm run test:update-integration-baselines   # Update baselines
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Run Publish on `main` branch | Use `release/*` branch - main has no `dist/` |
| Push directly to main | Create feature branch and PR |
| Forget to update baselines | Run `npm run test:update-integration-baselines` |
| Miss schema file | Update BOTH `config.schema.json` AND `metadata.schema.json` |

## Troubleshooting

### Staging workflow fails with "content/dist is empty"

**Cause**: Publish workflow ran on `main` branch, but `dist/` only exists on `release/*` branches.

**Fix**: Find the latest release branch and run Publish on that branch:

```bash
gh api repos/infinity-microsoft/labs-content/branches --paginate \
  --jq '.[] | select(.name | startswith("release/")) | .name' | tail -1
gh workflow run "Publish: Staging" --repo infinity-microsoft/labs-content --ref release/YYYY-MM-DD-HHMMSS
```

## Checklist

### Local Development

- [ ] Create feature branch
- [ ] Update files (metadata.json, landing-page.md, schema if needed)
- [ ] Run `npm run test:integration`
- [ ] Update baselines if needed

### PR & Release

- [ ] Commit and create PR
- [ ] Wait for PR merge
- [ ] Find release branch

### Staging

- [ ] Trigger Publish: Staging
- [ ] Wait for picasso PR merge
- [ ] Verify at <https://www.copilot-stg.com/labs>

### Production

- [ ] Trigger Publish: Production
- [ ] Wait for picasso PR merge -> Live
- [ ] Verify at <https://www.copilot.microsoft.com/labs>
- [ ] Merge studio PR (can be async)
