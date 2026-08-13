// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Icons

/// Increments the example service count and supplies its undo command.
struct ExampleCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  let id = "com.elegantchaos.commands.example"

  func icon(centre: Centre) -> Icons.Icon {
    Icon("command")
  }

  func perform(centre: Centre, from source: CommandSource) async throws {
    centre.service.incrementDone()
  }

  func inverse(centre: Centre) -> CommandInverse? {
    return CommandInverseProxyWithUI(command: ExampleUndoCommand(), centre: centre)
  }
}

/// Decrements the example service count and supplies its redo command.
struct ExampleUndoCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  let id = "com.elegantchaos.commands.undo"

  func icon(centre: Centre) -> Icons.Icon {
    Icon("command")
  }

  func perform(centre: Centre, from source: CommandSource) async throws {
    centre.service.decrementDone()
  }

  func inverse(centre: Centre) -> CommandInverse? {
    return CommandInverseProxyWithUI(command: ExampleCommand(), centre: centre)
    //    let command = ExampleCommand<Centre>()
    //    return ExampleUndoInvocation(availability: {
    //      command.availability(centre: centre)
    //    }, perform: {
    //      try await command.perform(centre: centre)
    //    })
  }
}
