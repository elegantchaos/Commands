// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// A toolbar item group holding a command's button, steady as the command's availability
/// changes, as `CommandToolbarItem` describes. Create one with
/// `toolbarItemGroup(_:placement:confirmation:)`, or its `content:` form for a custom label.
public struct CommandToolbarItemGroup<C: CommandWithUI, CC: CommandCentre, Content: View>:
  ToolbarContent
where C.Centre == CC {
  /// Where the group goes in the toolbar.
  let placement: ToolbarItemPlacement

  /// The command's button.
  let button: CommandToolbarButton<C, CC, Content>

  /// Creates a group for a command, with a custom label.
  public init(
    command: C, centre: CC, placement: ToolbarItemPlacement = .automatic,
    confirmation: CommandConfirmationMode? = nil, @ViewBuilder content: @escaping (C) -> Content
  ) {
    self.placement = placement
    button = CommandToolbarButton(
      command: command, centre: centre, confirmation: confirmation, content: content)
  }

  /// The group holding the button, hidden on macOS with its command.
  public var body: some ToolbarContent {
    ToolbarItemGroup(placement: placement) { button }
      .commandHidden(button.isHidden)
  }
}

extension CommandToolbarItemGroup where Content == EmptyView {
  /// Creates a group for a command, with the command's standard label.
  public init(
    command: C, centre: CC, placement: ToolbarItemPlacement = .automatic,
    confirmation: CommandConfirmationMode? = nil
  ) {
    self.placement = placement
    button = CommandToolbarButton(
      command: command, centre: centre, confirmation: confirmation, content: nil)
  }
}
