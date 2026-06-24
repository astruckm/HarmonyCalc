# Swift Code Rules

## Whitespace Preservation
Preserve the exact whitespace (tabs, spaces, blank lines) of every line you do not modify. If a blank line contains tab characters, keep them. Your diff must contain zero lines that only differ in whitespace. Only touch lines where you are making a meaningful code change.

## Swift Version
Use Swift 5. Do not use Swift 6 features or syntax.

## UI Frameworks
- Use UIKit for iOS.
- Do not use SwiftUI unless the file already imports and uses SwiftUI.

## Platform Compatibility
- iOS: Support minimum iOS Deployment Target version. Do not use newer-only APIs without availability checks.
- When a newer API is unavoidable, mention the compatibility concern and ask for guidance.

## Thread Safety
All UI operations must happen on the main thread. When dispatching work to a background queue, ensure UI updates are dispatched back to `DispatchQueue.main`.

## Memory Management
Use `[weak self]` in escaping closures to prevent retain cycles. Mark delegate properties as `weak`.

## Code Style
- Match existing formatting, conventions, and patterns in each file. If the file uses a particular style of error handling, state management, or API usage, follow that style rather than introducing a different approach.
- Prefer `guard` for early returns over deeply nested `if let` chains.
- Avoid force unwrapping (`!`). Use `guard let`, `if let`, or `??`.
- When filtering text based on user input, use `localizedStandardContains()` instead of `contains()`.
- Fix the root cause rather than using `DispatchQueue.main.asyncAfter` with hardcoded delays as workarounds.
- When removing code, also clean up any resulting dead code (unused variables, unreachable branches, orphaned helpers).
- Remove unused imports after your changes.
- Only add comments to lines you are changing. Existing comments on untouched code stay as-is.
- Only add error handling at real system boundaries (user input, external APIs), not for internal scenarios that cannot fail.
- Keep abstractions proportional to usage — one-time operations stay inline.
