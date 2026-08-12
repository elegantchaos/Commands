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
struct ExampleUndoInvocation: UndoInvocation {
  let availability: () -> CommandAvailability
  let perform: @concurrent () async throws -> ()
}

struct ExampleCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  let id = "com.elegantchaos.commands.example"

  func icon(centre: Centre) -> Icons.Icon {
    Icon("command")
  }

  func perform(centre: Centre) async throws {
    centre.service.incrementDone()
  }
  
  func undoInvocation(centre: Centre) -> UndoInvocation? {
    let command = ExampleUndoCommand<Centre>()
    return ExampleUndoInvocation(availability: {
      command.availability(centre: centre)
    }, perform: {
      try await command.perform(centre: centre)
    })
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
  
  func undoInvocation(centre: Centre) -> UndoInvocation? {
    let command = ExampleCommand<Centre>()
    return ExampleUndoInvocation(availability: {
      command.availability(centre: centre)
    }, perform: {
      try await command.perform(centre: centre)
    })
  }
}

