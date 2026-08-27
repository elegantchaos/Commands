# System Undo and Redo Routing

## Status

Proposed design. This document records the intended system-menu integration for
`UndoService`; it does not describe an implemented API.

## Goal

The system-supplied Undo and Redo commands should execute the history owned by
the current editing context:

- A focused text control continues to use its framework-owned `UndoManager`.
- An application command surface with no native editing context uses the
  active scene's `UndoService`.

There must be one visible Undo command and one visible Redo command for a given
context. Application commands must not add duplicate Undo or Redo items beside
the system ones.

## Constraints

`UndoService` stores asynchronous `CommandReversal` values. A reversal returns
its opposing reversal only after `perform(in:)` completes. Foundation's
`UndoManager` instead registers and executes synchronous closures. Recording
an asynchronous reversal in `UndoManager` by launching an unstructured task
would allow UIKit or AppKit to update its redo state before the reversal
finishes, which is not correct.

UIKit and AppKit also keep their native undo registrations opaque. A router can
read the selected manager's availability and menu titles, and it can invoke the
manager, but it cannot recreate those registrations as `CommandReversal`
values. Text and application histories must therefore remain separate.

## Ownership model

The routing layer chooses an owner at the point where a system Undo or Redo
action is invoked. It does not merge histories.

```text
System Undo or Redo
        |
        +-- focused native text editor --> framework UndoManager
        |
        +-- other active native undo context --> framework UndoManager
        |
        +-- no native editing context --> active scene UndoService
```

The exact selection policy must favour a focused text editor even if that
editor's manager currently has no action. This prevents an application reversal
from unexpectedly changing application state while someone is editing text.

## Proposed responsibilities

### Commands

`UndoService` remains the owner of application command reversals. It must not
import native registrations or depend on UIKit or AppKit.

### CommandsUI

Add an opt-in, platform-specific routing adapter in `CommandsUI` (or a
separate platform target if that produces a cleaner dependency boundary). It
should:

- associate a command centre's `UndoService` with an active window or scene;
- resolve the current native editing context;
- expose the selected owner's title, availability, and in-progress state;
- invoke either `UndoManager.undo()` / `redo()` or `UndoService.performUndo()` /
  `performRedo()`;
- prevent repeat invocation while an asynchronous application reversal runs;
- request system-menu revalidation when focus or the selected owner's state
  changes.

The adapter must be a router, not an `UndoManager` history bridge.

### Application

The application composition root supplies the per-window or per-scene command
centre to the adapter. This avoids a global `UndoService` and keeps independent
windows from sharing an undo cursor accidentally.

## macOS design

Leave the standard Edit menu's Undo and Redo items in place. AppKit resolves
nil-target actions from the key window's first responder through the responder
chain. The macOS adapter should act only as the fallback target when a native
editing responder does not own the action.

The implementation needs a small public-AppKit prototype to confirm the
least-invasive installation point for that fallback. It must not replace the
whole SwiftUI `CommandGroup(.undoRedo)`, because replacement removes the
framework-provided menu items and prevents native text editing from retaining
its default behaviour.

When the adapter is selected, it should validate the standard menu items from
the active `UndoService`. It may use a pending `CommandReversalWithUI`'s
history-action name to present a descriptive title, while retaining the
standard Undo and Redo semantics and shortcuts. The history-action name must
describe the original action (“Undo Add Item”), not the reversal that executes
it (“Remove Item”).

## iPadOS 26 design

iPadOS 26 presents a system menu bar that SwiftUI `Commands` can populate.
The iPad adapter must provide the same ownership policy as macOS, but UIKit's
main-menu construction is application-level and can occur without a view
hierarchy. The adapter must therefore resolve the active window and first
responder when an action is invoked, rather than treating menu construction as
the source of focus information.

`CommandCentreDelegate` is the natural integration point for UIKit command
dispatch. Extend it, or a focused companion type, with routing support that:

- builds or replaces only the Undo and Redo action entries in the main menu;
- routes a focused `UITextField` or `UITextView` to its native `UndoManager`;
- routes other contexts to the foreground scene's `UndoService`;
- revalidates the menu as focus and undo availability change.

On iPadOS versions before 26, the same router can provide physical-keyboard
fallback commands. Those commands must leave
`UIKeyCommand.wantsPriorityOverSystemBehavior` at its default `false`, so text
input and focus systems continue to receive keyboard input first.

Touch-driven system undo, including editing gestures, remains native when text
is focused. Providing equivalent system-gesture handling for `UndoService`
without using `UndoManager` requires separate platform investigation and is
not part of this design.

## Availability and execution

For the selected owner, the system command should:

- remain visible and be disabled when no undo or redo is possible;
- use the native manager's localized title for native actions;
- use the next command reversal's presentation when available for application
  actions;
- be disabled while `UndoService` performs an asynchronous reversal;
- leave the current state unchanged when an application reversal fails.

The router must resolve the active owner again for every action. It must not
cache a text editor's `UndoManager` after focus moves to another window or
scene.

## Implementation questions

Resolve these questions with focused macOS and iPadOS prototypes before making
the adapter public:

1. Identify the minimal public AppKit hook that adds an `UndoService` fallback
   without changing normal responder-chain targets.
2. Identify the public UIKit menu-builder operations that replace only Undo and
   Redo while retaining the other system Edit actions.
3. Confirm how a SwiftUI app supplies the active scene's command centre to the
   UIKit menu router when multiple scenes are active.
4. Confirm menu validation timing for focus changes and asynchronous command
   reversals on both platforms.
5. Decide whether application reversal titles should use the generic “Undo” /
   “Redo” labels or the pending reversal's UI presentation.

## Test plan

- A focused text field handles Undo and Redo through its native manager.
- A focused text editor with no native action does not execute an application
  reversal.
- With no native editing focus, Undo and Redo invoke the correct scene's
  `UndoService`.
- Switching focus and switching windows changes the selected owner.
- An in-progress or failed asynchronous reversal keeps the command state
  coherent and does not create an invalid redo state.
- iPadOS 26 menu-bar items and physical-keyboard shortcuts have the same
  routing result.

## References

- [Building and customizing the menu bar with SwiftUI](https://developer.apple.com/documentation/swiftui/building-and-customizing-the-menu-bar-with-swiftui)
- [CommandGroup](https://developer.apple.com/documentation/swiftui/commandgroup)
- [NSApplication target lookup](https://developer.apple.com/documentation/appkit/nsapplication/target%28foraction%3Ato%3Afrom%3A%29)
- [UIKit responder chain](https://developer.apple.com/documentation/uikit/using-responders-and-the-responder-chain-to-handle-events)
- [UIMenuBuilder](https://developer.apple.com/documentation/uikit/uimenubuilder)
- [UndoManager](https://developer.apple.com/documentation/foundation/undomanager)
