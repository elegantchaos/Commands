# Example

The example app is a bench for Commands' SwiftUI controls. Each page shows command controls in one of the places they are used, with commands whose availability is fixed or changes on a timer, so the controls' behaviour can be checked as the package changes.

## Pages

- **Toolbar:** four commands placed with `toolbarItem(_:)`: always enabled, always hidden, switching between enabled and disabled, and switching between enabled and hidden. Two switches toggle the changing ones every 1.5 seconds, independently.
- **Lists and Menus:** a list and a menu with a hidden command between two enabled ones, beside the same containers without it.
- **Undo and Redo:** a command that changes a counter, with Undo and Redo buttons and the undo stack.

The Edit menu also has two enabled commands with a hidden one between them, and one that switches between enabled and hidden.

## Automated Checks

`ExampleUITests` checks, on macOS, that a hidden command adds no list row, menu item, Edit menu item or toolbar button, that a toolbar button follows its command between enabled and disabled, and that a toolbar button for a command that switches to hidden disappears. Run them with the Example scheme's test action.

If an incremental build fails to sign the app, delete the derived data and build again: the project still has an `ExampleTests` unit-test target whose sources were removed.

## Manual Checks

Flicker cannot be detected by a test. On macOS, after a change to the controls:

1. On the Toolbar page, turn on only "Toggle enabled". Only Tool Toggling should change; if any other item, including the sidebar button, redraws, the toolbar is flickering.
2. Turn on "Toggle visible". The toolbar should resize as Tool Appearing comes and goes, with no gap where Tool Hidden would be.
3. Check that toolbar buttons show their tooltips, and that the Edit menu's commands show no gap for the hidden one.
