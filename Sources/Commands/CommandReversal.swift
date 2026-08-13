// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Describes an operation that reverses a command.
///
/// Performing a reversal returns the opposing reversal, allowing an
/// `UndoService` to move between undo and redo without losing its state.
@MainActor
public protocol CommandReversal {
  /// Stable identifier for the reversal.
  var id: String { get }

  /// Returns the reversal's current availability.
  func availability() -> CommandAvailability

  /// Performs the reversal in the supplied execution context.
  ///
  /// Implementations must use the context only for this invocation and must not
  /// retain or reuse it.
  func perform(in context: CommandExecutionContext) async throws -> (any CommandReversal)?
}
