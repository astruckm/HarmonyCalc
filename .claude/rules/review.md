# PR Review Guidelines

When reviewing a pull request (via GitHub or when triggered as a review bot), follow these guidelines.

## Review Checklist

Every PR review must evaluate these categories. Flag issues with severity (Critical / Major / Minor / Suggestion).

### Correctness
- Does the change address the stated issue or feature?
- Are there logic errors or unhandled edge cases?
- Could this break existing functionality?

### Platform Compatibility
- macOS: 
- iOS: Works on minimum deployment target of the project's build setting? No newer-only APIs without availability checks?
- Version-specific behavior considered?

### Code Quality
- Matches existing patterns and conventions in the file
- Unwrap optionals safely with `guard let`, `if let`, or `??` (avoid force unwraps `!`)
- Handle timing with proper async primitives or state observation (avoid `DispatchQueue.main.asyncAfter` with hardcoded delays as a workaround)
- Keep abstractions minimal — introduce them only when a concrete need exists
- Extract shared logic into reusable functions or types when duplication appears
- Variable/function names are clear and concise
- SnapKit used for Auto Layout (not raw `NSLayoutConstraint`)

### Framework Rules
- Use SwiftUI only in files that already import and use it; otherwise stay on AppKit/UIKit
- UIKit for iOS

### Thread Safety
- UI operations on main thread
- Guard shared mutable state behind proper synchronization to keep it race-free
- Proper use of synchronization primitives

### Memory Management
- Break potential retain cycles with `[weak self]` / `[unowned]` captures and weak delegate references
- Weak references used appropriately
- Remove observers and notification subscriptions in `deinit` (or matching teardown) to keep them leak-free

### Performance
- Keep hot paths allocation-free — reuse buffers, avoid boxing, and hoist invariants out of loops
- Run disk I/O, network, and heavy computation off the main thread
- Cache or memoize results so the same work isn't repeated

### Accessibility
- VoiceOver labels set for interactive elements
- Dynamic type supported where applicable

## Review Verdict

End every review with a clear verdict:
- **Approve** — no issues or only minor suggestions
- **Request Changes** — has Critical or Major issues that must be fixed
- **Comment** — has suggestions worth discussing but not blocking

## What Not to Flag
- Whitespace differences (tabs vs spaces, trailing whitespace) unless they break something
- Missing comments or docstrings
- Style preferences that differ from the existing file conventions
- Hypothetical future issues unrelated to the change
