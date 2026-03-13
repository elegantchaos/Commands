import Commands
import Testing
@testable import CommandsUI

/// Ensures the public trigger ordering remains stable for UI resolution logic.
@Test func testCommandTriggerOrdering() async throws {
  #expect(CommandTrigger.allCases == [.primary, .secondary, .tertiary])
  #expect(CommandTrigger.primary.rawValue == "primary")
  #expect(CommandTrigger.secondary.rawValue == "secondary")
  #expect(CommandTrigger.tertiary.rawValue == "tertiary")
}
