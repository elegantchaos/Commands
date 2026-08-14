// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Icons
import UniformTypeIdentifiers

/// Adds a completed item until the example reaches its configured limit.
struct AddCompletedItemCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  let id = "example.command.add"

  func icon(centre: Centre) -> Icons.Icon {
    Icon("plus")
  }

  func availability(centre: Centre) -> CommandAvailability {
    centre.service.completedItems < centre.service.maximumCompletedItems ? .enabled : .disabled
  }

  func perform(centre: Centre) async throws {
    centre.service.addCompletedItem()
  }

  func reversal(centre: Centre) -> (any CommandReversal)? {
    CommandReversalAdapterWithUI(command: RemoveCompletedItemCommand(), centre: centre)
  }
}

/// Removes a completed item when one exists.
struct RemoveCompletedItemCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  let id = "example.command.remove"

  func icon(centre: Centre) -> Icons.Icon {
    Icon("minus")
  }

  func availability(centre: Centre) -> CommandAvailability {
    centre.service.completedItems > 0 ? .enabled : .disabled
  }

  func perform(centre: Centre) async throws {
    centre.service.removeCompletedItem()
  }

  func reversal(centre: Centre) -> (any CommandReversal)? {
    CommandReversalAdapterWithUI(command: AddCompletedItemCommand(), centre: centre)
  }
}

/// Clears completed items after explicit confirmation.
struct ClearCompletedItemsCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  let id = "example.command.clear"

  func icon(centre: Centre) -> Icons.Icon {
    Icon("trash")
  }

  func availability(centre: Centre) -> CommandAvailability {
    centre.service.completedItems > 0 ? .enabled : .disabled
  }

  func confirmation(centre: Centre) -> CommandConfirmation? {
    CommandConfirmation(
      titleKey: "example.clear.confirmation.title",
      cancelKey: "example.clear.confirmation.cancel",
      messageKey: "example.clear.confirmation.message",
      confirmKey: "example.clear.confirmation.confirm"
    )
  }

  func perform(centre: Centre) async throws {
    centre.service.removeAllCompletedItems()
  }
}

/// Switches the visibility of commands intended for advanced users.
struct ToggleAdvancedCommandsCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  let id = "example.command.toggleAdvanced"

  func icon(centre: Centre) -> Icons.Icon {
    Icon("slider.horizontal.3")
  }

  func perform(centre: Centre) async throws {
    centre.service.showsAdvancedCommands.toggle()
  }
}

/// Demonstrates a command that is hidden until a separate command enables it.
struct ReviewCompletedItemsCommand<Centre: ExampleServiceProvider>: CommandWithUI {
  let id = "example.command.review"

  func icon(centre: Centre) -> Icons.Icon {
    Icon("checkmark.seal")
  }

  func availability(centre: Centre) -> CommandAvailability {
    guard centre.service.showsAdvancedCommands else { return .hidden }
    return centre.service.completedItems > 0 ? .enabled : .disabled
  }

  func perform(centre: Centre) async throws {
    centre.service.reviewCompletedItems()
  }
}

/// Imports one or more plain-text files and records their names.
struct ImportExampleFilesCommand<Centre: ExampleServiceProvider>: ImporterCommand {
  let id = "example.command.import"

  var types: [UTType] { [.plainText] }

  var allowsMultipleSelection: Bool { true }

  var state: ImporterState = .unknown

  func icon(centre: Centre) -> Icons.Icon {
    Icon("square.and.arrow.down")
  }

  func perform(centre: Centre) async throws {
    if case .chosen(let urls) = state {
      centre.service.importFiles(at: urls)
    }
  }
}
