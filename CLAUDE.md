# HarmonyCalc

HarmonyCalc by Kagi — Play the notes, get the chord! A music theory app that allows users to tap notes on a piano keyboard and view info about the notes played, and chord content of the notes, in both tonal and post-tonal music theory forms. 

## Core Rules

### Code Standards
- Don't new APIs unless replacing a deprecated one. Backwards compatibility, as much as reasonably possible, is a nice-to-have for this app.
- Use UIKit unless expressly told to use SwiftUI.
- Match existing formatting and conventions in each file exactly.

### Whitespace
Try to ensure your diff contains minimal whitespace changes, especially to blank lines.

### Localization

### Git
See `.claude/rules/git.md` for details.

### Building
Do not run `xcodebuild` unless explicitly asked. Use `HarmonyCalc.xcodeproj` for all development.

## Code Quality

- Only change what is necessary to fix the issue. No over-engineering.
- Avoid force unwrapping (`!`). Use `guard let`, `if let`, or `??`.
- Limit comments to lines you are actively adding or modifying. Don't write overly long comments, make them as short as possible  Feel free to not add any comments to a change. Self-documenting code is preferable.
- Do not add docstrings, error handling for impossible scenarios, or abstractions for one-time operations.
- Introduce feature flags and backward-compatibility shims only when a concrete rollout or migration requires them or when explicitely asked by the user.

## Print Debugging

Follow current project convention for adding logs

## PR Reviews

See `.claude/rules/review.md` for the full review checklist and guidelines.

## Creating New Skills

Skills are defined in `.claude/skills/<skill-name>/SKILL.md`. When creating a new skill:

1. Create the skill directory and `SKILL.md` in `.claude/skills/`
2. Add a symlink in `.codex/skills/` pointing to the Claude skill:
   ```bash
   cd .codex/skills
   ln -s ../../.claude/skills/<skill-name> <skill-name>
   ```
3. Add `"Skill(<skill-name>)"` to `.claude/settings.json` permissions allow list
