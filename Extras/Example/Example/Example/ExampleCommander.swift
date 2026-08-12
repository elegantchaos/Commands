
import Commands
import CommandsUI

import SwiftUI


@MainActor
@Observable
class ExampleUndoService: UndoService {
  
  override init() {
    super.init()
  }

  var undoStack: [CommandInverse] = []
  
  override var hasUndo: Bool {
    !undoStack.isEmpty
  }
  
  override func recordUndo(_ invocation: CommandInverse) {
    undoStack = undoStack + [invocation]
    
  }
  
  override func performUndo() {
    if let last = undoStack.popLast() {
      let inv = last.perform
      Task {
        do {
          _ = try await inv()
        } catch {
          
        }
      }
    }
  }
  
  override var debugDescription: String {
    undoStack
      .map { $0.id }
      .joined(separator: " > ")
  }
}

class ExampleCommander: UndoableCommandCenter, ExampleServiceProvider {
  var service = ExampleService()
  var undoService: UndoService = ExampleUndoService()
}
