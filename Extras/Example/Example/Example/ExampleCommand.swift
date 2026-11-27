// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Icons

/// Increments the example service count.
struct ExampleCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  /// Stable identifier, also used to look up the command's localized name.
  let id = "com.elegantchaos.commands.example"

  /// Returns the icon shown on the command's button.
  func icon(centre: Centre) -> Icons.Icon {
    Icon("command")
  }

  /// Increments the count.
  func perform(centre: Centre) async throws {
    centre.service.incrementDone()
  }
}

/// Decrements the example service count.
struct ExampleUndoCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  /// Stable identifier, also used to look up the command's localized name.
  let id = "com.elegantchaos.commands.undo"

  /// Returns the icon shown on the command's button.
  func icon(centre: Centre) -> Icons.Icon {
    Icon("command")
  }

  /// Decrements the count.
  func perform(centre: Centre) async throws {
    centre.service.decrementDone()
  }
}

/// The increment is reversed by a decrement when the centre keeps history.
extension ExampleCommand: CommandWithHistory where Centre: CommandCentreWithHistory {
  /// Returns the command that decrements the count again.
  func reversal(centre: Centre) -> ExampleUndoCommand<Centre>? {
    ExampleUndoCommand()
  }
}

/// The decrement is reversed by an increment when the centre keeps history.
extension ExampleUndoCommand: CommandWithHistory where Centre: CommandCentreWithHistory {
  /// Returns the command that increments the count again.
  func reversal(centre: Centre) -> ExampleCommand<Centre>? {
    ExampleCommand()
  }
}
