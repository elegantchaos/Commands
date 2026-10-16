// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// A toolbar item holding a command's button, which keeps the toolbar steady as the command's
/// availability changes.
///
/// The button sits in a fixed stack, as `CommandToolbarButton` describes, and the item reads the
/// command's availability in its own body, never in the caller's toolbar. On macOS the item hides
/// itself while the command is hidden; elsewhere a hidden command leaves an empty item. Create one
/// with `toolbarItem(_:placement:confirmation:)`, or its `content:` form for a custom label.
public struct CommandToolbarItem<C: CommandWithUI, CC: CommandCentre, Content: View>: ToolbarContent
where C.Centre == CC {
  /// Where the item goes in the toolbar.
  let placement: ToolbarItemPlacement

  /// The command's button.
  let button: CommandToolbarButton<C, CC, Content>

  /// Creates an item for a command, with a custom label.
  public init(
    command: C, centre: CC, placement: ToolbarItemPlacement = .automatic,
    confirmation: CommandConfirmationMode? = nil, @ViewBuilder content: @escaping (C) -> Content
  ) {
    self.placement = placement
    button = CommandToolbarButton(
      command: command, centre: centre, confirmation: confirmation, content: content)
  }

  /// The item holding the button, hidden on macOS with its command.
  public var body: some ToolbarContent {
    ToolbarItem(placement: placement) { button }
      .commandHidden(button.isHidden)
  }
}

extension CommandToolbarItem where Content == EmptyView {
  /// Creates an item for a command, with the command's standard label.
  public init(
    command: C, centre: CC, placement: ToolbarItemPlacement = .automatic,
    confirmation: CommandConfirmationMode? = nil
  ) {
    self.placement = placement
    button = CommandToolbarButton(
      command: command, centre: centre, confirmation: confirmation, content: nil)
  }
}
