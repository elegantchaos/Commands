// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Icons

/// Adds an item, so there is something to clear.
struct AddItemCommand<Centre: BenchItemsProvider>: CommandWithUI {
  /// Stable identifier for the command.
  let id = "com.elegantchaos.commands.bench.add-item"

  /// The name shown on the command's button.
  func name(centre: Centre) -> String { "Add Item" }

  /// The icon shown on the command's button.
  func icon(centre: Centre) -> Icon { Icon("plus") }

  /// The bench commands have no help text.
  func help(centre: Centre) -> String? { nil }

  /// Adds an item.
  func perform(centre: Centre) async throws {
    centre.items.count += 1
  }
}
