// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

/// UI tests that perform, undo and redo a command on each of the example's undo tabs.
final class ExampleUITests: XCTestCase {
  /// Stops each test at its first failure, since later steps depend on earlier ones.
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  /// Verifies that the UndoManager tab's commands undo and redo through the window's undo manager.
  @MainActor
  func testUndoManagerTabUndoesAndRedoesCommands() throws {
    let app = XCUIApplication()
    app.launch()
    selectTab("UndoManager", in: app)

    press(app.buttons["Increment"])
    XCTAssertTrue(app.staticTexts["Done: 1"].waitForExistence(timeout: 2))

    press(app.buttons["Undo Increment"])
    XCTAssertTrue(app.staticTexts["Done: 0"].waitForExistence(timeout: 2))

    press(app.buttons["Redo Increment"])
    XCTAssertTrue(app.staticTexts["Done: 1"].waitForExistence(timeout: 2))
  }

  /// Verifies that the History tab's command undoes and redoes through its history service.
  @MainActor
  func testHistoryTabUndoesAndRedoesCommands() throws {
    let app = XCUIApplication()
    app.launch()
    selectTab("History", in: app)

    press(app.buttons["Increment"])
    XCTAssertTrue(app.staticTexts["Done: 1"].waitForExistence(timeout: 2))

    press(app.buttons["Undo Increment"])
    XCTAssertTrue(app.staticTexts["Done: 0"].waitForExistence(timeout: 2))

    press(app.buttons["Redo Increment"])
    XCTAssertTrue(app.staticTexts["Done: 1"].waitForExistence(timeout: 2))
  }

  /// Measures how long the application takes to launch.
  @MainActor
  func testLaunchPerformance() throws {
    measure(metrics: [XCTApplicationLaunchMetric()]) {
      XCUIApplication().launch()
    }
  }

  /// Selects the tab with the supplied title, however the platform presents tabs.
  @MainActor
  private func selectTab(_ title: String, in app: XCUIApplication) {
    let candidates = [app.radioButtons[title], app.tabs[title], app.buttons[title]]
    guard let tab = candidates.first(where: { $0.waitForExistence(timeout: 2) }) else {
      XCTFail("No tab titled \(title)")
      return
    }
    press(tab)
  }

  /// Clicks the element on macOS and taps it elsewhere.
  @MainActor
  private func press(_ element: XCUIElement) {
    #if os(macOS)
      element.click()
    #else
      element.tap()
    #endif
  }
}
