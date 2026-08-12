
import Commands
import CommandsUI

import SwiftUI



class ExampleCommander: UndoableCommandCenter, ExampleServiceProvider {
  var service = ExampleService()
  
  var undoStack: [any UndoableCommand] = []
  
  func pushCommand<C: UndoableCommand>(_ command: C) where C.Centre: UndoableCommandCenter {
    let u = command.commandForUndo(centre: self)
    undoStack.append(command)
//    undoStack.append(
//      {
//        performWithoutWaiting(command)
//      }
  }
  
  func popCommand() {
//    undoStack.removeLast()
  }
}
