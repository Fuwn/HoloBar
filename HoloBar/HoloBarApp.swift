import SwiftUI

#Preview { ContentView().environmentObject(CharacterFetcher()) }

@main
struct HoloBarApp: App {
    @StateObject private var fetcher = CharacterFetcher()
    @State private var showAvatars = false

    var body: some Scene {
        Window("HoloBar", id: "main") {
            ContentView().environmentObject(fetcher)
        }

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
                                    AsyncImage(url: character.avatarURL) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } else if phase.error != nil {
                                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundStyle(.gray)
                                        } else {
                                            Image(systemName: "person.crop.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundStyle(.gray)
                                        }
                                    }
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

                Button("Show UI") {
                    for window in NSApp.windows {
                        if window.identifier?.rawValue == "main" {
                            window.makeKeyAndOrderFront(nil)

                            return
                        }
                    }
                }

                Button("\(showAvatars ? "Hide" : "Show") Avatars") {
                    showAvatars.toggle()
                }

                Button("Refresh", action: fetcher.refreshCharactersForToday)
                Button("Quit", action: { NSApplication.shared.terminate(nil) })
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
                fetcher.refreshCharactersForToday()
            }
        } label: {
            Text("HL")
        }
    }
}
