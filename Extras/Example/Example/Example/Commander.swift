// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import SwiftUI

/// Composes the example's command execution, state, and undo history.
///
/// `Commander` is the app-level command centre shared by every command surface.
/// It composes the item-management `ItemService`, the importing `ImportService`, and
/// the `UndoService`. Each command declares only the provider capability it
/// needs, allowing unrelated command areas to stay independent while this type
/// remains the single composition root for the example application.
@MainActor
final class Commander: ImportServiceProvider, ItemServiceProvider, UndoableCommandCentre {
  /// Service used by the item-management and advanced commands.
  var itemService = ItemService()

  /// Service used exclusively by importer commands.
  var importService = ImportService()

  /// Service that coordinates the reversible example commands.
  var undoService: UndoService = UndoService()
}
