// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Displays the live values that determine command availability.
struct ExampleStatePanel: View {
  /// Current example state.
  let service: ExampleService

  var body: some View {
    GroupBox {
      VStack(alignment: .leading) {
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

        Divider()

        ImportedFilesState(fileNames: service.importedFileNames)

        Text("example.panel.state.hint")
          .font(.footnote)
          .foregroundStyle(.secondary)
          .padding(.top)
      }
    } label: {
      Label("example.section.state", systemImage: "chart.bar.xaxis")
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

/// Displays the latest importer result within the state panel.
private struct ImportedFilesState: View {
  /// Names returned by the importer command.
  let fileNames: [String]

  var body: some View {
    VStack {
      if fileNames.isEmpty {
        Label("example.imported.empty", systemImage: "doc")
          .foregroundStyle(.secondary)
      } else {
        Label("example.section.imported", systemImage: "doc.text")

        VStack(alignment: .leading) {
          ForEach(fileNames, id: \.self) { fileName in
            Label(fileName, systemImage: "doc.text")
              .font(.footnote)
          }
        }.padding()
      }
    }
  }
}
