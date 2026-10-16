// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// A command's button for toolbar content, held in a fixed stack.
///
/// On macOS, a toolbar item whose content's outermost view is conditional makes SwiftUI rebuild
/// every item in the window's toolbar each time that content re-evaluates, even when the
/// condition has not changed, so the whole toolbar flickers. A command button is conditional,
/// since it leaves itself out while its command is hidden, so `CommandToolbarItem` and
/// `CommandToolbarItemGroup` hold it inside this stack, which adds no spacing.
struct CommandToolbarButton<C: CommandWithUI, CC: CommandCentre, Content: View>: View
where C.Centre == CC {
  /// The command the button performs.
  let command: C

  /// The centre that evaluates and performs the command.
  let centre: CC

  /// Where the button presents the command's confirmation, or nil to use the environment's.
  let confirmation: CommandConfirmationMode?

  /// Custom label content, or nil for the command's standard label.
  let content: ((C) -> Content)?

  /// Whether the command is hidden, for the toolbar content holding the button.
  var isHidden: Bool { centre.availability(command) == .hidden }

  /// The button inside a stack that adds no spacing.
  var body: some View {
    VStack(spacing: 0) {
      CommandButton(
        command: command, commander: centre, confirmation: confirmation, optionalContent: content)
    }
  }
}
