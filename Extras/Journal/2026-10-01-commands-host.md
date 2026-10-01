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
- Added `CommandConfirmationMode` (`.local`, `.hosted`, `.never`). The
  environment supplies the default (`.local`), set for a subtree with
  `commandConfirmation(_:)` or `withoutConfirmation()`. A `confirmation:`
  parameter on `button`, `toolbarItem`, `toolbarItemGroup` and `dynamicButton`
  overrides it for one button.
- `button(_:)` is now the only confirming button. It confirms whenever its
  command declares a confirmation, so a command opts in by returning one from
  `confirmation(centre:)`, which describes the command rather than the UI.
  `defaultConfirmation(centre:)` supplies a stock one.
- `confirmableButton` and `confirmableToolbarItem` are deprecated and forward
  to `button` and `toolbarItem`.
- `.local` is a `confirmationDialog` attached to the button, which the system
  anchors to it (a popover pointing at the button on a regular-width iPad, an
  action sheet on iPhone). `.hosted` is the host's centred alert.
- `.hosted` without a host falls back to `.local`, with a debug log.

## Decisions

- Local by default, hosted for menus. SwiftUI has no public way to ask whether
  a view is inside a menu, so the call site or an enclosing view says so. A menu
  without `.commandConfirmation(.hosted)` fails silently: its button's dialog is
  discarded with the menu.
- The "no confirmation" case is `.never`, not `.none`. The call-site parameter
  is optional, and `.none` there is `Optional.none`, "not specified", which
  would quietly mean "use the environment".
- Multiple windows: each host publishes its presenter as a focused scene
  value, so the menu bar reaches the key window's host.
- The host is a view, not a modifier, because it should appear once per
  presentation scope.

## Found on the way

`confirmation.default.message` had no English value in the string catalog, so
the old stock confirmation would have shown the raw key as its message. Fixed;
`defaultConfirmation` looks its strings up in the module bundle. Tests check both
the catalog source (every key has an English value) and, from Swift 6.4, the
lookup itself. Before 6.4, SwiftPM's own build system did not compile catalogs,
so a lookup returned the raw key and CI failed on a test that expected text; the
package now requires Swift 6.4, whose unified build system compiles them.

## Validation

- `swift test` passes, including `CommandPresenterTests` (confirming does not
  perform, accepting performs once, cancelling does not perform, a new request
  replaces a pending one) and `CommandConfirmationModeTests` (the outcome table
  for call-site and environment modes, and `defaultConfirmation`).
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
