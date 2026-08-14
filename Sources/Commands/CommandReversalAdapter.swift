// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Adapts a command and its centre into a `CommandReversal`.
@MainActor
public struct CommandReversalAdapter<C: Command>: CommandReversal {
  /// Command performed by this reversal.
  let command: C

  /// Centre that evaluates and performs the command.
  let centre: C.Centre

  /// Creates a reversal that performs the supplied command through its centre.
  public init(command: C, centre: C.Centre) {
    self.command = command
    self.centre = centre
  }

  /// Stable identifier forwarded from the command.
  public var id: String {
    command.id
  }

  /// Returns the command's current availability.
  public func availability() -> CommandAvailability {
    centre.availability(command)
  }

  /// Performs the command and returns the reversal it supplies.
  public func perform(in context: CommandExecutionContext) async throws -> (any CommandReversal)? {
    _ = try await centre.perform(command, during: context)
    return command.reversal(centre: centre)
  }
}
