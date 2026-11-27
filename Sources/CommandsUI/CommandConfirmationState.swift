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
    /// Identifies the request, so the dialog's actions apply only to the request it shows.
    let id = UUID()

    /// The dialog to show.
    let confirmation: CommandConfirmation

    /// The action to run if the user confirms.
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
      guard localRequest == nil else {
        commandChannel.log("Refused confirmation \"\(confirmation.title)\" while another is shown")
        return
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
  /// The button's pending local confirmation.
  @Binding var request: CommandConfirmationState.LocalRequest?

  /// Attaches the dialog for the request shown when the body is evaluated.
  func body(content: Content) -> some View {
    let shown = request
    return content.confirmationDialog(
      shown?.confirmation.title ?? "",
      isPresented: isPresenting(shown),
      titleVisibility: .visible,
      presenting: shown
    ) { pending in
      Button(pending.confirmation.confirm, role: .destructive) {
        guard request?.id == pending.id else { return }
        request = nil
        pending.perform()
      }
      Button(pending.confirmation.cancel, role: .cancel) {
        if request?.id == pending.id { request = nil }
      }
    } message: { pending in
      Text(pending.confirmation.message)
    }
  }

  /// Whether `shown` is pending; dismissing the dialog cancels that request, and no other.
  private func isPresenting(_ shown: CommandConfirmationState.LocalRequest?) -> Binding<Bool> {
    Binding {
      shown != nil
    } set: { isPresented in
      if !isPresented, request?.id == shown?.id { request = nil }
    }
  }
}
