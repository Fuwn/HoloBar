import Foundation

struct Character: Identifiable {
    let id = UUID()
    let name: String
    let profileURL: URL
}
