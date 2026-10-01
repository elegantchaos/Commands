// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation
import SwiftUI

/// Holds the user-facing requests that command buttons make of the view hierarchy.
///
/// A button inside a menu cannot present its own alert, because the menu discards the button when
/// it closes, and a macOS `CommandMenu` has no view at all. Buttons therefore ask a presenter to
/// show the alert, and a `CommandsHost` at the root of a window renders it.
@MainActor
@Observable
public final class CommandPresenter {
  /// A confirmation waiting for the user's answer.
  public struct PendingConfirmation: Identifiable {
    /// Identifies the request, so a replaced request is seen as new.
    public let id = UUID()

    /// The dialog to show.
    public let confirmation: CommandConfirmation

    /// The action to run if the user confirms.
    fileprivate let perform: @MainActor () -> Void
  }

  /// The confirmation currently shown to the user, if any.
  public private(set) var pendingConfirmation: PendingConfirmation?

  /// Creates a presenter with nothing pending.
  public init() {}

  /// Asks the user to confirm, then runs `perform`.
  ///
  /// The action runs only if the user accepts. A request made while another is pending replaces it.
  public func confirm(
    _ confirmation: CommandConfirmation, perform: @escaping @MainActor () -> Void
  ) {
    pendingConfirmation = PendingConfirmation(confirmation: confirmation, perform: perform)
  }

  /// Runs the pending action and clears the request.
  public func accept() {
    guard let pending = pendingConfirmation else { return }
    pendingConfirmation = nil
    pending.perform()
  }

  /// Clears the pending request without running its action.
  public func cancel() {
    pendingConfirmation = nil
  }
}

extension EnvironmentValues {
  /// The presenter of the nearest enclosing `CommandsHost`.
  @Entry public var commandPresenter: CommandPresenter?
}

extension FocusedValues {
  /// The presenter of the focused window's `CommandsHost`, for menus that have no view hierarchy.
  @Entry public var commandPresenter: CommandPresenter?
}
