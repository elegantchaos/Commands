// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import SwiftUI

/// Coordinates command execution, example state, and undo history.
@MainActor
final class ExampleCommander: UndoableCommandCentre, ExampleServiceProvider {
  var service = ExampleService()
  var undoService: UndoService = UndoService()
}
