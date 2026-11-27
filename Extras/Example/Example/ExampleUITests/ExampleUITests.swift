// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

/// UI tests that check the bench's command controls and its undo pages.
///
/// On macOS they check that hidden commands are left out of lists, menus, the menu bar and the
/// toolbar, that availability changes reach the controls, and the order in which typing and
/// commands undo. On every platform they perform, undo and redo a command on each undo page.
///
/// Flicker cannot be detected here; the bench's README lists the checks to make by eye.
final class ExampleUITests: XCTestCase {
  /// The bench application under test.
  private let app = XCUIApplication()

  /// Launches the bench, stopping each test at its first failure.
  override func setUpWithError() throws {
    continueAfterFailure = false
    app.launch()
  }

  /// The UndoManager page's commands undo and redo through the window's undo manager.
  @MainActor
  func testUndoManagerPageUndoesAndRedoesCommands() throws {
    showPage("undoManager")
    performUndoAndRedo()
  }

  /// The History page's command undoes and redoes through its centre's history service.
  @MainActor
  func testHistoryPageUndoesAndRedoesCommands() throws {
    showPage("history")
    performUndoAndRedo()
  }

  #if os(macOS)
    /// Typing in the text editor and commands undo in the reverse of the order they happened.
    @MainActor
    func testEditorTypingAndCommandsUndoInReverseOrder() throws {
      showPage("undoManager")
      let observed = undoStates(typingInto: app.textViews.firstMatch)

      XCTAssertEqual(observed, ["ab | 1", "a | 1", "a | 0", " | 0"])
    }

    /// Checks whether typing in the text field undoes in the same order as the text editor.
    ///
    /// On macOS, SwiftUI's text field edits through a field editor with its own undo manager, so
    /// all of its typing is undone before any command. The expected failure records that
    /// difference, and the test reports it if the text field starts behaving like the editor.
    @MainActor
    func testFieldTypingAndCommandsUndoInReverseOrder() throws {
      showPage("undoManager")
      let observed = undoStates(typingInto: app.textFields["Text field"])

      XCTExpectFailure("A macOS text field keeps its own undo stack while it is being edited.")
      XCTAssertEqual(observed, ["ab | 1", "a | 1", "a | 0", " | 0"])
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

    /// A toolbar item given a custom label shows that label.
    @MainActor
    func testToolbarItemShowsCustomLabel() throws {
      showPage("toolbar")

      XCTAssertTrue(app.toolbars.buttons["Tool Custom Label"].waitForExistence(timeout: 5))
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

    /// Types "a", increments, types "b", then presses Command-Z three times, returning the state
    /// after each step.
    @MainActor
    private func undoStates(typingInto input: XCUIElement) -> [String] {
      XCTAssertTrue(input.waitForExistence(timeout: 5))
      input.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).click()
      let focused = NSPredicate(format: "hasKeyboardFocus == true")
      XCTAssertEqual(
        XCTWaiter.wait(for: [expectation(for: focused, evaluatedWith: input)], timeout: 2),
        .completed)
      app.typeText("a")
      press(app.buttons["Increment"])
      XCTAssertTrue(app.staticTexts["Done: 1"].waitForExistence(timeout: 2))
      app.typeText("b")

      var observed = [state(of: input)]
      for _ in 1...3 {
        app.typeKey("z", modifierFlags: .command)
        observed.append(state(of: input))
      }
      return observed
    }

    /// Returns the input's text and the count, for comparing undo states.
    @MainActor
    private func state(of input: XCUIElement) -> String {
      let countText = app.staticTexts.matching(NSPredicate(format: "value BEGINSWITH 'Done: '"))
        .firstMatch
      let count = ((countText.value as? String) ?? "?").replacing("Done: ", with: "")
      let text = (input.value as? String) ?? "?"
      return "\(text) | \(count)"
    }
  #endif

  /// Increments, undoes and redoes on the current page, checking the count after each step.
  @MainActor
  private func performUndoAndRedo() {
    let increment = app.buttons["Increment"]
    XCTAssertTrue(increment.waitForExistence(timeout: 5))
    press(increment)
    XCTAssertTrue(app.staticTexts["Done: 1"].waitForExistence(timeout: 2))

    press(app.buttons["Undo Increment"])
    XCTAssertTrue(app.staticTexts["Done: 0"].waitForExistence(timeout: 2))

    press(app.buttons["Redo Increment"])
    XCTAssertTrue(app.staticTexts["Done: 1"].waitForExistence(timeout: 2))
  }

  /// Shows a bench page by selecting its sidebar row, identified by the page's raw value.
  ///
  /// On a compact device the split view opens on the selected page, with the sidebar hidden, so
  /// it goes back to the page list first when the row is not on screen.
  @MainActor
  private func showPage(_ page: String) {
    let row = element("bench.page.\(page)")
    if !row.waitForExistence(timeout: 2) {
      let back = app.navigationBars.buttons["Bench"]
      if back.waitForExistence(timeout: 2) {
        press(back)
      }
    }
    XCTAssertTrue(row.waitForExistence(timeout: 5))
    press(row)
  }

  /// The element with an accessibility identifier, whatever its type.
  @MainActor
  private func element(_ identifier: String) -> XCUIElement {
    app.descendants(matching: .any).matching(identifier: identifier).firstMatch
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
