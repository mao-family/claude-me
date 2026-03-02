---
name: research
description: Conducts systematic research before development by gathering information from multiple sources (Slack, websites, PRDs, GitHub repos, design docs) and synthesizing insights. Use when user says "帮我研究 XXX", "做个调研", "research this", "investigate", or asks to understand a topic, technology, or external project before building something. Also triggers when comparing multiple solutions, evaluating third-party tools, or needing to understand how others have solved similar problems.
---

# Research Skill

Conduct structured research before development to make informed decisions.

## When to Use

- User explicitly asks for research ("帮我研究", "做个调研", "research this")
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

> "你想研究哪些内容？可以是：
>
> - 网站 URL
> - GitHub 仓库
> - Slack 频道/消息
> - PRD 或设计文档
> - Notion 页面
> - 其他任何资料"

Wait for user input. Don't assume sources.

### Step 2: Research Each Source (Parallel)

For multiple sources, spawn parallel agents to research each one simultaneously.

Each research agent should:

1. Read/fetch the source content
2. Extract key information
3. Analyze strengths and weaknesses
4. Identify takeaways relevant to claude-me

Output each research doc to `memory-bank/references/{topic}.md`.

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

**Output Location:** Always write to `memory-bank/references/`, not to other directories.

### Step 3: Synthesize Insight

After all research is complete, synthesize findings into a single insight document.

Output to `memory-bank/insights/{topic}.md`.

**Insight Document Template:**

```markdown
# Insight: {Topic}

**Date:** {YYYY-MM-DD}

**Sources:**

- [Research: {Source 1}](../references/{source1}.md)
- [Research: {Source 2}](../references/{source2}.md)

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
    - Write to memory-bank/references/{source-name}.md
```

All agents run in parallel. After all complete, synthesize into insight.

## Calling Other Skills

Before writing markdown, invoke the `writing-docs` skill to ensure proper formatting:

- Progressive disclosure
- Markdown style rules
- No duplication

## Examples

### Example 1: Single source

```text
User: 帮我研究一下 obra/superpowers 这个项目
Claude: 好的，我来研究 obra/superpowers...
→ Output: memory-bank/references/superpowers.md
→ Output: memory-bank/insights/superpowers.md
```

### Example 2: Multiple sources

```text
User: 做个调研，关于 vibe coding 的最佳实践，看看这几个项目：
- https://github.com/EnzeD/vibe-coding
- https://github.com/everything-claude-code
- OpenAI 的 harness engineering 文章

Claude: 我会并行研究这三个来源...
→ 3 agents spawn in parallel
→ Output: memory-bank/references/vibe-coding.md
→ Output: memory-bank/references/everything-claude-code.md
→ Output: memory-bank/references/openai-harness-engineering.md
→ Output: memory-bank/insights/vibe-coding-workflow.md
```

## Notes

- Research docs are factual extractions; insights are synthesized conclusions
- Keep research docs focused on the source; don't add opinions
- Insights should be actionable for claude-me specifically
- File names are flexible — use descriptive names based on the topic
