// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Observation

/// State the bench's commands read their availability from.
///
/// `isEnabled` and `isVisible` flip on a timer while their toggling switches are on, so commands
/// that follow them change availability while the user watches the controls that show them.
/// They are independent, so a change of enabled state can be watched without items appearing or
/// disappearing at the same moment.
@Observable
final class BenchState {
  /// Whether commands that switch between enabled and disabled are enabled.
  var isEnabled = true

  /// Whether commands that switch between enabled and hidden are shown.
  var isVisible = true

  /// Whether the timer flips `isEnabled`.
  var isTogglingEnabled = false

  /// Whether the timer flips `isVisible`.
  var isTogglingVisible = false

  /// Flips each value whose toggling is on every `interval`, until the calling task is cancelled.
  func runToggling(every interval: Duration = .seconds(1.5)) async {
    while !Task.isCancelled {
      try? await Task.sleep(for: interval)
      if isTogglingEnabled { isEnabled.toggle() }
      if isTogglingVisible { isVisible.toggle() }
    }
  }
}

/// A command centre that offers the bench state.
protocol BenchStateProvider: CommandCentre {
  /// The state bench commands read.
  var bench: BenchState { get }
}
