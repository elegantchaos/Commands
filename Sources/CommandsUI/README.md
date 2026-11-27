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
centre.button(command)
centre.toolbarItem(command)
centre.dynamicButton(command: command(for:))
```

A control leaves itself out while its command is hidden, so a hidden command adds no row to a
list and no item to a menu. Place commands in a toolbar with `toolbarItem(_:)` or
`toolbarItemGroup(_:)`, not a `ToolbarItem` around `button(_:)`: they keep the toolbar steady
as availability changes, and on macOS a hidden command leaves no slot. Each has a `content:` form
for a custom label, like `button(_:content:)`. On iOS a hidden command
leaves an empty toolbar item.

`importer(_:)` and `importerButton(_:isShowingImportSheet:)` support file-import
commands. `historyUndoButton()` and `historyRedoButton()` remain visible but disabled when no
operation is available. Set `showsCommandPresentation: true` to label them with
the localized name and icon of the command that made the pending step, such as "Undo
Increment", when it adopts `CommandWithUI`.
A `CommandWithUI` that also adopts `CommandWithUndo` names its `UndoManager`
action with its localized name.

## Confirmation

A command opts into confirmation by returning one from `confirmation(centre:)`. The simplest is
`defaultConfirmation(centre:)`, a stock dialog titled with the command's name:

```swift
func confirmation(centre: Centre) -> CommandConfirmation? {
  defaultConfirmation(centre: centre)
}
```

`button(_:)`, `toolbarItem(_:)`, `dynamicButton`, the importer controls and UIKit menu commands then confirm before performing the command. An importer asks after the user has chosen a file.
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
  centre.button(ResetCommand())
}
.commandConfirmation(.hosted)
```

## The commands host

Place a `CommandsHost` at the root of each window, and inside any sheet that contains command
buttons:

```swift
WindowGroup {
  CommandsHost(centre: engine.centre) {
    RootView()
  }
}
```

The host injects the command centre into the environment, and presents the alerts that `.hosted`
buttons request. A button inside a menu is discarded when the menu closes, and a macOS
`CommandMenu` has no view hierarchy, so neither can present a dialog of their own. They ask the
host's `CommandPresenter` instead, which a button finds in the environment, or through the focused
scene in the menu bar. Without a host, `.hosted` falls back to `.local`, which a menu cannot show:
a menu button needs a host.

A host shows one confirmation at a time. A request made while one is on screen is refused, and the alert's buttons and dismissal act only on the request it shows.

## UIKit and Mac Catalyst

Subclass `CommandCentreDelegate` to build `UICommand`, `UIKeyCommand`, and inline `UIMenu` values in `buildMenu(with:)`, calling `super.buildMenu(with:)` before or after adding them. Each generated item runs its own command, even when several share a command ID; the delegate discards the invocations of items that menu rebuilds have replaced.

A command that declares a confirmation asks for it before it runs. Set the delegate's `commandPresenter` to use a `CommandsHost`'s presenter; otherwise the delegate shows an alert on the key window, or override `confirm(_:perform:)` to confirm another way.

## Localization

The target supplies localized defaults for confirmation, Undo, and Redo. Add
application-specific command metadata to the application's resource bundle.
