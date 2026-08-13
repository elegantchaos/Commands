import Commands
import CommandsUI
import SwiftUI

// TODO: ability to extract the name of the command(s) to undo


class ExampleCommander: UndoableCommandCenter, ExampleServiceProvider {
  var service = ExampleService()
  var undoService: UndoService = UndoService()
}
