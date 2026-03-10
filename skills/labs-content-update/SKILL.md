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

#### Step 2: For Each Release Branch, Check Workflow Status

**CRITICAL: Check workflow status FIRST before looking for PRs.**

```bash
# 1. Find Staging workflow runs for this release branch
gh run list --repo infinity-microsoft/labs-content \
  --workflow "Publish: Staging" --branch release/YYYY-MM-DD-HHMMSS --limit 1 \
  --json databaseId,conclusion,status

# 2. Find Production workflow runs for this release branch
gh run list --repo infinity-microsoft/labs-content \
  --workflow "Publish: Production" --branch release/YYYY-MM-DD-HHMMSS --limit 1 \
  --json databaseId,conclusion,status
```

| Workflow | Conclusion | Meaning |
|----------|------------|---------|
| Staging | success | picasso staging PR created |
| Staging | failure | Check logs for error |
| Production | success | picasso prod PR + studio PR created |
| Production | failure | **Check logs** - picasso PR may exist but studio PR missing |

#### Step 3: If Workflow Failed, Check Logs

```bash
# Get failure details
gh run view <run-id> --repo infinity-microsoft/labs-content --log 2>&1 | tail -50

# Common failure: authentication error when pushing to studio
# "fatal: could not read Username for 'https://github.com'"
# This means: picasso PR created, but studio PR NOT created
```

#### Step 4: Find PRs from Workflow Logs (if successful)

```bash
# Extract PR links from successful workflow logs
gh run view <run-id> --repo infinity-microsoft/labs-content --log 2>&1 | grep -i "github.com.*pull"

# Example output:
# https://github.com/infinity-microsoft/picasso-assets/pull/143
# https://github.com/infinity-microsoft/studio/pull/23024
```

#### Step 5: Alternative - Find PRs by Branch Name

If workflow logs unavailable, search by branch naming convention:

```bash
# Staging workflow creates branch: copilotlabs-staging-config/YYYY-MM-DD-HHMMSS
gh pr list --repo infinity-microsoft/picasso-assets --state all \
  --head "copilotlabs-staging-config/2026-02-27" --json number,state

# Production workflow creates branches:
# - copilotlabs-prod-config/YYYY-MM-DD-HHMMSS (picasso)
# - copilotlabs-production/YYYY-MM-DD-HHMMSS (studio)
gh pr list --repo infinity-microsoft/picasso-assets --state all \
  --head "copilotlabs-prod-config/2026-02-27" --json number,state
gh pr list --repo infinity-microsoft/studio --state all \
  --head "copilotlabs-production/2026-02-27" --json number,state
```

#### Step 6: Determine Status for Each Update

| Check | Command | Status |
|-------|---------|--------|
| Staging workflow | `gh run list --workflow "Publish: Staging"` | success/failure |
| Staging PR | From workflow log or branch search | Open/Merged/Missing |
| Production workflow | `gh run list --workflow "Publish: Production"` | success/failure |
| Production picasso PR | From workflow log or branch search | Open/Merged/Missing |
| Production studio PR | From workflow log or branch search | Open/Merged/**Missing if workflow failed** |

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

**MUST collect info from user before modifying:**

1. Show current status:

   ```bash
   gh api repos/infinity-microsoft/labs-content/contents/content/original/{alias}/metadata.json \
     --jq '.content' | base64 -d | jq '.status'
   ```

2. **Ask user for graduated description** (required):
   > "Please provide the graduated description, e.g., 'Now available in Voice mode on desktop and mobile'"

3. Confirm with user before proceeding

**Changes to make in `metadata.json`:**

1. Set `status: "GRADUATED"`
2. Add `graduated` description in `assets.descriptions`:

```json
{
  "status": "GRADUATED",
  "assets": {
    "descriptions": {
      "graduated": {
        "stringValue": "{user provided description}",
        "i18nKey": "labs.experimentsAssets.{alias}.graduatedDescription"
      }
    }
  }
}
```

The experiment will be marked as graduated from Labs with the provided description.

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

### Production workflow fails when pushing to studio

**Symptom**: picasso PR created and merged, but studio PR missing.

**Error in logs**:
```
fatal: could not read Username for 'https://github.com': No such device or address
```

**Cause**: GitHub Actions authentication issue when pushing to studio repo.

**Fix Options**:

1. **Re-trigger workflow** (may fail again if auth issue persists):
   ```bash
   gh workflow run "Publish: Production" --repo infinity-microsoft/labs-content --ref release/YYYY-MM-DD-HHMMSS
   ```

2. **Manually create studio PR**:

   ```bash
   # 1. Clone studio repo (if not in workspace)
   cd workspace/repos
   gh repo clone infinity-microsoft/studio

   # 2. Create branch
   cd studio
   git checkout -b copilotlabs-production/manual-sync

   # 3. Get content from labs-content dist
   # Copy from labs-content/content/dist/en-US/config.json to:
   #   - studio/src/components/labs/assets/labs-config.fallback.json

   # 4. Extract strings from config and update:
   #   - studio/src/config/strings/en-US/strings.json

   # 5. Copy markdown files from labs-content/content/dist/en-US/markdown/ to:
   #   - studio/src/config/markdown-strings/en-US/

   # 6. Commit and create PR
   git add .
   git commit -m "[Labs] update copilotlabs markdown content (manual sync)"
   git push -u origin copilotlabs-production/manual-sync
   gh pr create --title "[Labs] update copilotlabs markdown content" --body "Manual sync due to workflow failure"
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
