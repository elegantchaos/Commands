//
//  ContentView.swift
//  Example
//
//  Created by Sam Deane on 05/08/2026.
//

import SwiftUI
import Commands
import CommandsUI

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
