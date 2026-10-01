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
/// - injects the app's commander into the environment, so views can build command controls;
/// - presents the alerts that command buttons request, wherever those buttons are, including in
///   menus and the macOS menu bar;
/// - publishes its presenter to the focused scene, so menu-bar commands reach the key window.
///
/// ```swift
/// WindowGroup {
///   CommandsHost(commander: engine.commander) {
///     RootView()
///   }
/// }
/// ```
public struct CommandsHost<Commander: AnyObject & Observable, Content: View>: View {
  /// The commander injected into the environment, or nil to inherit the enclosing one.
  private let commander: Commander?

  /// The window or sheet content.
  private let content: Content

  /// The requests made of this host.
  @State private var presenter = CommandPresenter()

  /// Creates a host that injects `commander` into its content.
  public init(commander: Commander, @ViewBuilder content: () -> Content) {
    self.commander = commander
    self.content = content()
  }

  /// The host's content, with its presentation surface attached.
  public var body: some View {
    content
      .environment(commander)
      .environment(\.commandPresenter, presenter)
      .focusedSceneValue(\.commandPresenter, presenter)
      .alert(
        presenter.pendingConfirmation?.confirmation.title ?? "",
        isPresented: isPresentingConfirmation,
        presenting: presenter.pendingConfirmation
      ) { pending in
        Button(pending.confirmation.cancel, role: .cancel) { presenter.cancel() }
        Button(pending.confirmation.confirm, role: .destructive) { presenter.accept() }
      } message: { pending in
        Text(pending.confirmation.message)
      }
  }

  /// Whether a confirmation is waiting; dismissing the alert cancels the request.
  private var isPresentingConfirmation: Binding<Bool> {
    Binding {
      presenter.pendingConfirmation != nil
    } set: { isPresented in
      if !isPresented { presenter.cancel() }
    }
  }
}

/// A commander type for hosts that inherit the enclosing host's commander.
@MainActor
@Observable
public final class InheritedCommander {
  private init() {}
}

extension CommandsHost where Commander == InheritedCommander {
  /// Creates a host that keeps the enclosing commander, for use inside sheets.
  public init(@ViewBuilder content: () -> Content) {
    self.commander = nil
    self.content = content()
  }
}
