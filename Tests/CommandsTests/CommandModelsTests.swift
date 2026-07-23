// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Codex on 13/03/2026.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
import Testing

/// Verifies the lightweight value types exposed by the Commands module.
struct CommandModelsTests {
  /// Checks that trigger ordering and raw values remain stable.
  @Test func commandTriggerOrderingAndRawValuesRemainStable() async throws {
    #expect(CommandTrigger.allCases == [.primary, .secondary, .tertiary])
    #expect(CommandTrigger.primary.rawValue == "primary")
    #expect(CommandTrigger.secondary.rawValue == "secondary")
    #expect(CommandTrigger.tertiary.rawValue == "tertiary")
  }
}
