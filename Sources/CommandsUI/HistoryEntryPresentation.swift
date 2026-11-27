// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons

/// Current UI metadata for the command held by a history entry.
///
/// History buttons use it to label a pending undo or redo with the command's own name,
/// icon and help. The values are read when the presentation is created, so they reflect
/// the centre's current state.
@MainActor
struct HistoryEntryPresentation {
  /// The command's display name.
  let name: String

  /// The command's icon.
  let icon: Icon

  /// The command's help text, if any.
  let help: String?

  /// Reads the metadata of a UI command through its centre.
  ///
  /// Fails when the centre is not the command's centre type, which cannot happen for an
  /// entry recorded through `HistoryService`.
  init?<C: CommandWithUI>(command: C, centre: any CommandCentre) {
    guard let centre = centre as? C.Centre else {
      return nil
    }
    name = command.name(centre: centre)
    icon = command.icon(centre: centre)
    help = command.help(centre: centre)
  }
}
