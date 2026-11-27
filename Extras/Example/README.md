# Example

The example app is a bench for Commands' SwiftUI controls. Each page shows command controls in one of the places they are used, with commands whose availability is fixed or changes on a timer, so the controls' behaviour can be checked as the package changes.

## Pages

- **Toolbar:** five commands placed with `toolbarItem(_:)`: always enabled, always hidden, switching between enabled and disabled, switching between enabled and hidden, and one with a custom label. Two switches toggle the changing ones every 1.5 seconds, independently.
- **Lists and Menus:** a list and a menu with a hidden command between two enabled ones, beside the same containers without it.
- **UndoManager:** commands that register their undo actions with the window's `UndoManager`, beside a text field and a text editor. Typing in the editor and the commands undo in the order they happened; on macOS, the text field keeps its own undo stack while it is being edited, so its typing undoes first.
- **History:** a command that undoes through the centre's own `HistoryService`, with Undo and Redo buttons named after the command, and the history stack.

The Edit menu also has two enabled commands with a hidden one between them, and one that switches between enabled and hidden.

## Automated Checks

`ExampleUITests` checks, on macOS, that a hidden command adds no list row, menu item, Edit menu item or toolbar button, that a toolbar button follows its command between enabled and disabled, that a toolbar button for a command that switches to hidden disappears, and that a custom toolbar label is shown. It also checks the order in which typing and commands undo on the UndoManager page; the text field's check is an expected failure. On every platform, it performs, undoes and redoes a command on the UndoManager and History pages. Run them with the Example scheme's default test plan.

On macOS the UI tests take over the screen, so run them on a machine or VM that nobody is using. The scheme's "Full Validation" test plan runs only the package's unit tests, and is the one `agt validate --full` uses; it does not run these UI tests.

## Manual Checks

Flicker cannot be detected by a test. On macOS, after a change to the controls:

1. On the Toolbar page, turn on only "Toggle enabled". Only Tool Toggling should change; if any other item, including the sidebar button, redraws, the toolbar is flickering.
2. Turn on "Toggle visible". The toolbar should resize as Tool Appearing comes and goes, with no gap where Tool Hidden would be.
3. Check that toolbar buttons show their tooltips, and that the Edit menu's commands show no gap for the hidden one.
