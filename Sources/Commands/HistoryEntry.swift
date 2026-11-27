// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// One step in a `HistoryService`: a command to perform for undo or redo, bound to its centre.
///
/// The entry captures its command and centre when it is created, and performs the command
/// through the centre's `perform(_:during:)`. Performing an entry returns the entry for the command's own
/// reversal, which the service stores in its place. UI layers read `command` and `centre`
/// to present the pending step.
@MainActor
public struct HistoryEntry {
  /// The command this entry performs.
  public let command: any Command

  /// The centre that evaluates and performs `command`.
  public let centre: any CommandCentre

  /// Returns the command's current availability through its centre.
  private let currentAvailability: () -> CommandAvailability

  /// Performs the command in a history context and returns the entry for its reversal.
  private let performer: (CommandExecutionContext) async throws -> HistoryEntry?

  /// Creates an entry that performs the supplied command through its centre.
  init<C: CommandWithHistory>(command: C, centre: C.Centre) {
    self.command = command
    self.centre = centre
    currentAvailability = { centre.availability(command) }
    performer = { context in
      _ = try await centre.perform(command, during: context)
      return command.reversal(centre: centre).map { HistoryEntry(command: $0, centre: centre) }
    }
  }

  /// Identifier of the entry's command.
  public var id: String {
    command.id
  }

  /// Returns the command's current availability, including the centre's running and history state.
  public func availability() -> CommandAvailability {
    currentAvailability()
  }

  /// Performs the command in the supplied history context and returns the entry that reverses it.
  ///
  /// The context is used only for this invocation.
  func perform(in context: CommandExecutionContext) async throws -> HistoryEntry? {
    try await performer(context)
  }
}
