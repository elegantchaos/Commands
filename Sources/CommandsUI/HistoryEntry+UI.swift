// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands

@MainActor
extension HistoryEntry {
  /// UI metadata for the action that names the entry's step, or `nil` when the action does not adopt `CommandWithUI`.
  var presentation: HistoryEntryPresentation? {
    guard let action = action as? any CommandWithUI else {
      return nil
    }
    return HistoryEntryPresentation(command: action, centre: centre)
  }
}
