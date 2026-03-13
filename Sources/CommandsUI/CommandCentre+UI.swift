// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// SwiftUI helpers for rendering and invoking commands from a `CommandCentre`.
@MainActor
public extension CommandCentre {
  /// Returns whether the given command should be disabled in the current UI state.
  // TODO: track commands whilst they are running, and disable their buttons appropriately
  func shouldDisable<C: CommandWithUI>(_ command: C) -> Bool where C.Centre == Self {
    switch availability(command) {
      case .disabled, .running, .runningSilently: return true
      default: return false
    }
  }

  /// Returns a labelled button for the given command, or nothing when it is hidden.
  @ViewBuilder func button<C: CommandWithUI>(_ command: C, role: ButtonRole? = nil) -> some View where C.Centre == Self {
    let availability = availability(command)
    if availability != .hidden {
      Button(role: role, action: { performWithoutWaiting(command) }) {
        Label(command.name, icon: command.icon)
      }
      .disabled(shouldDisable(command))
      #if !os(watchOS) && !os(tvOS)
        .keyboardShortcut(command.shortcut)
      #endif
      .help(command.help ?? "")
    }
  }

  /// Returns a button for the given command with custom content, or nothing when it is hidden.
  @ViewBuilder func button<C: CommandWithUI, Content: View>(_ command: C, role: ButtonRole? = nil, content: () -> Content) -> some View where C.Centre == Self {
    let availability = availability(command)
    if availability != .hidden {
      Button(role: role, action: { performWithoutWaiting(command) }) {
        content()
      }
      .disabled(shouldDisable(command))
      #if !os(watchOS) && !os(tvOS)
        .keyboardShortcut(command.shortcut)
      #endif
      .help(command.help ?? "")
    }
  }

  /// Returns a button that passes the command into the content builder, or nothing when it is hidden.
  @ViewBuilder func button<C: CommandWithUI, Content: View>(_ command: C, role: ButtonRole? = nil, content: (C) -> Content) -> some View where C.Centre == Self {
    let availability = availability(command)
    if availability != .hidden {
      Button(role: role, action: { performWithoutWaiting(command) }) {
        content(command)
      }
      .disabled(shouldDisable(command))
      #if !os(watchOS) && !os(tvOS)
        .keyboardShortcut(command.shortcut)
      #endif
      .help(command.help ?? "")
    }
  }

  /// Return a button that resolves a concrete command from an activation trigger.
  @ViewBuilder func dynamicButton<C: CommandWithUI, Content: View>(
    role: ButtonRole? = nil,
    command: @escaping @MainActor (CommandTrigger) -> C,
    content: @escaping () -> Content
  ) -> some View where C.Centre == Self {
    if availability(command(.primary)) != .hidden {
      DynamicCommandButton(commander: self, role: role, command: command, content: content)
    }
  }

  /// Return a labelled button that resolves a concrete command from an activation trigger.
  @ViewBuilder func dynamicButton<C: CommandWithUI>(
    role: ButtonRole? = nil,
    command: @escaping @MainActor (CommandTrigger) -> C
  ) -> some View where C.Centre == Self {
    let primaryCommand = command(.primary)
    dynamicButton(role: role, command: command) {
      Label(primaryCommand.name, icon: primaryCommand.icon)
    }
  }

  /// Returns a button that confirms before executing the command, or nothing when it is hidden.
  @ViewBuilder func confirmableButton<C: CommandWithUI>(_ command: C) -> some View where C.Centre == Self {
    let availability = availability(command)
    if availability != .hidden {
      ConfirmableCommandButton(command: command, commander: self)
        .disabled(shouldDisable(command))
        #if !os(watchOS) && !os(tvOS)
          .keyboardShortcut(command.shortcut)
        #endif
        .help(command.help ?? "")
    }
  }

  /// Returns a toolbar item for the given command, or nothing when it is hidden.
  @ToolbarContentBuilder func toolbarItem<C: CommandWithUI>(_ command: C, placement: ToolbarItemPlacement = .automatic) -> some ToolbarContent where C.Centre == Self {
    if availability(command) != .hidden {
      ToolbarItem(placement: placement) {
        button(command)
      }
    }
  }

  /// Returns a toolbar item that confirms before executing the command, or nothing when it is hidden.
  @ToolbarContentBuilder func confirmableToolbarItem<C: CommandWithUI>(_ command: C, placement: ToolbarItemPlacement = .automatic) -> some ToolbarContent where C.Centre == Self {
    if availability(command) != .hidden {
      ToolbarItem(placement: placement) {
        confirmableButton(command)
      }
    }
  }

  /// Returns a toolbar item group for the given command, or nothing when it is hidden.
  @ToolbarContentBuilder func toolbarItemGroup<C: CommandWithUI>(_ command: C, placement: ToolbarItemPlacement = .automatic) -> some ToolbarContent where C.Centre == Self {
    if availability(command) != .hidden {
      ToolbarItemGroup(placement: placement) {
        button(command)
      }
    }
  }

  //  func menu<each C: Command>(_ command: repeat each C) -> some View where repeat (each C).Centre == Self {
  //    return Menu {
  //      repeat button(each command)
  //    } label: {
  //      Label("action.more", systemImage: "ellipsis.circle")
  //    }
  //  }

}
