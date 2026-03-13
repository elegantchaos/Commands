// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/09/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftUI

/// Errors thrown by the default command-centre execution helpers.
public enum CommandError: Error {
  /// The command reported that it cannot currently be performed.
  case commandUnavaiable
}

/// Coordinates command availability and execution for a concrete application context.
@MainActor
public protocol CommandCentre {
  /// Records that a command has started executing.
  func recordStartedCommand<C: Command>(_ command: C) where C.Centre == Self

  /// Records that a command has finished executing.
  func recordFinishedCommand<C: Command>(_ command: C) where C.Centre == Self
}


/// Default implementations of command-related functionality.
@MainActor
public extension CommandCentre {
  /// Returns the current availability of the given command, including running state.
  func availability<C: Command>(_ command: C) -> CommandAvailability where C.Centre == Self {
    let availability = command.availability(centre: self)
    if isRunning(command) {
      return availability == .hidden ? .runningSilently : .running
    }
    return availability
  }

  /// Performs the given command after checking that it is currently enabled.
  func perform<C: Command>(_ command: C) async throws -> C.ResultType where C.Centre == Self {
    commandChannel.debug("performing command «\(command.id)»")

    // UI callers should normally gate execution through `availability`, but the
    // command centre still guards execution because availability can change
    // between rendering a control and the action firing.
    guard command.availability(centre: self) == .enabled else {
      throw CommandError.commandUnavaiable
    }

    recordStartedCommand(command)
    defer {
      recordFinishedCommand(command)
    }

    return try await command.perform(centre: self)
  }

  /// Starts the given command in a child task and logs any thrown error.
  func performWithoutWaiting<C: Command>(_ command: C) where C.Centre == Self {
    commandChannel.debug("performing command «\(command.id)»")
    Task {
      do {
        _ = try await perform(command)
      } catch {
        commandChannel.log("Error performing command \(command.id): \(error)")
      }
    }
  }

  /// Default hook for centres that do not track active commands.
  func recordStartedCommand<C: Command>(_ command: C) where C.Centre == Self {
  }

  /// Default hook for centres that do not track completed commands.
  func recordFinishedCommand<C: Command>(_ command: C) where C.Centre == Self {
  }

  /// Returns whether the given command is already executing.
  func isRunning<C: Command>(_ command: C) -> Bool where C.Centre == Self {
    false
  }
}
