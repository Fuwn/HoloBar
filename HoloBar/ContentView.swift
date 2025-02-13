import SwiftUI

struct ContentView: View {
    @EnvironmentObject var fetcher: CharacterFetcher
    @State private var searchText: String = ""

    private var filteredCharacters: [Character] {
        if searchText.isEmpty { return fetcher.characters }

        return fetcher.characters.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            List(filteredCharacters) { character in
                Button {
                    NSWorkspace.shared.open(character.profileURL)
                } label: {
                    HStack(spacing: 16) {
                        AsyncImage(url: character.avatarURL) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else if phase.error != nil {
                                Image(systemName: "person.crop.circle.badge.exclamationmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundStyle(.gray)
                            } else {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundStyle(.gray)
                                    .opacity(0.25)
                            }
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(character.rawName).font(.headline)

                            Text(character.affiliation)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Characters")
            .searchable(text: $searchText, placement: .automatic, prompt: "Search Characters")
            .toolbar {
                ToolbarItem {
                    Button(action: fetcher.refreshCharactersForToday) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .help("Refresh Characters")
                }
            }
        }
    }
}
