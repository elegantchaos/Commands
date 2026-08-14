// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
import Observation

/// Observable state used to demonstrate command availability and results.
@MainActor
@Observable
final class ExampleService {
  /// Maximum number of completed items allowed by the example.
  let maximumCompletedItems = 5

  /// Number of items completed through the add command.
  var completedItems = 0

  /// Names of files selected by the importer command.
  var importedFileNames: [String] = []

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

  /// Records the names of selected files.
  func importFiles(at urls: [URL]) {
    importedFileNames = urls.map(\.lastPathComponent)
  }

  /// Records the current completed-item count as having been reviewed.
  func reviewCompletedItems() {
    reviewedItems = completedItems
  }
}

/// Supplies the service required by the example commands.
protocol ExampleServiceProvider: CommandCentre {
  var service: ExampleService { get }

}
