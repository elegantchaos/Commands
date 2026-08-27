// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
import Logger
import SwiftUI

/// Installs the UndoManager-proxy experiment around an example view hierarchy.
///
/// The modifier observes Commands history and mirrors its current direction into
/// the manager supplied by SwiftUI. It is enabled only for the proxy prototype;
/// the other experiments leave SwiftUI's environment manager untouched.
struct UndoManagerProxyPrototype: ViewModifier {
  /// The Commands history mirrored by native proxy registrations.
  let undoService: UndoService

  /// Whether this app run selected the proxy experiment.
  let isEnabled: Bool

  /// The manager supplied by SwiftUI for this view hierarchy.
  @Environment(\.undoManager) private var undoManager

  /// The bridge retained for the lifetime of this modifier.
  @State private var bridge: CommandsUndoManagerProxy

  /// Creates a modifier for one Commands history.
  init(undoService: UndoService, isEnabled: Bool) {
    self.undoService = undoService
    self.isEnabled = isEnabled
    _bridge = State(initialValue: CommandsUndoManagerProxy(undoService: undoService))
  }

  /// Reconciles the native registration whenever Commands history changes.
  func body(content: Content) -> some View {
    let historyDescription = undoService.stackDescription
    let isPerforming = undoService.isUndoing || undoService.isRedoing
    let managerID = undoManager.map(ObjectIdentifier.init)

    content
      .onAppear {
        bridge.configure(undoManager: isEnabled ? undoManager : nil)
      }
      .onChange(of: managerID) {
        bridge.configure(undoManager: isEnabled ? undoManager : nil)
      }
      .onChange(of: historyDescription, initial: true) {
        bridge.synchronize()
      }
      .onChange(of: isPerforming) {
        bridge.synchronize()
      }
  }
}

extension View {
  /// Applies the optional UndoManager-proxy experiment to this view hierarchy.
  func undoManagerProxyPrototype(undoService: UndoService, isEnabled: Bool) -> some View {
    modifier(UndoManagerProxyPrototype(undoService: undoService, isEnabled: isEnabled))
  }
}

/// Mirrors the current Commands undo direction into SwiftUI's native manager.
///
/// A registered proxy changes the native manager's direction synchronously, then
/// starts the corresponding Commands reversal. The `UndoService` remains the
/// authority for command history and reports failure by retaining its cursor.
@MainActor
final class CommandsUndoManagerProxy {
  /// The Commands history invoked by native proxy actions.
  private let undoService: UndoService

  /// The manager supplied by the current SwiftUI hierarchy.
  private weak var undoManager: UndoManager?

  /// The proxy action currently mirrored into the native manager.
  private var registeredDirection: Direction?

  /// Creates a bridge for one Commands history.
  init(undoService: UndoService) {
    self.undoService = undoService
  }

  /// Associates the bridge with a manager, removing only this bridge's actions
  /// from any manager it previously owned.
  func configure(undoManager: UndoManager?) {
    guard self.undoManager !== undoManager else {
      synchronize()
      return
    }

    self.undoManager?.removeAllActions(withTarget: self)
    self.undoManager = undoManager
    registeredDirection = nil
    synchronize()
  }

  /// Rebuilds this bridge's native action when Commands history changes direction.
  func synchronize() {
    guard undoService.isUndoing == false, undoService.isRedoing == false else {
      return
    }

    let direction = desiredDirection
    guard direction != registeredDirection else {
      return
    }

    undoManager?.removeAllActions(withTarget: self)
    registeredDirection = direction

    switch direction {
    case .undo:
      registerUndoProxy()
    case .redo:
      registerRedoProxy()
    case nil:
      break
    }
  }

  /// The native direction matching Commands history while no action is active.
  private var desiredDirection: Direction? {
    if undoService.hasUndo {
      return .undo
    }

    if undoService.hasRedo {
      return .redo
    }

    return nil
  }

  /// Registers a native action that begins Commands undo.
  private func registerUndoProxy() {
    undoManager?.registerUndo(withTarget: self) { proxy in
      proxy.performUndo()
    }
  }

  /// Registers a native action that begins Commands redo.
  private func registerRedoProxy() {
    undoManager?.registerUndo(withTarget: self) { proxy in
      proxy.performRedo()
    }
  }

  /// Handles a native undo invocation after its manager has moved the proxy.
  private func performUndo() {
    guard undoService.isUndoing == false, undoService.isRedoing == false else {
      synchronize()
      return
    }

    registeredDirection = .redo
    registerRedoProxy()
    perform { try await self.undoService.performUndo() }
  }

  /// Handles a native redo invocation after its manager has moved the proxy.
  private func performRedo() {
    guard undoService.isUndoing == false, undoService.isRedoing == false else {
      synchronize()
      return
    }

    registeredDirection = .undo
    registerUndoProxy()
    perform { try await self.undoService.performRedo() }
  }

  /// Starts a Commands operation and reconciles native registration on completion.
  private func perform(_ operation: @escaping @MainActor () async throws -> Void) {
    Task { @MainActor [weak self] in
      do {
        try await operation()
      } catch {
        commandChannel.log("Error performing UndoManager proxy action: \(error)")
      }

      self?.synchronize()
    }
  }

  /// The action represented by the native manager's next proxy registration.
  private enum Direction: Equatable {
    /// The proxy starts Commands undo.
    case undo

    /// The proxy starts Commands redo.
    case redo
  }
}
