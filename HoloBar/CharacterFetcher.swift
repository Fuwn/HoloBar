import Foundation
import SwiftSoup

class CharacterFetcher: ObservableObject {
    @Published var characters: [Character] = []

    init() {
        let today = Calendar.current.dateComponents([.month, .day], from: Date())

        if let month = today.month, let day = today.day {
            fetchCharacters(for: month, day: day)
        }
    }

    func fetchCharacters(for month: Int, day: Int) {
        let urlString = "https://hololist.net/birthday/?birthday_month=\(String(format: "%02d", month))&birthday_day=\(String(format: "%02d", day))"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil,
                  let html = String(data: data, encoding: .utf8) else { return }

            DispatchQueue.main.async {
                self.characters = self.parseHTML(html: html)
            }
        }

        task.resume()
    }

    private func parseHTML(html: String) -> [Character] {
        var fetchedCharacters: [Character] = []

        do {
            let document = try SwiftSoup.parse(html)
            let characterElements = try document.select("div.d-flex.mb-4.rounded")

            for element in characterElements {
                if let nameElement = try? element.select("a.line-truncate span").first(),
                   let linkElement = try? element.select("a.line-truncate").first(),
                   let profileHref = try? linkElement.attr("href"),
                   let profileURL = URL(string: profileHref)
                {
                    let name = try nameElement.text()

                    fetchedCharacters.append(Character(name: name, profileURL: profileURL))
                }
            }
        } catch {
            fetchedCharacters.append(Character(name: "Error parsing HTML", profileURL: URL(string: "#")!))
        }

        return fetchedCharacters
    }
}
