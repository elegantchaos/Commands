// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/09/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Coordinates command availability and execution for a concrete application context.
///
/// This base protocol deliberately remains independent of undo and redo.
/// Services that coordinate a command sequence use `CommandExecutionContext`;
/// `UndoableCommandCentre` defines the undo/redo policy.
@MainActor
public protocol CommandCentre {
  /// Records that a command has started executing.
  func recordStartedCommand<C: Command>(_ command: C) where C.Centre == Self

  /// Records that a command has finished executing with the supplied outcome.
  func recordFinishedCommand<C: Command>(
    _ command: C,
    outcome: CommandOutcome
  ) where C.Centre == Self

  /// Returns whether the given command is already executing.
  func isRunning<C: Command>(_ command: C) -> Bool where C.Centre == Self

  /// Returns whether a command can begin in the supplied execution context.
  ///
  /// Normal callers pass no context. A coordinating service supplies a context
  /// only for commands that belong to its active operation.
  func isAllowed(during context: CommandExecutionContext?) -> Bool
}

/// Default implementations of command-related functionality.
@MainActor
extension CommandCentre {
  /// Returns the current availability of the given command, including running state.
  public func availability<C: Command>(_ command: C) -> CommandAvailability where C.Centre == Self {
    let availability = command.availability(centre: self)
    guard isAllowed(during: nil) else {
      return availability == .hidden ? .hidden : .disabled
    }
    if isRunning(command) {
      return availability == .hidden ? .runningSilently : .running
    }
    return availability
  }

  /// Performs a command after checking its availability and execution context.
  ///
  /// Ordinary callers omit `context`. A coordinating service supplies it only
  /// while performing work that belongs to its active operation.
  public func perform<C: Command>(
    _ command: C, during context: CommandExecutionContext? = nil
  )
    async throws -> C.ResultType where C.Centre == Self
  {
    commandChannel.debug("performing command «\(command.id)»")

    // UI callers should normally gate execution through `availability`, but the
    // command centre still guards execution because availability can change
    // between rendering a control and the action firing.
    guard command.availability(centre: self) == .enabled,
      isAllowed(during: context)
    else {
      throw CommandError.commandUnavailable
    }

    recordStartedCommand(command)
    do {
      let result = try await command.perform(centre: self)
      recordFinishedCommand(command, outcome: .succeeded)
      return result
    } catch {
      recordFinishedCommand(command, outcome: .failed(error))
      throw error
    }
  }

  /// Starts the given command in an unstructured task and logs any thrown error.
  @discardableResult
  public func performWithoutWaiting<C: Command>(_ command: C) -> Task<
    Void, Never
  > where C.Centre == Self {
    commandChannel.debug("performing command «\(command.id)» without waiting")
    return Task {
      do {
        _ = try await perform(command)
      } catch {
        commandChannel.log("Error performing command \(command.id): \(error)")
      }
    }
  }

  /// Default hook for centres that do not track active commands.
  public func recordStartedCommand<C: Command>(_ command: C)
  where C.Centre == Self {
  }

  /// Default hook for centres that do not track completed commands or their outcomes.
  public func recordFinishedCommand<C: Command>(
    _ command: C,
    outcome: CommandOutcome
  ) where C.Centre == Self {
  }

  /// Returns whether the given command is already executing.
  public func isRunning<C: Command>(_ command: C) -> Bool where C.Centre == Self {
    false
  }

  /// By default, command execution is allowed in every execution context.
  public func isAllowed(during context: CommandExecutionContext?) -> Bool {
    true
  }
}
