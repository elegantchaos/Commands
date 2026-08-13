// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// A basic undo service.
/// Keeps a simple stack of `CommandInverse` instances.
@MainActor
@Observable
open class UndoService {
  /// Stack of command inverses.
  /// Performing the actions of these will undo the commands they represent.
  var undoStack: [CommandInverse] = []

  public init() {
  }

  /// Are there items on the undo stack?
  open var hasUndo: Bool {
    !undoStack.isEmpty
  }

  /// Record a `CommandInverse` on the stack.
  open func recordUndo(_ invocation: CommandInverse) {
    undoStack = undoStack + [invocation]
  }

  /// Perform the `CommandInverse` on the top of the stack.
  open func performUndo() {
    if let action = undoStack.popLast()?.action {
      Task {
        do {
          _ = try await action(.undo)
        } catch {

        }
      }
    }
  }

  /// Textual description of the stack.
  open var stackDescription: String {
    undoStack
      .map { $0.id }
      .joined(separator: " > ")
  }
}

@MainActor
extension UndoService: @MainActor CustomDebugStringConvertible {
  public var debugDescription: String { stackDescription }
}
