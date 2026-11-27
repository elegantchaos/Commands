// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Foundation
import Icons
import Testing

/// Command centre that registers undo actions with a Foundation `UndoManager`.
@MainActor
private final class UndoUITestCentre: CommandCentreWithUndo {
}

/// UI command that registers itself as its own inverse, to check the undo action name.
@MainActor
private struct NamedUndoCommand: CommandWithUndo, CommandWithUI {
  /// Centre type, declared because inference cannot resolve a command that is its own inverse.
  typealias Centre = UndoUITestCentre

  /// Output type, declared for the same reason as `Centre`.
  typealias Output = Void

  /// Stable identifier, which must not be used as the undo action name.
  let id = "test.ui.named-undo"

  /// Undo manager that receives the inverse command.
  weak var undoManager: UndoManager?

  /// Returns the user-visible name expected in the undo menu.
  func name(centre: UndoUITestCentre) -> String {
    "Named Undo"
  }

  /// Returns a fixed icon.
  func icon(centre: UndoUITestCentre) -> Icon {
    Icon("arrow.uturn.backward")
  }

  /// Performs no work.
  func performSynchronously(centre: UndoUITestCentre) {
  }

  /// Returns the same command, since it has no state to reverse.
  func undoCommand(centre: UndoUITestCentre) -> NamedUndoCommand {
    self
  }
}

/// Tests how UI commands present themselves to a Foundation `UndoManager`.
@MainActor
struct CommandWithUndoUITests {
  /// Verifies that a UI command's display name becomes its undo action name.
  @Test func undoActionUsesCommandName() async throws {
    let centre = UndoUITestCentre()
    let undoManager = UndoManager()
    undoManager.groupsByEvent = false

    undoManager.beginUndoGrouping()
    try await centre.perform(NamedUndoCommand(undoManager: undoManager))
    undoManager.endUndoGrouping()

    #expect(undoManager.undoActionName == "Named Undo")
  }
}
