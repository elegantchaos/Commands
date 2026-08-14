// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Icons

/// Increments the example service count and supplies its reversal.
struct ExampleCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  let id = "com.elegantchaos.commands.example"

  func icon(centre: Centre) -> Icons.Icon {
    Icon("command")
  }

  func perform(centre: Centre) async throws {
    centre.service.incrementDone()
  }

  func reversal(centre: Centre) -> (any CommandReversal)? {
    CommandReversalAdapterWithUI(command: ExampleUndoCommand(), centre: centre)
  }
}

/// Decrements the example service count and supplies its reversal.
struct ExampleUndoCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  let id = "com.elegantchaos.commands.undo"

  func icon(centre: Centre) -> Icons.Icon {
    Icon("command")
  }

  func perform(centre: Centre) async throws {
    centre.service.decrementDone()
  }

  func reversal(centre: Centre) -> (any CommandReversal)? {
    CommandReversalAdapterWithUI(command: ExampleCommand(), centre: centre)
  }
}
