//
//  ExampleCommand.swift
//  Example
//
//  Created by Sam Deane on 05/08/2026.
//

import CommandsUI
import Icons

struct ExampleCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  let id = "com.elegantchaos.commands.example"

  func icon(centre: Centre) -> Icons.Icon {
    Icon("command")
  }

  func perform(centre: Centre) throws {
    centre.service.incrementDone()
  }
  
  func commandForUndo(centre: Centre) -> ExampleUndoCommand<Centre> {
    ExampleUndoCommand()
  }
}

struct ExampleUndoCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  let id = "com.elegantchaos.commands.undo"

  func icon(centre: Centre) -> Icons.Icon {
    Icon("command")
  }

  func perform(centre: Centre) throws {
    centre.service.decrementDone()
  }
  
  func commandForUndo(centre: Centre) -> ExampleCommand<Centre> {
    ExampleCommand()
  }
}

