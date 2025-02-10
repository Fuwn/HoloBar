import SwiftUI

@main
struct HoloBarApp: App {
    @StateObject private var fetcher = CharacterFetcher()

    var body: some Scene {
        MenuBarExtra {
            VStack {
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
                #if DEBUG
                    Button("Simulate Day Change") {
                        NotificationCenter.default.post(name: .NSCalendarDayChanged, object: nil)
                    }
                #endif
                Button("Refresh") {
                    refreshCharacters()
                }
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
                refreshCharacters()
            }
        } label: {
            Text("HL")
        }
    }

    private func refreshCharacters() {
        let today = Calendar.current.dateComponents([.month, .day], from: Date())

        if let month = today.month, let day = today.day {
            fetcher.characters.removeAll()
            fetcher.fetchCharacters(for: month, day: day)
        }
    }
}
