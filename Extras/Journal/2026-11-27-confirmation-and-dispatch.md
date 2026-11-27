# 2026-11-27 — Confirmation and menu dispatch

## Summary

Fixed three correctness findings from the full review in `Extras/Reviews/2026-11-27-commands-full-review.md` (findings 1, 2 and 7), each with a test that failed first.

- **A hosted alert could perform a different command from the one shown.** `CommandPresenter.accept(_:)` and `cancel(_:)` now take the request they act on and ignore any other, and the presenter refuses a new request while one is shown. `CommandsHost` builds its alert, buttons and dismissal from the request it shows; SwiftUI ignores changes to the presented data once an alert is up, so replacing the request could otherwise make "Delete A" run B. A button's local confirmation dialog follows the same rules.
- **UIKit menus and file importers skipped confirmation.** `CommandCentreDelegate` asks for a command's confirmation through an overridable `confirm(_:perform:)`, which uses `commandPresenter` when set and otherwise shows a `UIAlertController` on the key window; with nowhere to ask, the command does not run. `ImporterCommandModifier`, which both importer controls use, confirms after the user has chosen a file, through the same confirmation state as a command button.
- **UIKit menu items for the same command ID ran the last one built.** Each generated item now carries its own invocation token. `CommandCentreDelegate.buildMenu(with:)` advances a menu generation, and invocations older than the previous generation are dropped, so the registry stays bounded whether a subclass calls `super` before or after adding its items.

Undo and redo still perform commands without confirmation, in both History and `UndoManager`.

## Validation

`agt validate --target CommandsUI` passes on macOS. The UIKit tests run only on iOS: the package's unit tests pass on the iOS 27.2 simulator through the example's "Full Validation" test plan, including the three new delegate tests. The importer confirmation has no automated test, because it sits behind SwiftUI's file importer.
