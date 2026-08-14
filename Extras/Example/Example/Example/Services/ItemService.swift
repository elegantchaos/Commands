// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation

/// Holds the observable item state used by the item-management commands.
///
/// This service owns only the completed-item, review, and advanced-mode state
/// that its commands need. Keeping that state out of `Commander` lets commands
/// depend on the focused `ItemServiceProvider` capability instead of the whole
/// application command centre. Import results belong to `ImportService`, which
/// keeps the importing area independent from these item-management commands.
@MainActor
@Observable
final class ItemService {
  /// Maximum number of completed items allowed by the example.
  let maximumCompletedItems = 5

  /// Number of items completed through the add command.
  var completedItems = 0

  /// Number of items processed by the advanced review command.
  var reviewedItems = 0

  /// Controls whether the advanced command is surfaced.
  var showsAdvancedCommands = false

  /// Adds a completed item.
  func addCompletedItem() {
    completedItems += 1
  }

  /// Removes the most recently completed item.
  func removeCompletedItem() {
    completedItems -= 1
  }

  /// Removes every completed item.
  func removeAllCompletedItems() {
    completedItems = 0
  }

  /// Records the current completed-item count as having been reviewed.
  func reviewCompletedItems() {
    reviewedItems = completedItems
  }
}
