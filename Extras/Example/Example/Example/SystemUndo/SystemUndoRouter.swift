// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Foundation
import Logger
import Observation
import SwiftUI

#if os(macOS)
  import AppKit
#elseif canImport(UIKit)
  import UIKit
#endif

/// Routes a system Undo or Redo invocation to the focused native editor or Commands.
///
/// The router deliberately gives a focused text editor ownership even when its
/// native manager has no action. This prevents application state from changing
/// while a person is editing text.
@MainActor
@Observable
final class SystemUndoRouter: NSObject {
  /// The Commands history used when no native text editor owns the action.
  private var undoService: UndoService?

  /// Whether platform notifications already invalidate the command presentation.
  private var isObservingNativeUndoChanges = false

  /// Changes whenever the system Undo and Redo menu needs revalidation.
  private var validationRevision = 0

  /// Configures the history used by this example app run.
  func configure(undoService: UndoService) {
    self.undoService = undoService
    observeNativeUndoChanges()
    refreshMenuState()
  }

  /// Whether the currently selected owner can undo.
  var canUndo: Bool {
    _ = validationRevision

    return switch owner {
    case .native(let manager):
      manager.canUndo
    case .commands(let service):
      service.hasUndo && service.isUndoing == false && service.isRedoing == false
    case nil:
      false
    }
  }

  /// Whether the currently selected owner can redo.
  var canRedo: Bool {
    _ = validationRevision

    return switch owner {
    case .native(let manager):
      manager.canRedo
    case .commands(let service):
      service.hasRedo && service.isUndoing == false && service.isRedoing == false
    case nil:
      false
    }
  }

  /// The title of the next undo action for the current owner.
  var undoTitle: String {
    actionTitle(for: .undo)
  }

  /// The title of the next redo action for the current owner.
  var redoTitle: String {
    actionTitle(for: .redo)
  }

  /// Starts the selected undo operation.
  func undo() {
    switch owner {
    case .native(let manager):
      manager.undo()
    case .commands(let service):
      perform { try await service.performUndo() }
    case nil:
      break
    }
  }

  /// Starts the selected redo operation.
  func redo() {
    switch owner {
    case .native(let manager):
      manager.redo()
    case .commands(let service):
      perform { try await service.performRedo() }
    case nil:
      break
    }
  }

  /// Resolves ownership each time an action is queried or invoked.
  private var owner: Owner? {
    if let manager = nativeTextUndoManager {
      return .native(manager)
    }

    if let undoService {
      return .commands(undoService)
    }

    return nil
  }

  /// Starts an asynchronous Commands operation from a synchronous menu action.
  private func perform(_ operation: @escaping @MainActor () async throws -> Void) {
    Task {
      do {
        try await operation()
      } catch {
        commandChannel.log("Error performing system undo action: \(error)")
      }
    }
  }

  /// Begins observing platform notifications that can change native Undo state.
  private func observeNativeUndoChanges() {
    guard isObservingNativeUndoChanges == false else {
      return
    }

    for notification in nativeUndoChangeNotifications {
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(refreshMenuStateAfterNativeChange),
        name: notification,
        object: nil
      )
    }

    isObservingNativeUndoChanges = true
  }

  /// Invalidates the SwiftUI commands that display the current native state.
  private func refreshMenuState() {
    validationRevision &+= 1
  }

  /// Revalidates SwiftUI commands after native text editing or Undo changes.
  @objc private func refreshMenuStateAfterNativeChange() {
    refreshMenuState()
  }

  /// Formats the system menu title for the active owner and requested direction.
  private func actionTitle(for direction: Direction) -> String {
    _ = validationRevision

    guard let actionName = actionName(for: direction), actionName.isEmpty == false else {
      return String(localized: direction.simpleLocalizationKey)
    }

    return String.localizedStringWithFormat(
      String(localized: direction.localizationKey),
      actionName
    )
  }

  /// Returns the action name supplied by the current Undo owner.
  private func actionName(for direction: Direction) -> String? {
    switch owner {
    case .native(let manager):
      switch direction {
      case .undo:
        return manager.undoActionName
      case .redo:
        return manager.redoActionName
      }
    case .commands(let service):
      let reversal: (any CommandReversal)?
      switch direction {
      case .undo:
        reversal = service.nextUndo
      case .redo:
        reversal = service.nextRedo
      }
      return (reversal as? any CommandReversalWithUI)?.historyActionName()
    case nil:
      return nil
    }
  }
}

/// The history owner selected by a system Undo or Redo invocation.
private enum Owner {
  /// A focused framework text editor's manager.
  case native(UndoManager)

  /// The Commands history for the example window.
  case commands(UndoService)
}

/// The system action whose title and availability the router resolves.
private enum Direction {
  /// The action that reverses the most recent operation.
  case undo

  /// The action that reapplies the next reversed operation.
  case redo

  /// The localized format string for an action with a specific name.
  var localizationKey: LocalizedStringResource {
    switch self {
    case .undo:
      "action.undo"
    case .redo:
      "action.redo"
    }
  }

  /// The localized title for an action without a specific name.
  var simpleLocalizationKey: LocalizedStringResource {
    switch self {
    case .undo:
      "action.undo.simple"
    case .redo:
      "action.redo.simple"
    }
  }
}

#if os(macOS)
  extension SystemUndoRouter {
    /// Notifications that can change AppKit text editing focus or Undo state.
    private var nativeUndoChangeNotifications: [Notification.Name] {
      [
        .NSUndoManagerCheckpoint,
        .NSUndoManagerDidUndoChange,
        .NSUndoManagerDidRedoChange,
        NSText.didBeginEditingNotification,
        NSText.didChangeNotification,
        NSText.didEndEditingNotification,
        NSWindow.didBecomeKeyNotification,
        NSWindow.didResignKeyNotification,
      ]
    }

    /// The manager for a focused AppKit text editor, when present.
    private var nativeTextUndoManager: UndoManager? {
      guard let responder = NSApp.keyWindow?.firstResponder, responder is NSTextView else {
        return nil
      }

      return responder.undoManager
    }
  }

  /// Supplies the same composition hook as UIKit without adding AppKit state.
  struct SystemUndoWindowAnchor: View {
    /// Produces no AppKit content because AppKit resolves the key window directly.
    var body: some View {
      EmptyView()
    }
  }
#elseif canImport(UIKit)
  extension SystemUndoRouter {
    /// Notifications that can change UIKit text editing focus or Undo state.
    private var nativeUndoChangeNotifications: [Notification.Name] {
      [
        .NSUndoManagerCheckpoint,
        .NSUndoManagerDidUndoChange,
        .NSUndoManagerDidRedoChange,
        UITextField.textDidBeginEditingNotification,
        UITextField.textDidChangeNotification,
        UITextField.textDidEndEditingNotification,
        UITextView.textDidBeginEditingNotification,
        UITextView.textDidChangeNotification,
        UITextView.textDidEndEditingNotification,
      ]
    }

    /// The manager for a focused UIKit text editor, when present.
    private var nativeTextUndoManager: UndoManager? {
      guard
        let window = UndoWindowLocator.shared.window,
        let responder = window.undoLabFirstResponder,
        responder is UITextField || responder is UITextView
      else {
        return nil
      }

      return responder.undoManager
    }
  }

  /// Retains the active UIKit window for the example's focus resolver.
  @MainActor
  final class UndoWindowLocator {
    /// Shared locator used by the router and its SwiftUI anchor.
    static let shared = UndoWindowLocator()

    /// The most recently attached example window.
    weak var window: UIWindow?
  }

  /// Adds a UIKit view that records the window hosting the SwiftUI example.
  @MainActor
  struct SystemUndoWindowAnchor: UIViewRepresentable {
    /// The UIKit view type inserted into the SwiftUI hierarchy.
    typealias UIViewType = UndoWindowAnchorView

    /// Creates the inert view used to observe its hosting window.
    func makeUIView(context: UIViewRepresentableContext<SystemUndoWindowAnchor>) -> UIViewType {
      UndoWindowAnchorView()
    }

    /// Updates the locator after SwiftUI attaches the view to its window.
    func updateUIView(
      _ view: UIViewType,
      context: UIViewRepresentableContext<SystemUndoWindowAnchor>
    ) {
      UndoWindowLocator.shared.window = view.window
    }
  }

  /// A view that refreshes the locator after moving between windows.
  final class UndoWindowAnchorView: UIView {
    /// Records the host window whenever UIKit moves this view.
    override func didMoveToWindow() {
      super.didMoveToWindow()
      UndoWindowLocator.shared.window = window
    }
  }

  extension UIWindow {
    /// The first responder contained in this window's view hierarchy.
    fileprivate var undoLabFirstResponder: UIResponder? {
      rootViewController?.view.undoLabFirstResponder()
    }
  }

  extension UIView {
    /// Searches this view hierarchy for the current first responder.
    fileprivate func undoLabFirstResponder() -> UIResponder? {
      if isFirstResponder {
        return self
      }

      for subview in subviews {
        if let responder = subview.undoLabFirstResponder() {
          return responder
        }
      }

      return nil
    }
  }
#endif
