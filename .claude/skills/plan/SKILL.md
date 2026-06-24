---
name: plan
description: Create detailed fix proposals based on bug research - analyzes causes and proposes specific code changes
---

# Plan Fix

Read the bug research and formulate detailed fix proposals. This skill is read-only — do not edit code files.

## Input
Ticket ID: $ARGUMENTS

## Process

### Step 1: Read the Research
If a research document exists (`$ARGUMENTS-bug-research.md`), read it. Otherwise, use the investigation findings from the conversation context.

Extract:
- The bug description and expected behavior
- Probable causes identified
- Relevant files and code locations

### Step 2: Deep Dive into Relevant Code
For each probable cause:
- Understand the full context around the problematic code
- Check how it interacts with other parts of the system
- Look for existing patterns in the codebase that should guide the fix
- Identify edge cases and platform-specific considerations

### Step 3: Formulate Fix Approaches
For each probable cause, develop one or more fix approaches. Follow the project code rules in `.claude/rules/swift-code.md`. Keep fixes minimal — the smallest diff that fixes the issue is preferred.

When deleting something, remove any resultant dead code too.

### Step 4: Assess Confidence
For each proposed fix:
- Rate confidence (high/medium/low)
- Explain why you believe it will work
- Identify if print verification is needed (via `/verify`)
- Note risks or potential side effects

## Output

Talk through the proposed fix conversationally:
- Summarize the bug in one paragraph
- Present each fix approach with: what to change, where, why, confidence level, and the actual code diffs
- Recommend which approach to use
- Note if verification via `/verify` is needed first
- List any questions that need user input

Do not write a file unless asked. If the user requests a file, write it as `$ARGUMENTS-bugfix-plan.md`.

## Rules
1. This skill is read-only. Do not edit code files.
2. Be detailed enough that the fix is implementable from your description.
3. Explain your reasoning — not just what to change, but why.
4. Acknowledge uncertainty — if unsure, recommend verification via `/verify`.
