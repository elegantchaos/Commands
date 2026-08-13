// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/09/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftUI

/// Errors thrown by the default command-centre execution helpers.
public enum CommandError: Error, Equatable {
  /// The command reported that it cannot currently be performed.
  case commandUnavailable
}

/// Coordinates command availability and execution for a concrete application context.
@MainActor
public protocol CommandCentre {
  /// Records that a command has started executing.
  func recordStartedCommand<C: Command>(_ command: C, from: CommandSource) where C.Centre == Self

  /// Records that a command has finished executing.
  func recordFinishedCommand<C: Command>(_ command: C, from: CommandSource) where C.Centre == Self

  /// Returns whether the given command is already executing.
  func isRunning<C: Command>(_ command: C) -> Bool where C.Centre == Self
}

/// Default implementations of command-related functionality.
@MainActor
extension CommandCentre {
  /// Returns the current availability of the given command, including running state.
  public func availability<C: Command>(_ command: C) -> CommandAvailability where C.Centre == Self {
    let availability = command.availability(centre: self)
    if isRunning(command) {
      return availability == .hidden ? .runningSilently : .running
    }
    return availability
  }

  /// Performs the given command after checking that it is currently enabled.
  public func perform<C: Command>(_ command: C, from source: CommandSource) async throws
    -> C.ResultType where C.Centre == Self
  {
    commandChannel.debug("performing command «\(command.id)» from \(source)")

    // UI callers should normally gate execution through `availability`, but the
    // command centre still guards execution because availability can change
    // between rendering a control and the action firing.
    guard command.availability(centre: self) == .enabled else {
      throw CommandError.commandUnavailable
    }

    recordStartedCommand(command, from: source)
    defer {
      recordFinishedCommand(command, from: source)
    }

    return try await command.perform(centre: self, from: source)
  }

  /// Starts the given command in a child task and logs any thrown error.
  @discardableResult
  public func performWithoutWaiting<C: Command>(_ command: C, from source: CommandSource) -> Task<
    Void, Never
  > where C.Centre == Self {
    commandChannel.debug("performing command «\(command.id)» from \(source) without waiting")
    return Task {
      do {
        _ = try await perform(command, from: source)
      } catch {
        commandChannel.log("Error performing command \(command.id): \(error)")
      }
    }
  }

  /// Default hook for centres that do not track active commands.
  public func recordStartedCommand<C: Command>(_ command: C, from source: CommandSource)
  where C.Centre == Self {
  }

  /// Default hook for centres that do not track completed commands.
  public func recordFinishedCommand<C: Command>(_ command: C, from source: CommandSource)
  where C.Centre == Self {
  }

  /// Returns whether the given command is already executing.
  public func isRunning<C: Command>(_ command: C) -> Bool where C.Centre == Self {
    false
  }
}
