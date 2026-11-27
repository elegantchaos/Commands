// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import SwiftUI

/// The example app's main command centre: the counter and history for the History page, and the
/// state the bench commands read.
final class ExampleCentre: CommandCentreWithHistory, ExampleServiceProvider, BenchStateProvider {
  /// The counter the History page's commands change.
  let service = ExampleService()

  /// History that the History page's undo and redo buttons perform.
  let historyService = HistoryService()

  /// The state bench commands read.
  let bench = BenchState()
}
