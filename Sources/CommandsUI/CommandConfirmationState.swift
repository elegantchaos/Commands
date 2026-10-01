// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// The state a command button needs to confirm before it performs its command.
///
/// Create one as a property of the button, call `request(_:mode:perform:)` from its action, and
/// attach `commandLocalConfirmation(_:)` to the button to show the local dialog.
@MainActor
struct CommandConfirmationState: DynamicProperty {
  /// A local confirmation waiting for the user's answer.
  struct LocalRequest: Identifiable {
    let id = UUID()
    let confirmation: CommandConfirmation
    let perform: @MainActor () -> Void
  }

  /// The presenter of the enclosing window's host.
  @Environment(\.commandPresenter) private var environmentPresenter

  /// The presenter of the focused window's host, for menu-bar commands.
  @FocusedValue(\.commandPresenter) private var focusedPresenter

  /// The mode that the environment asks for.
  @Environment(\.commandConfirmationMode) private var environmentMode

  /// The local confirmation currently shown, if any.
  @State private var localRequest: LocalRequest?

  /// A binding to the local confirmation, for the dialog attached to the button.
  fileprivate var localRequestBinding: Binding<LocalRequest?> { $localRequest }

  /// Performs a command, first confirming if its `confirmation` is non-nil and the mode asks for it.
  ///
  /// - Parameters:
  ///   - confirmation: What the command declares, or nil if it needs no confirmation.
  ///   - mode: The mode requested at the call site, or nil to use the environment's.
  ///   - perform: Runs the command.
  func request(
    _ confirmation: CommandConfirmation?,
    mode: CommandConfirmationMode?,
    perform: @escaping @MainActor () -> Void
  ) {
    let presenter = environmentPresenter ?? focusedPresenter
    let outcome = CommandConfirmationMode.outcome(
      requested: mode, environment: environmentMode,
      declaresConfirmation: confirmation != nil, hasHost: presenter != nil)

    switch (outcome, confirmation) {
    case (.confirmWithHost, let confirmation?):
      presenter?.confirm(confirmation, perform: perform)

    case (.confirmLocally, let confirmation?):
      if (mode ?? environmentMode) == .hosted {
        commandChannel.debug("no CommandsHost, so a hosted confirmation is shown locally")
      }
      localRequest = LocalRequest(confirmation: confirmation, perform: perform)

    default:
      perform()
    }
  }
}

extension View {
  /// Shows the local confirmation that a `CommandConfirmationState` requests, anchored to this view.
  func commandLocalConfirmation(_ state: CommandConfirmationState) -> some View {
    modifier(LocalConfirmationModifier(request: state.localRequestBinding))
  }
}

/// Attaches the dialog for a button's local confirmation.
private struct LocalConfirmationModifier: ViewModifier {
  @Binding var request: CommandConfirmationState.LocalRequest?

  func body(content: Content) -> some View {
    content.confirmationDialog(
      request?.confirmation.title ?? "",
      isPresented: isPresented,
      titleVisibility: .visible,
      presenting: request
    ) { pending in
      Button(pending.confirmation.confirm, role: .destructive) {
        request = nil
        pending.perform()
      }
      Button(pending.confirmation.cancel, role: .cancel) {
        request = nil
      }
    } message: { pending in
      Text(pending.confirmation.message)
    }
  }

  /// Whether a request is pending; dismissing the dialog cancels it.
  private var isPresented: Binding<Bool> {
    Binding {
      request != nil
    } set: { isPresented in
      if !isPresented { request = nil }
    }
  }
}
