---
name: investigate
description: Deep investigation of bug causes - fetches ticket info, explores codebase, and documents probable causes
---

# Investigate Bug

Research a bug deeply and report findings. This skill is read-only — do not edit code files.

## Input
Ticket ID: $ARGUMENTS

## Process

### Step 1: Fetch Ticket Information
```bash
linearis issues read $ARGUMENTS
```

Parse the ticket to understand:
- Bug title and description
- Steps to reproduce (if provided)
- Expected vs actual behavior
- Any attachments, comments, or links
- If the information seems too sparse, ask the user for more details

### Step 2: Fetch Orion Feedback Post (if linked)
If the ticket links to an orionfeedback.org discussion, fetch it via the Flarum API:
```
GET https://orionfeedback.org/api/posts?filter[discussion]=<ID>
GET https://orionfeedback.org/api/discussions/<ID>
```
Extract the numeric discussion ID from the URL (e.g. `https://orionfeedback.org/d/13752-some-title` → `13752`).

From the feedback post, gather:
- Full text of all posts in the thread (user reports, team replies, follow-ups)
- Platform, OS version, and Orion version mentioned
- Screenshots or videos referenced (fetch and inspect images for context)
- Crash logs or file attachments (fetch and read them — crash logs often contain the exact stack trace)
- Whether a team member already replied or asked for clarification

This is often the richest source of reproduction details, user environment info, and visual evidence.

### Step 3: Deep Code Investigation
Based on the bug description, systematically explore the codebase:

1. **Identify relevant areas** — search for keywords, class names, feature areas related to the bug
2. **Read deeply** — read the full implementation of relevant classes and functions, not just skimming
3. **Trace the flow** — follow the code path that executes when the bug occurs
4. **Check related code** — look at callers, callees, and related classes
5. **Review recent changes** — check git history for recent modifications to relevant files

### Step 4: Web Research (if needed)
If the bug involves Apple APIs, WebKit behavior, or platform-specific issues, search for known issues, documentation, or version-specific behaviors.

### Step 5: Formulate Probable Causes
- For simple bugs: state the cause with confidence
- For complex bugs: list probable causes ranked by confidence (high/medium/low) with supporting evidence
- Be honest about uncertainty

## Output

Present findings conversationally. Cover:
- What the ticket describes
- Relevant files and code paths you found
- Key findings from code reading
- Probable cause(s) with confidence levels and evidence
- Any code snippets that illustrate the problem

Do not write a file unless asked. If the user requests a file, write it as `$ARGUMENTS-bug-research.md`.

## Rules
1. This skill is read-only. Do not edit code files.
2. Read code deeply — do not just skim.
3. Be honest about uncertainty.
4. Focus on causes, not fixes — leave solutions to `/plan`.
