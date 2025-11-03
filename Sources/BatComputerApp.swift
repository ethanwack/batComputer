import SwiftUI
import AppIntents

@main
struct BatComputerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var batComputer = BatComputerManager.shared
    
    var body: some View {
        VStack {
            Text("Bat Computer")
                .font(.title)
                .padding()
            
            if batComputer.isListening {
                Text("Listening...")
                    .foregroundColor(.green)
            }
            
            Button(action: {
                Task {
                    await batComputer.toggleListening()
                }
            }) {
                Image(systemName: batComputer.isListening ? "mic.fill" : "mic")
                    .font(.system(size: 50))
                    .padding()
            }
            
            Text(batComputer.lastResponse)
                .padding()
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}