# 2026-10-01 — Commands host

## Summary

Confirmations declared by a command never appeared when the command was in a
menu. A button attached its own alert, a menu discards its buttons when it
closes, and a macOS `CommandMenu` has no view hierarchy to hold one. Bookish
hit this with Reset Datastore and Rebuild Record Store, which ran unconfirmed.

I checked ActionStatus, Stack and ClockSync for an existing fix. None had one:
they use `confirmableButton` in toolbars and forms, where a local alert works.
`ConfirmableCommandButton` was identical in each.

## Completed work

- Added `CommandsHost`, a view placed at the root of each window (and inside
  any sheet that contains command buttons). It injects the app's commander and
  presents alerts that buttons request.
- Added `CommandPresenter`, which holds the pending confirmation. Buttons find
  it in the environment, or through a focused scene value when they are in the
  macOS menu bar, which has no environment.
- `confirmableButton(_:)` and `button(_:)` both ask the host to confirm when the
  command declares a confirmation. `confirming: false` opts out, on every
  `button` overload.
- Without a host, behaviour is unchanged for existing apps: `confirmableButton`
  keeps a local dialog, and `button` runs the command unconfirmed with a logged
  warning.
- The no-host fallback now uses `confirmationDialog` instead of `alert`, so the
  system anchors it to the button (a popover pointing at it on a regular-width
  iPad, an action sheet on iPhone).

## Decisions

- Presentation is hosted for everything, not detected per button. SwiftUI has
  no public way to ask whether a view is inside a menu, so a button that
  "stays local unless in a menu" cannot be built without the call site saying
  so. A possible later step is an environment value set by menu wrappers, so
  that only menus use the host and other buttons keep an anchored local dialog.
- Multiple windows: each host publishes its presenter as a focused scene
  value, so the menu bar reaches the key window's host.
- The host is a view, not a modifier, because it should appear once per
  presentation scope.

## Validation

- `swift test` passes, including `CommandPresenterTests`: confirming does not
  perform, accepting performs once, cancelling does not perform, and a new
  request replaces a pending one.
- Checked from Bookish on the iPhone simulator: Rebuild Record Store in a
  toolbar menu shows its confirmation, and Cancel runs nothing.
- Checked on the iPad simulator without a host: the fallback dialog is a
  popover anchored under the tapped button.
- Not checked: the macOS menu bar path, which depends on the focused scene
  value, and the fallback dialog on iPhone and macOS.

## Open

- Importers and exporters (`ImporterCommandButton`) have the same
  discarded-with-the-menu flaw. They could present from the host too.
- A sheet that contains a confirming command needs its own `CommandsHost`,
  since an alert cannot present from a view a sheet covers.
