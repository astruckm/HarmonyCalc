---
name: verify
description: Add strategic print statements to verify fix hypotheses, iterate with user, and document findings
---

# Verify Fix

Add strategic debug logs to verify fix hypotheses, iterate with the user, and document findings. This skill can edit code files to add/remove debug logs.

## Input
Ticket ID: $ARGUMENTS

## Process

### Step 1: Read the Plan
If a plan document exists (`$ARGUMENTS-bugfix-plan.md`), read it. Otherwise, use the plan from conversation context. Focus on the "Verification Needed" sections.

### Step 2: Read Relevant Code
Read the files mentioned in the plan to find exact locations for debug logs.

### Step 3: Add Debug Logs

Use `DebugLog.shared` with a `#####` prefix for easy filtering:
```swift
DebugLog.shared.addInfo("ClassName.functionName", "##### [key=\(value)] [other=\(info)]")
```

Rules:
- Use `addInfo` for general debugging, `addError` for error conditions
- First parameter: `"ClassName.functionName"`
- Prefix the message with `##### ` for easy log filtering
- Wrap each value in `[]`
- One log per function generally
- Use 🔴 only for "should never happen" errors

### Step 4: Iterate with User
1. Tell the user what logs were added and where
2. Ask them to run the app and trigger the bug
3. Ask for the log output (lines containing `#####`)
4. Analyze the output:
   - Confirms hypothesis → document and proceed
   - Unexpected behavior → add more logs to narrow down
   - Refutes hypothesis → document finding, may need to revisit with `/investigate`

### Step 5: Document Findings
Report findings inline: what the logs showed, whether the hypothesis was confirmed, and what the verified root cause is.

Do not write a file unless asked. If the user requests a file, write it as `$ARGUMENTS-verification.md`.

### Step 6: Clean Up Debug Logs
Only after the user explicitly confirms the fix works, remove all debug logs that were added. Verify none remain.

## Rules
1. Do not remove debug logs until the user confirms the fix works. This is the most important rule.
2. Keep logs minimal — one per function when possible.
3. Always use the `#####` prefix for searchable logs.
4. Document all findings — what logs showed and what they mean.
5. Iterate patiently — may take multiple rounds.
