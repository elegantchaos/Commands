// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Where a command button presents the confirmation its command declares.
///
/// A command opts into confirmation by returning one from `confirmation(centre:)`. This says how
/// the button then shows it: next to the button, from a `CommandsHost`, or not at all.
public enum CommandConfirmationMode: Sendable {
  /// Run the command without confirming.
  ///
  /// This is not called `none` because the call-site parameter is optional, where `.none` would
  /// mean `Optional.none`, "not specified".
  case never

  /// Present a dialog attached to the button, which the system anchors to it where it can.
  ///
  /// This is the default. It does not work inside a menu, which discards the button when it
  /// closes; use `.hosted` there.
  case local

  /// Ask the enclosing `CommandsHost` to present an alert.
  ///
  /// Use this for buttons in menus, including the macOS menu bar. Without a host this falls back
  /// to `.local`.
  case hosted
}

/// What pressing a command button should do.
enum CommandConfirmationOutcome: Equatable {
  /// Run the command now.
  case perform

  /// Show a dialog attached to the button, and run the command if the user accepts.
  case confirmLocally

  /// Ask the host to confirm, and run the command if the user accepts.
  case confirmWithHost
}

extension CommandConfirmationMode {
  /// Decides what a button does, from the mode its call site asked for, the one in its
  /// environment, and whether its command declares a confirmation.
  ///
  /// A mode passed at the call site wins over the environment.
  static func outcome(
    requested: CommandConfirmationMode?,
    environment: CommandConfirmationMode,
    declaresConfirmation: Bool,
    hasHost: Bool
  ) -> CommandConfirmationOutcome {
    guard declaresConfirmation else { return .perform }

    switch requested ?? environment {
    case .never: return .perform
    case .local: return .confirmLocally
    case .hosted: return hasHost ? .confirmWithHost : .confirmLocally
    }
  }
}

extension EnvironmentValues {
  /// How command buttons in this part of the hierarchy present their confirmations.
  @Entry public var commandConfirmationMode: CommandConfirmationMode = .local
}

extension View {
  /// Sets how command buttons inside this view present the confirmations their commands declare.
  ///
  /// Apply `.hosted` to the content of a menu.
  public func commandConfirmation(_ mode: CommandConfirmationMode) -> some View {
    environment(\.commandConfirmationMode, mode)
  }

  /// Runs the commands of buttons inside this view without confirming.
  public func withoutConfirmation() -> some View {
    commandConfirmation(.never)
  }
}
