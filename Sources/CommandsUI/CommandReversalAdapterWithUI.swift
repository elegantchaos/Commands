// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons

/// Adapts a UI-capable command and its centre into a presentable reversal.
@MainActor
public struct CommandReversalAdapterWithUI<C: CommandWithUI>: CommandReversalWithUI {
  /// Core reversal behavior for the wrapped command.
  private let reversal: CommandReversalAdapter<C>

  /// UI-capable command whose metadata is presented.
  private let command: C

  /// Command centre used to resolve dynamic metadata.
  private let centre: C.Centre

  /// The original action represented by this entry in undo history.
  private let actionName: String

  /// Creates a reversal that forwards execution and UI metadata from a command.
  ///
  /// - Parameter historyActionName: The name shown in Undo and Redo labels for
  ///   the action being reversed. When omitted, the reversal command's name is
  ///   used for compatibility with existing adapters.
  public init(command: C, centre: C.Centre, historyActionName: String? = nil) {
    reversal = CommandReversalAdapter(command: command, centre: centre)
    self.command = command
    self.centre = centre
    actionName = historyActionName ?? command.name(centre: centre)
  }

  /// Stable identifier forwarded from the wrapped command.
  public var id: String {
    reversal.id
  }

  /// Returns the wrapped command's current availability.
  public func availability() -> CommandAvailability {
    reversal.availability()
  }

  /// Performs the wrapped command and returns its opposing reversal.
  public func perform(in context: CommandExecutionContext) async throws -> (any CommandReversal)? {
    try await reversal.perform(in: context)
  }

  /// Returns the command's current display name.
  public func name() -> String {
    command.name(centre: centre)
  }

  /// Returns the original action's display name for an Undo or Redo label.
  public func historyActionName() -> String {
    actionName
  }

  /// Returns the command's current icon.
  public func icon() -> Icon {
    command.icon(centre: centre)
  }

  /// Returns the command's current help text.
  public func help() -> String? {
    command.help(centre: centre)
  }
}
