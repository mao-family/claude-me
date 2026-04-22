---
name: research
description: Conducts systematic research before development by gathering information from multiple sources (Slack, websites, PRDs, GitHub repos, design docs) and synthesizing insights. Use when user says "research this", "investigate", or asks to understand a topic, technology, or external project before building something. Also triggers when comparing multiple solutions, evaluating third-party tools, or needing to understand how others have solved similar problems.
---

# Research Skill

Conduct structured research before development to make informed decisions.

## When to Use

- User explicitly asks for research ("research this", "investigate")
- Evaluating third-party tools, frameworks, or approaches
- Understanding how others solved similar problems
- Comparing multiple solutions before choosing one
- Gathering context before a design or implementation phase

## Workflow

```text
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ 1. COLLECT  │────▶│ 2. RESEARCH │────▶│ 3. SYNTHESIZE│
│ Sources     │     │ (parallel)  │     │ Insight     │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Step 1: Collect Sources

If the user has already provided specific sources, skip to Step 2.

Otherwise, ask what sources to research:

> "What sources would you like me to research?
>
> - Website URLs
> - GitHub repositories
> - Slack channels/messages
> - PRDs or design documents
> - Notion pages
> - Any other materials"

Wait for user input. Don't assume sources.

### Step 2: Research Each Source (Parallel)

For multiple sources, spawn parallel agents to research each one simultaneously.

Each research agent should:

1. Read/fetch the source content
2. Extract key information
3. Analyze strengths and weaknesses
4. Identify takeaways relevant to claude-me

Output each research doc to `memory-bank/research/{source}.md`.

**Research Document Template:**

```markdown
# Research: {Topic/Project Name}

**Date:** {YYYY-MM-DD}

**Source:** {URL or path to source}

---

## Overview

{Brief description of what this is and why it's relevant}

## Key Findings

{Bullet points of important discoveries, patterns, or techniques}

## Strengths

{What does this do well? What can we learn from it?}

## Weaknesses

{Limitations, gaps, or things that don't apply to our context}

## Takeaways for claude-me

{Specific, actionable insights for our project}
```

**Output Location:** Always write to `memory-bank/research/`, not to other directories.

### Step 3: Synthesize Insight

After all research is complete, synthesize findings into a single insight document.

Output to `memory-bank/insights/{topic}.md`.

**Insight Document Template:**

```markdown
# Insight: {Topic}

**Date:** {YYYY-MM-DD}

**Sources:**

- [Research: {Source 1}](../research/{source1}.md)
- [Research: {Source 2}](../research/{source2}.md)

---

## Summary

{One paragraph synthesizing the key findings across all sources}

## Key Findings

| # | Finding |
|---|---------|
| 1 | {Finding 1} |
| 2 | {Finding 2} |
| 3 | {Finding 3} |

## Implications for claude-me

{What does this mean for our project? How should it influence our decisions? Include specific, actionable takeaways.}

## Recommendations

| Priority | Recommendation | Rationale |
|----------|----------------|-----------|
| 🔴 HIGH | {Recommendation} | {Why} |
| 🟡 MED | {Recommendation} | {Why} |
| 🟢 LOW | {Recommendation} | {Why} |
```

**Output Location:** Always write to `memory-bank/insights/`, not to other directories.

## Parallel Research Execution

When there are multiple sources, use subagent-driven development:

```text
For each source:
  spawn agent:
    - Read source content (WebFetch, Read, MCP tools)
    - Apply research template
    - Write to memory-bank/research/{source-name}.md
```

All agents run in parallel. After all complete, synthesize into insight.

## Calling Other Skills

## Examples

### Example 1: Single source

```text
User: Research the obra/superpowers project
Claude: I'll research obra/superpowers...
→ Output: memory-bank/research/superpowers.md
→ Output: memory-bank/insights/superpowers.md
```

### Example 2: Multiple sources

```text
User: Research vibe coding best practices from these projects:
- https://github.com/EnzeD/vibe-coding
- https://github.com/everything-claude-code
- OpenAI's harness engineering article

Claude: I'll research these three sources in parallel...
→ 3 agents spawn in parallel
→ Output: memory-bank/research/vibe-coding.md
→ Output: memory-bank/research/everything-claude-code.md
→ Output: memory-bank/research/openai-harness-engineering.md
→ Output: memory-bank/insights/vibe-coding-workflow.md
```

## Notes

- Research docs are factual extractions; insights are synthesized conclusions
- Keep research docs focused on the source; don't add opinions
- Insights should be actionable for claude-me specifically
- File names are flexible — use descriptive names based on the topic
