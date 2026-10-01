// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI
import UniformTypeIdentifiers

/// SwiftUI helpers for rendering and invoking commands from a `CommandCentre`.
@MainActor
extension CommandCentre {
  /// Returns a labelled button for the given command, or nothing when it is hidden.
  ///
  /// A command opts into confirmation by returning one from `confirmation(centre:)`. The button
  /// then confirms before performing it, in the mode the environment sets (`.local` unless a
  /// parent sets another with `commandConfirmation(_:)`). Pass `confirmation` to choose a mode for
  /// this button alone, including `.never` to skip confirmation.
  @ViewBuilder public func button<C: CommandWithUI>(
    _ command: C, role: ButtonRole? = nil, confirmation: CommandConfirmationMode? = nil
  ) -> some View where C.Centre == Self {
    CommandButton(command: command, commander: self, role: role, confirmation: confirmation)
  }

  /// Returns a button for the given command with custom content, or nothing when it is hidden.
  @ViewBuilder public func button<C: CommandWithUI, Content: View>(
    _ command: C, role: ButtonRole? = nil, confirmation: CommandConfirmationMode? = nil,
    content: @escaping () -> Content
  ) -> some View where C.Centre == Self {
    CommandButton(command: command, commander: self, role: role, confirmation: confirmation) { _ in
      content()
    }
  }

  /// Returns a button that passes the command into the content builder, or nothing when it is hidden.
  @ViewBuilder public func button<C: CommandWithUI, Content: View>(
    _ command: C, role: ButtonRole? = nil, confirmation: CommandConfirmationMode? = nil,
    content: @escaping (C) -> Content
  ) -> some View where C.Centre == Self {
    CommandButton(
      command: command, commander: self, role: role, confirmation: confirmation,
      content: content)
  }

  /// Return a button that resolves a concrete command from an activation trigger.
  ///
  /// The resolved command confirms first if it declares a confirmation, as `button(_:)` does.
  @ViewBuilder public func dynamicButton<C: CommandWithUI, Content: View>(
    role: ButtonRole? = nil,
    confirmation: CommandConfirmationMode? = nil,
    command: @escaping @MainActor (CommandTrigger) -> C,
    @ViewBuilder content: () -> Content
  ) -> some View where C.Centre == Self {
    DynamicCommandButton(
      commander: self,
      role: role,
      command: command,
      content: content(),
      confirmation: confirmation
    )
  }

  /// Return a labelled button that resolves a concrete command from an activation trigger.
  @ViewBuilder public func dynamicButton<C: CommandWithUI>(
    role: ButtonRole? = nil,
    confirmation: CommandConfirmationMode? = nil,
    command: @escaping @MainActor (CommandTrigger) -> C
  ) -> some View where C.Centre == Self {
    let primaryCommand = command(.primary)
    dynamicButton(role: role, confirmation: confirmation, command: command) {
      CommandLabel(command: primaryCommand, centre: self)
    }
  }

  /// Returns a button that confirms before executing the command, or nothing when it is hidden.
  @available(
    *, deprecated,
    message:
      "Use button(_:role:). A command opts into confirmation by returning one from confirmation(centre:), for example defaultConfirmation(centre:)."
  )
  @ViewBuilder public func confirmableButton<C: CommandWithUI>(
    _ command: C, role: ButtonRole? = nil
  ) -> some View
  where C.Centre == Self {
    button(command, role: role)
  }

  /// Returns a toolbar item for the given command, or nothing when it is hidden.
  @ToolbarContentBuilder public func toolbarItem<C: CommandWithUI>(
    _ command: C, placement: ToolbarItemPlacement = .automatic,
    confirmation: CommandConfirmationMode? = nil
  ) -> some ToolbarContent where C.Centre == Self {
    if availability(command) != .hidden {
      ToolbarItem(placement: placement) {
        button(command, confirmation: confirmation)
      }
    }
  }

  /// Returns a toolbar item that confirms before executing the command, or nothing when it is hidden.
  @available(
    *, deprecated,
    message:
      "Use toolbarItem(_:placement:). A command opts into confirmation by returning one from confirmation(centre:), for example defaultConfirmation(centre:)."
  )
  @ToolbarContentBuilder public func confirmableToolbarItem<C: CommandWithUI>(
    _ command: C, placement: ToolbarItemPlacement = .automatic
  ) -> some ToolbarContent where C.Centre == Self {
    toolbarItem(command, placement: placement)
  }

  /// Returns a toolbar item group for the given command, or nothing when it is hidden.
  @ToolbarContentBuilder public func toolbarItemGroup<C: CommandWithUI>(
    _ command: C, placement: ToolbarItemPlacement = .automatic,
    confirmation: CommandConfirmationMode? = nil
  ) -> some ToolbarContent where C.Centre == Self {
    if availability(command) != .hidden {
      ToolbarItemGroup(placement: placement) {
        button(command, confirmation: confirmation)
      }
    }
  }

  /// Returns a labelled button for the given command, or nothing when it is hidden.
  /// When the button is pressed, an importer sheet is shown.
  /// When the import is confirmed, the command is performed with the selected URLs.
  @ViewBuilder public func importer<C: CommandWithUI>(_ command: C, role: ButtonRole? = nil)
    -> some View where C: ImporterCommand, C.Centre == Self
  {
    ImporterCommandButton(command: command, centre: self, role: role)
  }

  /// Returns a button that shows an importer sheet when activated.
  ///
  /// Note that this button builds on watchOS/tvOS, but the importer sheet
  /// itself is not available on those platforms, so the button will not do
  /// anything when pressed.
  @ViewBuilder public func importerButton<C: ImporterCommand>(
    _ command: C,
    isShowingImportSheet: Binding<Bool>
  ) -> some View where C.Centre == Self {
    ImporterCommandShowButton(
      command: command, centre: self, isShowingImportSheet: isShowingImportSheet)
  }
}

@MainActor
extension UndoableCommandCentre {
  /// Returns a button that performs the next undo operation.
  @ViewBuilder public func undoButton(
    role: ButtonRole? = nil,
    showsCommandPresentation: Bool = false
  ) -> some View {
    UndoCommandButton(
      undoService: undoService,
      role: role,
      showsCommandPresentation: showsCommandPresentation
    )
  }

  /// Returns a button that performs the next redo operation.
  @ViewBuilder public func redoButton(
    role: ButtonRole? = nil,
    showsCommandPresentation: Bool = false
  ) -> some View {
    RedoCommandButton(
      undoService: undoService,
      role: role,
      showsCommandPresentation: showsCommandPresentation
    )
  }
}
