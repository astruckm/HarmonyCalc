---
name: bugfix
description: Main orchestrator for the complete bugfix workflow - investigation, planning, verification, and fix
---

# Bugfix Workflow

Main entry point for the bugfix workflow. Guides you through the complete process of fixing a bug.

## Input
Ticket ID: $ARGUMENTS

## Workflow

```
/bugfix ORION-X
      │
      ▼
/investigate ORION-X    ← Research the bug
      │
      ▼
/plan ORION-X           ← Propose fix approaches
      │
      ▼
/verify ORION-X         ← Print debugging (if needed)
      │
      ▼
Implement fix           ← Apply changes, remove prints, commit
      │
      ▼
/pr ORION-X             ← Create pull request
```

## How to Use

Run each stage in order. Each skill outputs inline by default — ask for a file if you need a persistent artifact.

1. **Investigate** — `/investigate ORION-1234`
2. **Plan** — `/plan ORION-1234`
3. **Verify** (if needed) — `/verify ORION-1234`
4. **Implement** — Apply code changes, remove debug prints, commit when asked
5. **PR** — `/pr ORION-1234`

## Getting Started

Let me fetch the ticket information to begin:

```bash
linearis issues read $ARGUMENTS
```

After reviewing the ticket, run:
```
/investigate $ARGUMENTS
```
