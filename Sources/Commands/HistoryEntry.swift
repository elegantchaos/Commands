// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// One step in a `HistoryService`: a command to perform for undo or redo, bound to its centre.
///
/// The entry captures its command and centre when it is created, and performs the command
/// through the centre's `perform(_:during:)`. Performing an entry returns the entry for the command's own
/// reversal, which the service stores in its place.
///
/// Each entry also holds the action that names its step: the forward command whose effect the
/// step undoes and redoes. The action stays the same as the step moves between undo and redo,
/// so UI layers read `action` and `centre` to label the pending step, such as "Undo Increment"
/// and then "Redo Increment".
@MainActor
public struct HistoryEntry {
  /// The command this entry performs.
  public let command: any Command

  /// The command that names this step, whichever direction it is performed in.
  public let action: any Command

  /// The centre that evaluates and performs `command`, or `nil` once it has been released.
  ///
  /// The entry holds its centre weakly: the centre owns its history service, which owns its
  /// entries, so a strong reference would keep the centre alive.
  public var centre: (any CommandCentre)? {
    centreReference
  }

  /// Weak reference to the centre, which owns the history this entry belongs to.
  private weak var centreReference: (any CommandCentreWithHistory)?

  /// Returns the command's current availability through its centre.
  private let currentAvailability: () -> CommandAvailability

  /// Performs the command in a history context and returns the entry for its reversal.
  private let performer: (CommandExecutionContext) async throws -> HistoryEntry?

  /// Creates an entry that performs the supplied command through its centre, as a step named by `action`.
  init<C: CommandWithHistory, A: Command>(command: C, action: A, centre: C.Centre)
  where A.Centre == C.Centre {
    self.command = command
    self.action = action
    centreReference = centre
    currentAvailability = { [weak centre] in
      centre?.availability(command) ?? .disabled
    }
    performer = { [weak centre] context in
      guard let centre else {
        throw CommandError.commandUnavailable
      }
      _ = try await centre.perform(command, during: context)
      return command.reversal(centre: centre).map {
        HistoryEntry(command: $0, action: action, centre: centre)
      }
    }
  }

  /// Identifier of the entry's command.
  public var id: String {
    command.id
  }

  /// Returns the command's current availability, including the centre's running and history state.
  ///
  /// An entry whose centre has been released is disabled.
  public func availability() -> CommandAvailability {
    currentAvailability()
  }

  /// Performs the command in the supplied history context and returns the entry that reverses it.
  ///
  /// The context is used only for this invocation. Throws `CommandError.commandUnavailable` when
  /// the centre has been released.
  func perform(in context: CommandExecutionContext) async throws -> HistoryEntry? {
    try await performer(context)
  }
}
