// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
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
final class SystemUndoRouter {
  /// The Commands history used when no native text editor owns the action.
  private var undoService: UndoService?

  /// Configures the history used by this example app run.
  func configure(undoService: UndoService) {
    self.undoService = undoService
  }

  /// Whether the currently selected owner can undo.
  var canUndo: Bool {
    switch owner {
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
    switch owner {
    case .native(let manager):
      manager.canRedo
    case .commands(let service):
      service.hasRedo && service.isUndoing == false && service.isRedoing == false
    case nil:
      false
    }
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
}

/// The history owner selected by a system Undo or Redo invocation.
private enum Owner {
  /// A focused framework text editor's manager.
  case native(UndoManager)

  /// The Commands history for the example window.
  case commands(UndoService)
}

#if os(macOS)
  extension SystemUndoRouter {
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
    /// The manager for a focused UIKit text editor, when present.
    private var nativeTextUndoManager: UndoManager? {
      guard
        let window = UndoWindowLocator.shared.window,
        let responder = window.firstResponder,
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
  struct SystemUndoWindowAnchor: UIViewRepresentable {
    /// Creates the inert view used to observe its hosting window.
    func makeUIView(context: Context) -> UndoWindowAnchorView {
      UndoWindowAnchorView()
    }

    /// Updates the locator after SwiftUI attaches the view to its window.
    func updateUIView(_ view: UndoWindowAnchorView, context: Context) {
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
    fileprivate var firstResponder: UIResponder? {
      rootViewController?.view.firstResponder
    }
  }

  extension UIView {
    /// Searches this view hierarchy for the current first responder.
    fileprivate var firstResponder: UIResponder? {
      if isFirstResponder {
        return self
      }

      for subview in subviews {
        if let responder = subview.firstResponder {
          return responder
        }
      }

      return nil
    }
  }
#endif
