// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

/// UI tests that check the bench's command controls: hidden commands are left out of lists,
/// menus, the menu bar and the toolbar, and availability changes reach the controls.
///
/// Flicker cannot be detected here; the bench's README lists the checks to make by eye.
final class ExampleUITests: XCTestCase {
  /// The launched bench.
  private var app: XCUIApplication!

  /// Launches the bench, stopping each test at its first failure.
  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launch()
  }

  /// A hidden command adds no row to a list: the list with one has as many rows as the list
  /// without.
  @MainActor
  func testHiddenCommandAddsNoListRow() throws {
    showPage("containers")
    let withHidden = element("bench.list.withHidden")
    let without = element("bench.list.without")
    XCTAssertTrue(withHidden.waitForExistence(timeout: 5))

    XCTAssertFalse(app.buttons["List Hidden"].exists)
    XCTAssertEqual(withHidden.cells.count, without.cells.count)
  }

  /// A hidden command adds no item to a menu.
  @MainActor
  func testHiddenCommandAddsNoMenuItem() throws {
    showPage("containers")
    let menu = element("bench.menu.withHidden")
    XCTAssertTrue(menu.waitForExistence(timeout: 5))
    menu.click()

    XCTAssertTrue(app.menuItems["Menu One"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.menuItems["Menu Hidden"].exists)
    app.typeKey(.escape, modifierFlags: [])
  }

  /// A hidden command adds no item to the Edit menu.
  @MainActor
  func testHiddenCommandAddsNoMenuBarItem() throws {
    app.menuBars.menuBarItems["Edit"].click()

    XCTAssertTrue(app.menuItems["Menu Bar One"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.menuItems["Menu Bar Hidden"].exists)
    app.typeKey(.escape, modifierFlags: [])
  }

  /// A hidden command adds no button to the toolbar.
  @MainActor
  func testHiddenCommandAddsNoToolbarButton() throws {
    showPage("toolbar")

    XCTAssertTrue(app.toolbars.buttons["Tool Enabled"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.toolbars.buttons["Tool Hidden"].exists)
  }

  /// A toolbar button follows its command as it switches between enabled and disabled.
  @MainActor
  func testToolbarButtonFollowsAvailability() throws {
    showPage("toolbar")
    let button = app.toolbars.buttons["Tool Toggling"]
    XCTAssertTrue(button.waitForExistence(timeout: 5))
    XCTAssertTrue(button.isEnabled)

    element("bench.togglingEnabled").click()

    wait(
      for: [expectation(for: NSPredicate(format: "isEnabled == false"), evaluatedWith: button)],
      timeout: 5)
  }

  /// A toolbar button for a command that switches between enabled and hidden comes and goes.
  @MainActor
  func testToolbarButtonAppearsAndDisappears() throws {
    showPage("toolbar")
    let button = app.toolbars.buttons["Tool Appearing"]
    XCTAssertTrue(button.waitForExistence(timeout: 5))

    element("bench.togglingVisible").click()

    wait(
      for: [expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: button)],
      timeout: 5)
  }

  /// Shows a bench page by selecting its sidebar row, identified by the page's raw value.
  private func showPage(_ page: String) {
    let row = element("bench.page.\(page)")
    XCTAssertTrue(row.waitForExistence(timeout: 5))
    row.click()
  }

  /// The element with an accessibility identifier, whatever its type.
  private func element(_ identifier: String) -> XCUIElement {
    app.descendants(matching: .any).matching(identifier: identifier).firstMatch
  }
}
