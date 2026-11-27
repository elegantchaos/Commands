// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands

@MainActor
extension HistoryEntry {
  /// UI metadata for the entry's command, or `nil` when the command does not adopt `CommandWithUI`.
  var presentation: HistoryEntryPresentation? {
    guard let command = command as? any CommandWithUI else {
      return nil
    }
    return HistoryEntryPresentation(command: command, centre: centre)
  }
}
