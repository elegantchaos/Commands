//
//  ExampleCommand.swift
//  Example
//
//  Created by Sam Deane on 05/08/2026.
//

import CommandsUI
import Commands
import Icons

@MainActor
struct CommandProxy<C: Command>: CommandInverse {
    let command: C
    let centre: C.Centre
  
  init(command: C, centre: C.Centre) {
    self.command = command
    self.centre = centre
  }
  
  var id: String {
    command.id
  }
  
  var availability: () -> CommandAvailability {
    {
      centre.availability(command)
    }
  }
  
  var perform: @concurrent () async throws -> () {
    {
      _ = try await centre.perform(command)
    }
  }
}

struct ExampleCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  let id = "com.elegantchaos.commands.example"

  func icon(centre: Centre) -> Icons.Icon {
    Icon("command")
  }

  func perform(centre: Centre) async throws {
    centre.service.incrementDone()
  }
  
  func inverse(centre: Centre) -> CommandInverse? {
    return CommandProxy(command: ExampleUndoCommand(), centre: centre)
  }
}

struct ExampleUndoCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  let id = "com.elegantchaos.commands.undo"

  func icon(centre: Centre) -> Icons.Icon {
    Icon("command")
  }

  func perform(centre: Centre) async throws {
    centre.service.decrementDone()
  }
  
  func inverse(centre: Centre) -> CommandInverse? {
    return CommandProxy(command: ExampleCommand(), centre: centre)
//    let command = ExampleCommand<Centre>()
//    return ExampleUndoInvocation(availability: {
//      command.availability(centre: centre)
//    }, perform: {
//      try await command.perform(centre: centre)
//    })
  }
}

