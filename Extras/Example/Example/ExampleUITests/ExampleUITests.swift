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

  #if os(macOS)
    /// Verifies that typing in the text editor and commands undo in the reverse of the order they happened.
    @MainActor
    func testEditorTypingAndCommandsUndoInReverseOrder() throws {
      let app = XCUIApplication()
      app.launch()
      selectTab("UndoManager", in: app)

      let editor = app.textViews.firstMatch
      let observed = undoStates(typingInto: editor, in: app)

      XCTAssertEqual(observed, ["ab | 1", "a | 1", "a | 0", " | 0"])
    }

    /// Checks whether typing in the text field undoes in the same order as the text editor.
    ///
    /// On macOS, SwiftUI's text field edits through a field editor with its own undo manager, so
    /// all of its typing is undone before any command. The expected failure records that
    /// difference, and the test reports it if the text field starts behaving like the editor.
    @MainActor
    func testFieldTypingAndCommandsUndoInReverseOrder() throws {
      let app = XCUIApplication()
      app.launch()
      selectTab("UndoManager", in: app)

      let field = app.textFields["Text field"]
      let observed = undoStates(typingInto: field, in: app)

      XCTExpectFailure("A macOS text field keeps its own undo stack while it is being edited.")
      XCTAssertEqual(observed, ["ab | 1", "a | 1", "a | 0", " | 0"])
    }

    /// Types "a", increments, types "b", then presses Command-Z three times, returning the state after each step.
    @MainActor
    private func undoStates(typingInto input: XCUIElement, in app: XCUIApplication) -> [String] {
      input.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).click()
      let focused = NSPredicate(format: "hasKeyboardFocus == true")
      XCTAssertEqual(
        XCTWaiter.wait(for: [expectation(for: focused, evaluatedWith: input)], timeout: 2),
        .completed)
      app.typeText("a")
      press(app.buttons["Increment"])
      XCTAssertTrue(app.staticTexts["Done: 1"].waitForExistence(timeout: 2))
      app.typeText("b")

      var observed = [state(of: app, input: input)]
      for _ in 1...3 {
        app.typeKey("z", modifierFlags: .command)
        observed.append(state(of: app, input: input))
      }
      return observed
    }

    /// Returns the input's text and the count, for comparing undo states.
    @MainActor
    private func state(of app: XCUIApplication, input: XCUIElement) -> String {
      let countText = app.staticTexts.matching(NSPredicate(format: "value BEGINSWITH 'Done: '"))
        .firstMatch
      let count = ((countText.value as? String) ?? "?").replacing("Done: ", with: "")
      let text = (input.value as? String) ?? "?"
      return "\(text) | \(count)"
    }
  #endif

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
