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
  /// `menuForCommand(_:centre:identifier:)` while building iOS or Mac Catalyst menus.
  /// Each generated menu command carries its command identifier, so dispatch does not
  /// depend on a concrete command-centre type or the presence of an icon.
  @MainActor
  open class CommandCentreDelegate: UIResponder, UIApplicationDelegate {
    /// Type-erased invocations indexed by their command identifiers.
    ///
    /// Stable identifiers keep this registry bounded because rebuilding a command
    /// replaces its existing invocation. Dynamically generated unique identifiers
    /// would retain invocations for the lifetime of the delegate and should be avoided.
    private var invocations: [String: CommandInvocation] = [:]

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
      let invocation = CommandInvocation {
        centre.performWithoutWaiting(command, from: .menu)
      }
      invocations[command.id] = invocation
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
          propertyList: command.id,
          discoverabilityTitle: command.help(centre: centre),
          attributes: attributes
        )
      }

      return UICommand(
        title: command.name(centre: centre),
        image: image,
        action: selector,
        propertyList: command.id,
        discoverabilityTitle: command.help(centre: centre),
        attributes: attributes
      )
    }

    /// Performs the invocation carried by a generated UIKit command.
    ///
    /// This internal entry point also provides deterministic package-level testing
    /// without requiring UIKit to route an Objective-C responder-chain action.
    @discardableResult
    func performCommand(_ command: UICommand) -> Task<Void, Never>? {
      guard
        let commandID = command.propertyList as? String,
        let invocation = invocations[commandID]
      else {
        return nil
      }
      return invocation.perform()
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
    /// Action that starts command execution.
    let perform: @MainActor () -> Task<Void, Never>

    /// Creates an invocation around a command-centre action.
    init(perform: @escaping @MainActor () -> Task<Void, Never>) {
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
