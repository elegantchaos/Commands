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

  /// Performs the command using the given command centre.
  func perform(centre: Centre) async throws -> ResultType

  /// Returns the operation that reverses this command.
  func reversal(centre: Centre) -> (any CommandReversal)?

}

/// Default implementations for `Command`.
@MainActor
extension Command {
  /// By default, commands are always enabled.
  public func availability(centre: Centre) -> CommandAvailability { .enabled }

  /// By default, a command does not provide a reversal.
  public func reversal(centre: Centre) -> (any CommandReversal)? { nil }
}
