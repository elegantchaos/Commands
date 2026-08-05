//
//  ContentView.swift
//  Example
//
//  Created by Sam Deane on 05/08/2026.
//

import SwiftUI
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
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
