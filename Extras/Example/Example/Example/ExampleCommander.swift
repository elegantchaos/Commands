
import Commands
import CommandsUI

import SwiftUI


@MainActor
@Observable
class ExampleUndoService: UndoService {
  
  override init() {
    super.init()
  }

  var undoStack: [UndoInvocation] = []
  
  override var hasUndo: Bool {
    !undoStack.isEmpty
  }
  
  override func recordUndo(_ invocation: UndoInvocation) {
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
}

class ExampleCommander: UndoableCommandCenter, ExampleServiceProvider {
  var service = ExampleService()
  var undoService: UndoService = ExampleUndoService()
}
