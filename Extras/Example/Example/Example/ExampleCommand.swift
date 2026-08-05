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
  
}
