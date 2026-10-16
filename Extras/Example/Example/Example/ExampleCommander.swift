// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import SwiftUI

/// The example app's command centre: the counter service for the undo demonstration and the
/// state for the bench.
final class ExampleCommander: UndoableCommandCentre, ExampleServiceProvider, BenchStateProvider {
  /// The counter the example command changes.
  var service = ExampleService()

  /// The undo history.
  var undoService: UndoService = UndoService()

  /// The state bench commands read.
  var bench = BenchState()
}
