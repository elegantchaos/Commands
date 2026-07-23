# CommandsUI

## Purpose
`CommandsUI` provides UI adapters for the core `Commands` framework.

It adds icon-backed command presentation models, UI wrappers, reusable SwiftUI controls, and UIKit menu adaptation for invoking commands with optional confirmation.

## Responsibilities
- Extend command models with UI-specific metadata.
- Provide reusable command button and wrapper views.
- Resolve dynamic trigger-based command variants at activation time.
- Adapt commands to `UICommand`, `UIKeyCommand`, and `UIMenu` for iOS and Mac Catalyst menu systems.
- Host localized resources for command UI strings.

## Depends On
- `Commands`
