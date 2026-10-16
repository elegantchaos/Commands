# Stable Command Control Identity

## Problem

In Bookish on macOS, every item in a window's toolbar flickered whenever a command button in
it changed availability: when Done became disabled while a field held invalid input, and
repeatedly at launch as commands settled. Bookish bisected it with a plain SwiftUI button and a
minimal sample app.

- A plain `Button` with the same availability did not flicker.
- Removing `CommandButton`'s confirmation dialog, confirmation state, presentation modifiers,
  keyboard shortcut or tooltip, or using a verbatim label, did not stop it.
- Removing the `if availability != .hidden` that formed the outermost view of `body` stopped
  it, although the branch never changed.
- Keeping the conditional inside a fixed `VStack` also stopped it, with shortcuts, tooltips and
  menu items unaffected.

So the trigger is a toolbar item whose content's outermost view is conditional: each time that
content re-evaluates, SwiftUI rebuilds every toolbar item.

## Change

`commandPresentation(availability:help:shortcut:isPerforming:)` already took a control's
availability and applied its disabled state, keyboard shortcut and help. It now also leaves the
control out while the command is hidden, inside a `VStack` that adds no spacing, so one modifier
decides what availability means for a control. `CommandButton`, `DynamicCommandButton`,
`ImporterCommandButton`, `ImporterCommandShowButton`, `UndoCommandButton` and
`RedoCommandButton` drop their top-level `if` and apply the modifier last, so a hidden command
still leaves out its whole control, including a confirmation dialog or importer sheet attached
to it. A first version used a separate `CommandVisibility` container taking a boolean; it
duplicated the modifier's use of availability and was folded into it.

## Verification

The package builds and its tests pass. In Bookish on macOS, a `VStack` placed directly in
`CommandButton.body`, and then the `CommandVisibility` container, each removed the flicker
when Done changed state and at launch, with shortcuts, tooltips and menu items still working.
The modifier form then held too: making the year invalid no longer flickers the toolbar.
Cancel's discard confirmation and the launch flicker were not separately rechecked. The view structure has no automated test, and iOS was
not checked.

## Toolbar Helpers

`toolbarItem` and `toolbarItemGroup` chose between an item and none with
`if availability(command) != .hidden`, evaluated in the caller's toolbar body. Every command
placed with them made the caller's whole toolbar depend on its availability and gave it
conditional structure, the shape behind the flicker. They now always return their item or
group, holding the command's button, and never read availability; the button leaves itself out
while the command is hidden, so a hidden command leaves an empty item. `ToolbarContent.hidden(_:)`
would avoid the empty item on macOS 15 and later but not on iOS, and reading availability to
drive it would bring back the caller's dependency. No known caller hides a command placed in a
toolbar: Bookish and Stack were searched.

## Omission and Toolbar Items

A review of the companion guidance change pointed out that a fixed container is not equivalent
to a conditional: it is still present when its content is absent. A sample with real command
buttons confirmed it: with the `VStack` in `commandPresentation`, a hidden command left a blank
list row and an empty toolbar slot, though menus and the menu bar showed no gap.

- `commandPresentation` leaves the control out again while its command is hidden, with no
  container, so lists and menus get no entry for a hidden command.
- `CommandToolbarItem` and `CommandToolbarItemGroup` are toolbar content that holds a command's
  button inside a `VStack` that adds no spacing, reads the command's availability in its own
  body, and on macOS hides itself with `hidden(_:)` while the command is hidden, so it leaves no
  slot. iOS has no way to hide toolbar content, so a hidden command there leaves an empty item.
  `toolbarItem` and `toolbarItemGroup` return them.
- In Bookish, the editing toolbar moved from `ToolbarItem { button(_:) }` to `toolbarItem(_:)`.
  Making a year invalid no longer flickers the toolbar there. Toolbars still redraw when editing
  starts or ends and when Cancel's confirmation appears; keeping the items present and hiding
  them did not help, so those transitions are a separate investigation in Bookish.

## Example Bench

The example app is now a bench with Toolbar, Lists and Menus, and Undo and Redo pages, Edit menu
commands, and bench commands whose availability is fixed or toggled on a timer, with separate
switches for enabled state and visibility. Its README lists the pages and the manual checks.
`ExampleUITests` replaces the template tests: on macOS they check that a hidden command adds no
list row, menu item, Edit menu item or toolbar button, and that toolbar buttons follow changing
availability. The test plan had no targets, so the Example scheme could not test; it now runs
the UI tests. With the `VStack` restored to `commandPresentation`, the list test failed, three
rows against two.

The bench did not reproduce the original flicker, even with a copy of the old conditional-root
button, so it does not show the toolbar fix working; Bookish did. The bench is for exercising
the controls' behaviour, not for reproducing bugs.

The project still has an `ExampleTests` target whose sources were removed, which can make
incremental builds fail to sign the app.

## Review Fixes

A diff review of the PR found four things to fix, all addressed:

- Toolbar items had no form with a custom label, so a toolbar command with its own label had to
  stay in a direct `ToolbarItem`, as Bookish's New button did. `toolbarItem` and
  `toolbarItemGroup`, and the two item types, now have `content:` forms.
- `CommandToolbarItem` and `CommandToolbarItemGroup` repeated each other. They now share
  `CommandToolbarButton`, which holds the button in its fixed stack, and a `commandHidden(_:)`
  toolbar-content extension for the macOS hiding, and each has its own file. `CommandButton`'s
  initialisers delegate to one that takes an optional label.
- The new bench views have previews.
- The UI tests hold the application in a constant instead of an implicitly unwrapped optional.

The bench toolbar has a command with a custom label, and a UI test checks it shows. The review's
suggestions, about modifier order under `.disabled`, a doc comment's certainty, the bench's
duplicated helper and its unlocalized names, are left open.
