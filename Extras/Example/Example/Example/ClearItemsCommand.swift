// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Icons

/// Removes every item, after asking the user to confirm.
struct ClearItemsCommand<Centre: BenchItemsProvider>: CommandWithUI {
  /// Stable identifier for the command.
  let id = "com.elegantchaos.commands.bench.clear-items"

  /// The name shown on the command's controls.
  func name(centre: Centre) -> String { "Clear Items" }

  /// The icon shown on the command's controls.
  func icon(centre: Centre) -> Icon { Icon("trash") }

  /// The bench commands have no help text.
  func help(centre: Centre) -> String? { nil }

  /// Disabled when there is nothing to clear.
  func availability(centre: Centre) -> CommandAvailability {
    centre.items.count > 0 ? .enabled : .disabled
  }

  /// Asks the user to confirm before clearing.
  func confirmation(centre: Centre) -> CommandConfirmation? {
    CommandConfirmation(
      title: "Clear all items?",
      cancel: "Cancel",
      message: "This removes all \(centre.items.count) items.",
      confirm: "Clear"
    )
  }

  /// Removes every item.
  func perform(centre: Centre) async throws {
    centre.items.count = 0
  }
}
