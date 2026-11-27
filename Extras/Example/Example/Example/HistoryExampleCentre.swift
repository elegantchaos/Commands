// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import SwiftUI

/// Performs the History tab's commands and records their reversals in its own history.
final class HistoryExampleCentre: CommandCentreWithHistory, ExampleServiceProvider {
  /// Count changed by the commands.
  let service = ExampleService()

  /// History that the tab's undo and redo buttons perform.
  let historyService = HistoryService()
}
