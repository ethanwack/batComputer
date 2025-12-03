
import Foundation
import Speech
import AVFoundation
import AppIntents

@available(iOS 16.0, macOS 13.0, *)
struct ActivateBatComputerIntent: AppIntent {
    static let title: LocalizedStringResource = "Activate Bat Computer"
    static let description: IntentDescription = IntentDescription(
        "Activates the Bat Computer voice assistant",
        categoryName: "Bat Computer"
    )
    
    func perform() async throws -> some IntentResult {
        await BatComputerManager.shared.toggleListening()
        return .result()
    }
}

@available(iOS 16.0, macOS 13.0, *)
struct BatComputerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ActivateBatComputerIntent(),
            phrases: [
                "Hey Computer",
                "Computer",
                "Activate Bat Computer"
            ]
        )
    }
}