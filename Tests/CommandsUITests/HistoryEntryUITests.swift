// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
import Icons
import Testing

@testable import CommandsUI

/// Command centre with history, used to check how history entries present UI commands.
@MainActor
private final class HistoryUITestCentre: CommandCentreWithHistory {
  /// History recorded by the centre.
  let historyService = HistoryService()

  /// Suffix appended to command names, to show that metadata is read from the centre's current state.
  var nameSuffix = ""
}

/// UI command with history, whose reversal is another instance of the same type.
@MainActor
private struct HistoryUICommand: CommandWithUI, CommandWithHistory {
  /// Centre type, declared because inference cannot resolve a command that is its own reversal.
  typealias Centre = HistoryUITestCentre

  /// Output type, declared for the same reason as `Centre`.
  typealias Output = Void

  /// Identifier used by assertions.
  let id: String

  /// Identifier of the reversal command, if any.
  let reversalID: String?

  /// Returns a name that includes the centre's current suffix.
  func name(centre: HistoryUITestCentre) -> String {
    "History Command \(id)\(centre.nameSuffix)"
  }

  /// Returns a fixed icon.
  func icon(centre: HistoryUITestCentre) -> Icon {
    Icon("clock.arrow.circlepath")
  }

  /// Returns fixed help text.
  func help(centre: HistoryUITestCentre) -> String? {
    "History help"
  }

  /// Performs no work.
  func perform(centre: HistoryUITestCentre) async throws {
  }

  /// Returns the configured reversal.
  func reversal(centre: HistoryUITestCentre) -> HistoryUICommand? {
    reversalID.map { HistoryUICommand(id: $0, reversalID: id) }
  }
}

/// Command with history but no UI metadata.
@MainActor
private struct HistoryPlainCommand: CommandWithHistory {
  /// Centre type, declared because inference cannot resolve a command that is its own reversal.
  typealias Centre = HistoryUITestCentre

  /// Output type, declared for the same reason as `Centre`.
  typealias Output = Void

  /// Identifier used by assertions.
  let id = "history.plain"

  /// Performs no work.
  func perform(centre: HistoryUITestCentre) async throws {
  }

  /// Has no reversal.
  func reversal(centre: HistoryUITestCentre) -> HistoryPlainCommand? {
    nil
  }
}

/// Tests the UI view of history entries and history recording through wrapped commands.
@MainActor
struct HistoryEntryUITests {
  /// Verifies that an entry presents the current metadata of the action that names its step.
  @Test func entryPresentsCurrentActionMetadata() throws {
    let centre = HistoryUITestCentre()
    centre.historyService.recordUndo(
      HistoryUICommand(id: "back", reversalID: nil),
      of: HistoryUICommand(id: "a", reversalID: nil), centre: centre)
    let entry = try #require(centre.historyService.nextUndo)

    let presentation = try #require(entry.presentation)
    #expect(presentation.name == "History Command a")
    #expect(presentation.icon.systemImage == "clock.arrow.circlepath")
    #expect(presentation.help == "History help")

    centre.nameSuffix = " (changed)"
    #expect(entry.presentation?.name == "History Command a (changed)")
  }

  /// Verifies that an entry whose action has no UI metadata has no presentation.
  @Test func entryWithoutUIActionHasNoPresentation() throws {
    let centre = HistoryUITestCentre()
    centre.historyService.recordUndo(
      HistoryPlainCommand(), of: HistoryPlainCommand(), centre: centre)

    let entry = try #require(centre.historyService.nextUndo)
    #expect(entry.presentation == nil)
  }

  /// Verifies that a step is named after the forward command for both undo and redo.
  @Test func stepKeepsForwardCommandNameThroughUndoAndRedo() async throws {
    let centre = HistoryUITestCentre()
    try await centre.perform(HistoryUICommand(id: "forward", reversalID: "back"))

    #expect(centre.historyService.nextUndo?.presentation?.name == "History Command forward")

    try await centre.historyService.performUndo()
    #expect(centre.historyService.nextRedo?.presentation?.name == "History Command forward")

    try await centre.historyService.performRedo()
    #expect(centre.historyService.nextUndo?.presentation?.name == "History Command forward")
  }

  /// Verifies that a wrapped history command records the wrapped command's reversal.
  @Test func wrappedCommandRecordsWrappedReversal() async throws {
    let centre = HistoryUITestCentre()

    try await centre.perform(WrappedCommand(HistoryUICommand(id: "forward", reversalID: "back")))

    #expect(centre.historyService.stackDescription == "back")
  }
}
