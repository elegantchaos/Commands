// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

/// Shared log channel for command execution diagnostics.
public let commandChannel = Channel("Commands")

/// Describes an action that a matching command centre can evaluate and perform.
///
/// Commands encapsulate availability and execution separately so callers can
/// decide whether to show, disable, or hide a command before invoking it.
@MainActor
public protocol Command<Centre> {
  /// The CommandCentre type that can perform this command.
  associatedtype Centre: CommandCentre

  /// The type of result returned when the command is performed.
  associatedtype ResultType

  /// A unique identifier for the command.
  var id: String { get }

  /// Determine whether the command is enabled, disabled, or hidden.
  func availability(centre: Centre) -> CommandAvailability

  /// Perform the command using the given CommandCentre.
  func perform(centre: Centre) async throws -> ResultType

  /// Return the inverse of this command.
  /// The inverse can be invoked to undo whatever state changes this
  /// command performs.
  func inverse(centre: Centre) -> CommandInverse?

}

/// Default implementations for `Command`.
@MainActor
extension Command {
  /// By default, commands are always enabled.
  public func availability(centre: Centre) -> CommandAvailability { .enabled }
}

/// Describes the inverse of a command.
@MainActor
public protocol CommandInverse {
  var id: String { get }
  
  /// Determine whether the inverse should be regarded as enabled, disabled, etc.
  var availability: () -> CommandAvailability { get }
  
  /// Perform the inverse command.
  /// Typically this is done by invoking another command on the same command centre
  /// that was used when the `CommandInverse` instance was created; though this
  /// is not strictly enforced.
  var perform: () async throws -> () { get }
}
