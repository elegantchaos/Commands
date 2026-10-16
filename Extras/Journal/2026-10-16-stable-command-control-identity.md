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
