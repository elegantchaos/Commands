// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/07/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(UIKit) && !os(watchOS)
  import Commands
  import Foundation
  import Icons
  import SwiftUI
  import UIKit

  /// Application delegate base class that adapts commands for UIKit menu systems.
  ///
  /// Subclass this type from an application's `UIApplicationDelegate` and use
  /// `menuForCommand(_:centre:identifier:)` or `uiCommand(_:centre:)` while building iOS or Mac
  /// Catalyst menus in `buildMenu(with:)`. Each generated menu item carries its own invocation
  /// token, so two items for the same command identifier, such as a per-item command built for
  /// several items, each run their own command.
  ///
  /// A command that declares a confirmation asks for it through `confirm(_:perform:)` before it
  /// runs, as a SwiftUI command button does.
  @MainActor
  open class CommandCentreDelegate: UIResponder, UIApplicationDelegate {
    /// The presenter that asks for confirmation, such as the one a `CommandsHost` publishes for
    /// the focused window. When it is nil, `confirm(_:perform:)` shows an alert on the key window.
    public weak var commandPresenter: CommandPresenter?

    /// Invocations for generated menu items, by invocation token, with the menu generation they
    /// were made in.
    private var invocations: [String: (generation: Int, invocation: CommandInvocation)] = [:]

    /// The current main-menu generation, advanced each time UIKit rebuilds the menus.
    private var generation = 0

    /// Source of unique invocation tokens.
    private var nextToken = 0

    /// Rebuilds the main menu, discarding invocations of menu items that UIKit has replaced.
    ///
    /// Subclasses that build command menus override this and may call `super` before or after
    /// adding their items.
    open override func buildMenu(with builder: any UIMenuBuilder) {
      menusWillRebuild()
      super.buildMenu(with: builder)
    }

    /// Creates an inline UIKit menu containing a generated command.
    public func menuForCommand<C: CommandWithUI>(
      _ command: C,
      centre: C.Centre,
      identifier: UIMenu.Identifier? = nil
    ) -> UIMenu {
      UIMenu(
        title: "",
        identifier: identifier,
        options: .displayInline,
        children: [uiCommand(command, centre: centre)]
      )
    }

    /// Creates a UIKit command that forwards metadata and execution to a command centre.
    public func uiCommand<C: CommandWithUI>(_ command: C, centre: C.Centre) -> UICommand {
      let token = register(command, centre: centre)
      let selector = #selector(handleCommand(_:))
      let attributes = attributes(for: command, centre: centre)
      let image = UIImage(icon: command.icon(centre: centre))

      if let shortcut = command.shortcut {
        return UIKeyCommand(
          title: command.name(centre: centre),
          image: image,
          action: selector,
          input: String(shortcut.key.character),
          modifierFlags: shortcut.modifiers.uiKeyModifierFlags,
          propertyList: token,
          discoverabilityTitle: command.help(centre: centre),
          attributes: attributes
        )
      }

      return UICommand(
        title: command.name(centre: centre),
        image: image,
        action: selector,
        propertyList: token,
        discoverabilityTitle: command.help(centre: centre),
        attributes: attributes
      )
    }

    /// Asks the user to confirm a command, running `perform` only if they accept.
    ///
    /// By default this uses `commandPresenter` when one is set, and otherwise shows an alert on
    /// the key window's frontmost view controller. When there is nowhere to ask, the command does
    /// not run. Override it to confirm some other way.
    open func confirm(
      _ confirmation: CommandConfirmation, perform: @escaping @MainActor () -> Void
    ) {
      if let commandPresenter {
        commandPresenter.confirm(confirmation, perform: perform)
        return
      }

      guard let presenting = frontmostViewController() else {
        commandChannel.log(
          "No window to confirm \"\(confirmation.title)\", so it was not performed")
        return
      }
      let alert = UIAlertController(
        title: confirmation.title, message: confirmation.message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: confirmation.cancel, style: .cancel))
      alert.addAction(
        UIAlertAction(title: confirmation.confirm, style: .destructive) { _ in perform() })
      presenting.present(alert, animated: true)
    }

    /// Performs the invocation carried by a generated UIKit command.
    ///
    /// Returns the task running the command, or nil when the item is no longer current or the
    /// command is waiting for confirmation. This internal entry point also provides deterministic
    /// package-level testing without requiring UIKit to route a responder-chain action.
    @discardableResult
    func performCommand(_ command: UICommand) -> Task<Void, Never>? {
      guard
        let token = command.propertyList as? String,
        let entry = invocations[token]
      else {
        return nil
      }
      return entry.invocation.perform()
    }

    /// Advances the menu generation and discards invocations older than the previous one.
    ///
    /// Items from the generation before stay valid, because a subclass may build its items before
    /// calling `super.buildMenu(with:)`, which advances the generation.
    func menusWillRebuild() {
      generation += 1
      invocations = invocations.filter { $0.value.generation >= generation - 1 }
    }

    /// Records an invocation for `command`, returning the token that identifies it.
    private func register<C: CommandWithUI>(_ command: C, centre: C.Centre) -> String {
      nextToken += 1
      let token = "\(command.id)#\(nextToken)"
      let invocation = CommandInvocation { [weak self] in
        guard let confirmation = command.confirmation(centre: centre) else {
          return centre.performWithoutWaiting(command)
        }
        self?.confirm(confirmation) { centre.performWithoutWaiting(command) }
        return nil
      }
      invocations[token] = (generation, invocation)
      return token
    }

    /// The view controller to present a confirmation from: the frontmost one in the key window.
    private func frontmostViewController() -> UIViewController? {
      let windows = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows)
      var controller = (windows.first(where: \.isKeyWindow) ?? windows.first)?.rootViewController
      while let presented = controller?.presentedViewController {
        controller = presented
      }
      return controller
    }

    /// Handles UIKit responder-chain actions for generated commands.
    @objc private func handleCommand(_ command: UICommand) {
      performCommand(command)
    }

    /// Maps command availability onto UIKit menu attributes.
    private func attributes<C: Command>(for command: C, centre: C.Centre)
      -> UIMenuElement.Attributes
    {
      switch centre.availability(command) {
      case .enabled:
        []
      case .disabled, .running, .runningSilently:
        .disabled
      case .hidden:
        .hidden
      }
    }
  }

  /// Type-erased invocation retained by the command-centre delegate.
  @MainActor
  private final class CommandInvocation {
    /// Action that starts command execution, returning its task, or nil while it awaits confirmation.
    let perform: @MainActor () -> Task<Void, Never>?

    /// Creates an invocation around a command-centre action.
    init(perform: @escaping @MainActor () -> Task<Void, Never>?) {
      self.perform = perform
    }
  }

  /// UIKit conversion for SwiftUI keyboard-shortcut modifiers.
  extension EventModifiers {
    /// Equivalent UIKit key-command flags.
    fileprivate var uiKeyModifierFlags: UIKeyModifierFlags {
      var result: UIKeyModifierFlags = []
      if contains(.shift) {
        result.insert(.shift)
      }
      if contains(.command) {
        result.insert(.command)
      }
      if contains(.control) {
        result.insert(.control)
      }
      if contains(.option) {
        result.insert(.alternate)
      }
      return result
    }
  }
#endif
