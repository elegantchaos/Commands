// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation
import SwiftUI

/// The root of the view hierarchy for command-driven UI.
///
/// Place one host at the root of each window, and another inside any sheet that contains command
/// buttons, since an alert cannot present from a view that a sheet covers. The host:
///
/// - injects the app's command centre into the environment, so views can build command controls;
/// - presents the alerts that command buttons request, wherever those buttons are, including in
///   menus and the macOS menu bar;
/// - publishes its presenter to the focused scene, so menu-bar commands reach the key window.
///
/// ```swift
/// WindowGroup {
///   CommandsHost(centre: engine.centre) {
///     RootView()
///   }
/// }
/// ```
public struct CommandsHost<Centre: AnyObject & Observable, Content: View>: View {
  /// The command centre injected into the environment, or nil to inherit the enclosing one.
  private let centre: Centre?

  /// The window or sheet content.
  private let content: Content

  /// The requests made of this host.
  @State private var presenter = CommandPresenter()

  /// Creates a host that injects `centre` into its content.
  public init(centre: Centre, @ViewBuilder content: () -> Content) {
    self.centre = centre
    self.content = content()
  }

  /// The host's content, with its presentation surface attached.
  public var body: some View {
    let shown = presenter.pendingConfirmation
    content
      .environment(centre)
      .environment(\.commandPresenter, presenter)
      .focusedSceneValue(\.commandPresenter, presenter)
      .alert(
        shown?.confirmation.title ?? "",
        isPresented: isPresenting(shown),
        presenting: shown
      ) { pending in
        Button(pending.confirmation.cancel, role: .cancel) { presenter.cancel(pending) }
        Button(pending.confirmation.confirm, role: .destructive) { presenter.accept(pending) }
      } message: { pending in
        Text(pending.confirmation.message)
      }
  }

  /// Whether `shown` is waiting; dismissing the alert cancels that request, and no other.
  ///
  /// SwiftUI ignores changes to the presented data once the alert is up, so every action is tied
  /// to the request the alert was built from.
  private func isPresenting(_ shown: CommandPresenter.PendingConfirmation?) -> Binding<Bool> {
    Binding {
      shown != nil
    } set: { isPresented in
      if !isPresented, let shown { presenter.cancel(shown) }
    }
  }
}

/// A placeholder centre type for hosts that inherit the enclosing host's command centre.
@MainActor
@Observable
public final class InheritedCentre {
  private init() {}
}

extension CommandsHost where Centre == InheritedCentre {
  /// Creates a host that keeps the enclosing command centre, for use inside sheets.
  public init(@ViewBuilder content: () -> Content) {
    self.centre = nil
    self.content = content()
  }
}
