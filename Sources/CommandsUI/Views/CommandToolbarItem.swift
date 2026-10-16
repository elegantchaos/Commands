// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// A toolbar item holding a command's button, which keeps the toolbar steady as the command's
/// availability changes.
///
/// On macOS, a toolbar item whose content's outermost view is conditional makes SwiftUI rebuild
/// every item in the window's toolbar each time that content re-evaluates, even when the
/// condition has not changed, so the whole toolbar flickers. A command button is conditional,
/// since it leaves itself out while its command is hidden, so this item holds it inside a stack
/// that adds no spacing. The item reads the command's availability in its own body, never in
/// the caller's toolbar. On macOS it hides itself while the command is hidden; elsewhere a hidden
/// command leaves an empty item, since there is no equivalent of `hidden(_:)` for toolbar content.
public struct CommandToolbarItem<C: CommandWithUI, CC: CommandCentre>: ToolbarContent
where C.Centre == CC {
  /// The command the item's button performs.
  public let command: C

  /// The centre that evaluates and performs the command.
  public let centre: CC

  /// Where the item goes in the toolbar.
  public let placement: ToolbarItemPlacement

  /// Where the button presents the command's confirmation, or nil to use the environment's.
  public let confirmation: CommandConfirmationMode?

  /// Creates an item for a command.
  public init(
    command: C, centre: CC, placement: ToolbarItemPlacement = .automatic,
    confirmation: CommandConfirmationMode? = nil
  ) {
    self.command = command
    self.centre = centre
    self.placement = placement
    self.confirmation = confirmation
  }

  /// The item, holding the button in a fixed stack, and hidden on macOS with its command.
  public var body: some ToolbarContent {
    ToolbarItem(placement: placement) {
      VStack(spacing: 0) {
        CommandButton(command: command, commander: centre, confirmation: confirmation)
      }
    }
    #if os(macOS)
      .hidden(centre.availability(command) == .hidden)
    #endif
  }
}

/// A toolbar item group holding a command's button, steady as the command's availability
/// changes, as `CommandToolbarItem` describes.
public struct CommandToolbarItemGroup<C: CommandWithUI, CC: CommandCentre>: ToolbarContent
where C.Centre == CC {
  /// The command the group's button performs.
  public let command: C

  /// The centre that evaluates and performs the command.
  public let centre: CC

  /// Where the group goes in the toolbar.
  public let placement: ToolbarItemPlacement

  /// Where the button presents the command's confirmation, or nil to use the environment's.
  public let confirmation: CommandConfirmationMode?

  /// Creates a group for a command.
  public init(
    command: C, centre: CC, placement: ToolbarItemPlacement = .automatic,
    confirmation: CommandConfirmationMode? = nil
  ) {
    self.command = command
    self.centre = centre
    self.placement = placement
    self.confirmation = confirmation
  }

  /// The group, holding the button in a fixed stack, and hidden on macOS with its command.
  public var body: some ToolbarContent {
    ToolbarItemGroup(placement: placement) {
      VStack(spacing: 0) {
        CommandButton(command: command, commander: centre, confirmation: confirmation)
      }
    }
    #if os(macOS)
      .hidden(centre.availability(command) == .hidden)
    #endif
  }
}
