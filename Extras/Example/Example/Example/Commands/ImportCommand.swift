// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import Icons
import SwiftUI
import UniformTypeIdentifiers

/// Imports one or more plain-text files and records their names.
///
/// This command depends only on `ImportServiceProvider`, demonstrating that a
/// command can use a focused service area without knowing about unrelated item
/// state or APIs exposed through `ItemServiceProvider`.
struct ImportCommand<Centre: ImportServiceProvider>: ImporterCommand {
  /// Stable identifier for this command.
  let id = "example.command.import"

  /// Keyboard shortcut for importing text files.
  var shortcut: CommandShortcut? {
    CommandShortcut("i", modifiers: [.command, .shift])
  }

  /// Content types accepted by the example importer.
  var types: [UTType] { [.plainText] }

  /// Allows the importer to select several files in one operation.
  var allowsMultipleSelection: Bool { true }

  /// Result returned by the importer before the command is performed.
  var state: ImporterState = .unknown

  func icon(centre: Centre) -> Icons.Icon {
    Icon("square.and.arrow.down")
  }

  func perform(centre: Centre) async throws {
    if case .chosen(let urls) = state {
      centre.importService.importFiles(at: urls)
    }
  }
}
