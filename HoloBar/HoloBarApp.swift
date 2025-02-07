import SwiftUI

@main
struct HoloBarApp: App {
    @StateObject private var fetcher = CharacterFetcher()

    var body: some Scene {
        MenuBarExtra {
            if fetcher.characters.isEmpty {
                Text("Loading …")
            } else {
                ForEach(fetcher.characters) { character in
                    Button(character.name) {
                        NSWorkspace.shared.open(character.profileURL)
                    }
                }
            }

            Divider()
            Button("Refresh") {
                let today = Calendar.current.dateComponents([.month, .day], from: Date())

                if let month = today.month, let day = today.day {
                    fetcher.fetchCharacters(for: month, day: day)
                }
            }
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Text("HL")
        }
    }
}
