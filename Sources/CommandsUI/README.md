# CommandsUI

`CommandsUI` presents `Commands` models in SwiftUI and adapts them for UIKit and
Mac Catalyst menus. It depends on the core [Commands](../Commands/README.md)
target and adds the UI-specific `Icons` dependency.

For an overview of the package, see the [root README](../../README.md).

## UI metadata

`CommandWithUI` adds localized names, icons, help, keyboard shortcuts, and
optional confirmation. Its default name and help use the command identifier as
the localization key; override them when presentation depends on the centre.

## SwiftUI controls

Extend a command centre to create controls from the same command model:

```swift
commander.button(command)
commander.confirmableButton(command)
commander.toolbarItem(command)
commander.dynamicButton(command: command(for:))
```

`importer(_:)` and `importerButton(_:isShowingImportSheet:)` support file-import
commands. `undoButton()` and `redoButton()` remain visible but disabled when no
operation is available. Set `showsCommandPresentation: true` to use a pending
`CommandReversalWithUI`'s localized name and icon.

## The commands host

Place a `CommandsHost` at the root of each window, and inside any sheet that contains command
buttons:

```swift
WindowGroup {
  CommandsHost(commander: engine.commander) {
    RootView()
  }
}
```

The host injects the commander into the environment, and presents the alerts that command
buttons request. This is what lets a confirmation work from a menu: a button inside a menu is
discarded when the menu closes, and a macOS `CommandMenu` has no view hierarchy, so the button
cannot present an alert of its own. Instead it asks the host's `CommandPresenter`, which the
button finds in the environment, or through the focused scene in the menu bar.

`button(_:)` and `confirmableButton(_:)` both ask the host to confirm when the command declares
a confirmation. Pass `confirming: false` to `button(_:)` to run the command immediately.

Without a host, `confirmableButton(_:)` falls back to a confirmation dialog on the button itself,
which the system anchors to the button where it can (a popover on a regular-width iPad), and which
works outside menus, and `button(_:)` runs the command unconfirmed and logs a warning.

## UIKit and Mac Catalyst

Subclass `CommandCentreDelegate` to build `UICommand`, `UIKeyCommand`, and
inline `UIMenu` values. Use stable command IDs: the delegate uses them to
replace registered invocations as menus are rebuilt.

## Localization

The target supplies localized defaults for confirmation, Undo, and Redo. Add
application-specific command metadata to the application's resource bundle.
