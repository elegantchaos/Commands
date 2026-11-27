// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Foundation
import Icons
import UniformTypeIdentifiers

/// Imports files chosen in the system file importer, recording their names.
struct ImportFilesCommand<Centre: BenchItemsProvider>: ImporterCommand {
  /// The name shown on the command's controls.
  let title: String

  /// Whether the command asks the user to confirm the chosen files before importing them.
  let confirms: Bool

  /// The importer's result, set when the user has chosen.
  var state: ImporterState = .unknown

  /// Stable identifier for the command, derived from its name.
  var id: String { "com.elegantchaos.commands.bench.import.\(title)" }

  /// Any file can be imported.
  var types: [UTType] { [.item] }

  /// Several files can be chosen at once.
  var allowsMultipleSelection: Bool { true }

  /// The name shown on the command's controls.
  func name(centre: Centre) -> String { title }

  /// The icon shown on the command's controls.
  func icon(centre: Centre) -> Icon { Icon("square.and.arrow.down") }

  /// The bench commands have no help text.
  func help(centre: Centre) -> String? { nil }

  /// Asks the user to confirm the chosen files, when the command confirms.
  func confirmation(centre: Centre) -> CommandConfirmation? {
    guard confirms, case .chosen(let urls) = state else { return nil }
    return CommandConfirmation(
      title: "Import \(urls.count) files?",
      cancel: "Cancel",
      message: "This replaces the files imported before.",
      confirm: "Import"
    )
  }

  /// Records the names of the chosen files, or the importer's error.
  func perform(centre: Centre) async throws {
    switch state {
    case .chosen(let urls):
      centre.items.importedFiles = urls.map(\.lastPathComponent)
    case .error(let error):
      centre.items.importedFiles = ["Error: \(error.localizedDescription)"]
    case .unknown:
      break
    }
  }
}
