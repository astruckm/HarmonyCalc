---
name: pr
description: Prepare Orion pull requests using repo templates, before/after media flow, and platform-specific reviewer rules
---

# PR Workflow

Prepare PR content and create PRs in the Orion repo with consistent formatting.

## Input
Optional: ticket ID (for example `ORION-3901` / `ORIMO-123`)  
If not provided, infer from branch name.

## Critical Rules

1. Do not create/update a PR until the user confirms the generated PR body.
2. Always use the repo PR templates from `.github/PULL_REQUEST_TEMPLATE/`.
3. Always search Desktop for before/after media and ask the user whether to use them.
4. Always apply reviewer rules below, excluding the PR author.
5. Default media embedding uses blank placeholders: `<video src="">` (do not block PR creation on media hosting/upload).
6. If there are multiple before/after comparisons, use a 3-column table: `Description | Before | After`.
7. If the current branch has the ticket ID, we don't need to create a new branch.

## Step 1: Determine PR Type

Inspect changed files (`git diff --name-only development...HEAD`) and classify:

- `macOS`: mostly `Kagi-macOS` / ORION work
- `iOS`: mostly `Kagi-iOS` / ORIMO work
- `both`: shared/core changes impacting both platforms

Choose template:

- macOS: `.github/PULL_REQUEST_TEMPLATE/macos_template.md`
- iOS: `.github/PULL_REQUEST_TEMPLATE/ios_template.md`
- both: start from macOS template and include iOS testing notes too

## Step 2: Build Summary Section

Use this structure:

1. Linear link line (if ticket known): `https://linear.app/kagi/issue/TICKET-ID/...`
2. 1-3 concise lines about what changed and why
3. Optional usage/example snippet if relevant
4. From the iOS / macOS template, keep the before / after screenshot section intact. User will edit this on their own.

## Step 3: Test Plan

After the summary section, create a Test Plan. The test plan will have a simple to understand list of steps that allows a reviewer to validate the PR's changes.
A test plan may also mention sanity check steps for testing broader areas of code.
For instance if a lot of code changes related to tabs were made, sanity check steps could include a general test of tabs behavior and testing them in all 3 modes, etc.
If a test plan is not required / or does not make sense for a particular PR, mention why it is not testable.

## Step 4: OS Checklist

Keep ALL checklist items from the template — do not remove unchecked items. Mark only items explicitly confirmed by user.
Never guess test/OS checks. Remove the app artifact section unless user explicitly asks.

## Step 5: Reviewer Assignment Rules

Determine PR author login with:

```bash
gh api user --jq .login
```

Add reviewers (excluding author):

- For macOS PRs: `aksh1t`, `dinodev90`, `astruckm`, `nrudnyk`
- For iOS PRs: `jet-kagi`, `iccub`, `dinodev90`
- For both: union of both sets (still exclude author)

## Step 6: Labels / Tagging

Tag PR as `macOS`, `iOS`, or both depending on touched areas.  
Only add labels that exist in the repo.

## Step 7: Create PR (After User Confirmation)

1. Show full PR body to user first.
2. On approval, create PR with title:
   - `TICKET-ID: short description`
3. Add reviewers according to rules.
4. Add platform label(s).
5. Return PR URL and final reviewer/label summary.

## Output to User

When done, report:

1. PR URL
2. Template used
3. Reviewers added
4. Labels added
5. Media section status (blank placeholders or embedded URLs)