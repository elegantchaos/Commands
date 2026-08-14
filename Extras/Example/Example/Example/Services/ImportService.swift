// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Observation

/// Owns the imported-file state and API used by the example importer command.
///
/// Keeping this responsibility separate from `ItemService` demonstrates that an
/// application command centre can compose unrelated service areas. Commands
/// that import files require only `ImportServiceProvider`, so they neither see
/// nor depend on the item-management state owned by `ItemService`.
@MainActor
@Observable
final class ImportService {
  /// Names of files selected by the importer command.
  var importedFileNames: [String] = []

  /// Records the names of the files chosen by the importer.
  func importFiles(at urls: [URL]) {
    importedFileNames = urls.map(\.lastPathComponent)
  }
}
