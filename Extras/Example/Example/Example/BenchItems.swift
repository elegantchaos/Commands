// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Observation

/// The items the Confirmation and Import pages' commands change.
@Observable
final class BenchItems {
  /// How many items the Confirmation page has; clearing them asks first.
  var count = 3

  /// The names of the files most recently imported on the Import page.
  var importedFiles: [String] = []
}

/// Supplies the items the Confirmation and Import pages' commands change.
protocol BenchItemsProvider: CommandCentre {
  /// The items the commands change.
  var items: BenchItems { get }
}
