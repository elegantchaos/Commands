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
commander.toolbarItem(command)
commander.dynamicButton(command: command(for:))
```

`importer(_:)` and `importerButton(_:isShowingImportSheet:)` support file-import
commands. `undoButton()` and `redoButton()` remain visible but disabled when no
operation is available. Set `showsCommandPresentation: true` to use a pending
`CommandReversalWithUI`'s localized name and icon.

## Confirmation

A command opts into confirmation by returning one from `confirmation(centre:)`. The simplest is
`defaultConfirmation(centre:)`, a stock dialog titled with the command's name:

```swift
func confirmation(centre: Centre) -> CommandConfirmation? {
  defaultConfirmation(centre: centre)
}
```

`button(_:)`, `toolbarItem(_:)` and `dynamicButton` then confirm before performing the command.
Where the confirmation appears is a `CommandConfirmationMode`:

- `.local` (the default) attaches a dialog to the button, which the system anchors to it where it
  can: a popover pointing at the button on a regular-width iPad.
- `.hosted` asks the window's `CommandsHost` to present an alert. Use it for buttons in menus.
- `.never` runs the command without confirming.

Set the mode for everything inside a view with `.commandConfirmation(_:)` (or
`.withoutConfirmation()`), or for one button with `button(_:confirmation:)`, which wins over the
environment:

```swift
Menu("Debug") {
  commander.button(ResetCommand())
}
.commandConfirmation(.hosted)
```

`confirmableButton(_:)` and `confirmableToolbarItem(_:)` are deprecated and forward to `button(_:)`
and `toolbarItem(_:)`. They no longer confirm a command that declares no confirmation.

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

The host injects the commander into the environment, and presents the alerts that `.hosted`
buttons request. A button inside a menu is discarded when the menu closes, and a macOS
`CommandMenu` has no view hierarchy, so neither can present a dialog of their own. They ask the
host's `CommandPresenter` instead, which a button finds in the environment, or through the focused
scene in the menu bar. Without a host, `.hosted` falls back to `.local`, which a menu cannot show:
a menu button needs a host.

## UIKit and Mac Catalyst

Subclass `CommandCentreDelegate` to build `UICommand`, `UIKeyCommand`, and
inline `UIMenu` values. Use stable command IDs: the delegate uses them to
replace registered invocations as menus are rebuilt.

## Localization

The target supplies localized defaults for confirmation, Undo, and Redo. Add
application-specific command metadata to the application's resource bundle.
