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

## UIKit and Mac Catalyst

Subclass `CommandCentreDelegate` to build `UICommand`, `UIKeyCommand`, and
inline `UIMenu` values. Use stable command IDs: the delegate uses them to
replace registered invocations as menus are rebuilt.

## Localization

The target supplies localized defaults for confirmation, Undo, and Redo. Add
application-specific command metadata to the application's resource bundle.
