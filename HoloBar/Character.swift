import Foundation

struct Character: Identifiable {
    let id = UUID()
    let name: String
    let profileURL: URL
    let avatarURL: URL
    let rawName: String
    let affiliation: String
}
