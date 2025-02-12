import SwiftUI

@main
struct HoloBarApp: App {
    @StateObject private var fetcher = CharacterFetcher()
    @State private var showAvatars = false

    var body: some Scene {
        MenuBarExtra {
            VStack {
                if fetcher.characters.isEmpty {
                    Text("Loading …")
                } else {
                    ForEach(fetcher.characters) { character in
                        Button(action: {
                            NSWorkspace.shared.open(character.profileURL)
                        }) {
                            HStack {
                                if showAvatars {
                                    AsyncImage(url: character.avatarURL, content: { $0 }, placeholder: {
                                        Image(systemName: "person.crop.circle")
                                    })
                                }

                                Text(character.name)
                            }
                        }
                    }
                }

                Divider()

                #if DEBUG
                    Button("Simulate Day Change") {
                        NotificationCenter.default.post(name: .NSCalendarDayChanged, object: nil)
                    }
                #endif

                Button("\(showAvatars ? "Hide" : "Show") Avatars") {
                    showAvatars.toggle()
                }

                Button("Refresh", action: refreshCharacters)
                Button("Quit", action: { NSApplication.shared.terminate(nil) })
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
