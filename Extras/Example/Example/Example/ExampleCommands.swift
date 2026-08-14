// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// Adds example commands to the platform command menus.
struct ExampleCommands: Commands {
  /// Shared command centre used to resolve command state.
  let commander: ExampleCommander

  var body: some Commands {
    CommandGroup(after: .newItem) {
      commander.importer(ImportExampleFilesCommand())
    }

    CommandMenu("example.menu.title") {
      commander.button(AddCompletedItemCommand())
      commander.button(RemoveCompletedItemCommand())
      commander.confirmableButton(ClearCompletedItemsCommand(), role: .destructive)

      Divider()

      commander.button(ToggleAdvancedCommandsCommand())
      commander.button(ReviewCompletedItemsCommand())
    }
  }
}

/// Renders command state that makes disabled and hidden examples discoverable.
struct CommandStateSection: View {
  /// Current example state.
  let service: ExampleService

  var body: some View {
    Section("example.section.state") {
      LabeledContent("example.state.completed") {
        Text(service.completedItems, format: .number)
      }
      LabeledContent("example.state.limit") {
        Text(service.maximumCompletedItems, format: .number)
      }
      LabeledContent("example.state.reviewed") {
        Text(service.reviewedItems, format: .number)
      }
      LabeledContent("example.state.advanced") {
        if service.showsAdvancedCommands {
          Text("example.state.visible")
        } else {
          Text("example.state.hidden")
        }
      }
    }
  }
}

/// Renders button-based command surfaces for the shared command centre.
struct CommandButtonsSection: View {
  /// Shared command centre that supplies the buttons.
  let commander: ExampleCommander

  var body: some View {
    Section("example.section.buttons") {
      commander.button(AddCompletedItemCommand())
      commander.button(RemoveCompletedItemCommand())
      commander.confirmableButton(ClearCompletedItemsCommand(), role: .destructive)
      commander.importer(ImportExampleFilesCommand())

      commander.button(ToggleAdvancedCommandsCommand())
      commander.button(ReviewCompletedItemsCommand())
    }
  }
}

/// Renders imported file names or an informative empty state.
struct ImportedFilesSection: View {
  /// Names returned by the importer command.
  let fileNames: [String]

  var body: some View {
    Section("example.section.imported") {
      if fileNames.isEmpty {
        ContentUnavailableView("example.imported.empty", systemImage: "doc")
      } else {
        ForEach(fileNames, id: \.self) { fileName in
          Label(fileName, systemImage: "doc.text")
        }
      }
    }
  }
}

/// Renders undo and redo controls for the reversible add and remove commands.
struct UndoSection: View {
  /// Shared command centre that owns the undo service.
  let commander: ExampleCommander

  var body: some View {
    Section("example.section.undo") {
      commander.undoButton(showsCommandPresentation: true)
      commander.redoButton(showsCommandPresentation: true)
    }
  }
}

/// Adds commands to the app toolbar on macOS and iOS.
struct ExampleToolbar: ToolbarContent {
  /// Shared command centre that supplies toolbar items.
  let commander: ExampleCommander

  var body: some ToolbarContent {
    commander.toolbarItem(AddCompletedItemCommand(), placement: .primaryAction)
    commander.toolbarItem(RemoveCompletedItemCommand(), placement: .secondaryAction)
    commander.confirmableToolbarItem(ClearCompletedItemsCommand(), placement: .secondaryAction)
    commander.toolbarItem(ReviewCompletedItemsCommand(), placement: .secondaryAction)
  }
}

/// Adds the same commands to the root view's contextual menu.
struct ExampleContextMenu: View {
  /// Shared command centre that supplies contextual buttons.
  let commander: ExampleCommander

  /// Controls presentation of the contextual importer sheet.
  @Binding var isShowingImporter: Bool

  var body: some View {
    commander.button(AddCompletedItemCommand())
    commander.button(RemoveCompletedItemCommand())
    commander.importerButton(ImportExampleFilesCommand(), isShowingImportSheet: $isShowingImporter)

    Divider()

    commander.button(ToggleAdvancedCommandsCommand())
    commander.button(ReviewCompletedItemsCommand())
  }
}
