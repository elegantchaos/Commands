// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import SwiftUI

/// Demonstrates command execution and undo in a SwiftUI view.
struct ContentView: View {
  @State var commander = ExampleCommander()

  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Done: \(commander.service.count)")
      commander.button(ExampleCommand())
      commander.undoButton()
      Text("Stack: \(commander.undoService.debugDescription)")
    }
    .padding()
  }

}

#Preview {
  ContentView()
}
