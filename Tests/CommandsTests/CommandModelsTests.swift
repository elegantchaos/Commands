// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Codex on 13/03/2026.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
import Testing

/// Verifies the lightweight value types exposed by the Commands module.
struct CommandModelsTests {
  /// Checks that the string-based confirmation initializer preserves values.
  @Test func confirmationStoresExplicitStrings() async throws {
    let confirmation = CommandConfirmation(
      title: "Delete Item",
      cancel: "Cancel",
      message: "This action cannot be undone.",
      confirm: "Delete"
    )

    #expect(confirmation.title == "Delete Item")
    #expect(confirmation.cancel == "Cancel")
    #expect(confirmation.message == "This action cannot be undone.")
    #expect(confirmation.confirm == "Delete")
  }

  /// Checks that the localized-resource initializer resolves inline string literals.
  @Test func confirmationResolvesLocalizedResources() async throws {
    let confirmation = CommandConfirmation(
      titleKey: "Archive",
      cancelKey: "Not Now",
      messageKey: "Archive the current item?",
      confirmKey: "Archive It"
    )

    #expect(confirmation.title == "Archive")
    #expect(confirmation.cancel == "Not Now")
    #expect(confirmation.message == "Archive the current item?")
    #expect(confirmation.confirm == "Archive It")
  }

  /// Checks that trigger ordering and raw values remain stable.
  @Test func commandTriggerOrderingAndRawValuesRemainStable() async throws {
    #expect(CommandTrigger.allCases == [.primary, .secondary, .tertiary])
    #expect(CommandTrigger.primary.rawValue == "primary")
    #expect(CommandTrigger.secondary.rawValue == "secondary")
    #expect(CommandTrigger.tertiary.rawValue == "tertiary")
  }
}
