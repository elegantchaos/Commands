// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons
import SwiftUI

/// The standard accessible label for a UI-capable command.
@MainActor
struct CommandLabel<C: CommandWithUI>: View {
  /// Command whose metadata is displayed.
  let command: C

  /// Command centre used to resolve metadata.
  let centre: C.Centre

  /// Current requested label visibility.
  @Environment(\.labelsVisibility) private var labelsVisibility

  /// Renders the command's icon and localized name.
  var body: some View {
    #if os(tvOS)
      if labelsVisibility == .hidden {
        Image(icon: command.icon(centre: centre))
          .accessibilityLabel(command.name(centre: centre))
      } else {
        Label(command.name(centre: centre), icon: command.icon(centre: centre))
      }
    #else
      Label(command.name(centre: centre), icon: command.icon(centre: centre))
    #endif
  }
}
