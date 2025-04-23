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
    let urlString =
      "https://hololist.net/birthday/?birthday_month=\(String(format: "%02d", month))&birthday_day=\(String(format: "%02d", day))"
    guard let url = URL(string: urlString) else { return }

    let task = URLSession.shared.dataTask(with: url) { data, _, error in
      guard let data = data, error == nil,
        let html = String(data: data, encoding: .utf8)
      else { return }

      DispatchQueue.main.async {
        self.fetchAffiliations(for: self.parseHTML(html: html))
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

          fetchedCharacters
            .append(
              Character(
                name: name,
                profileURL: profileURL,
                avatarURL: profileURL,  // Avatar URLs are fetched in ``fetchAffiliations``
                rawName: name,
                affiliation: ""
              )
            )
        }
      }
    } catch {
      let blankURL = URL(string: "#")!

      fetchedCharacters
        .append(
          Character(
            name: "Error parsing HTML",
            profileURL: blankURL,
            avatarURL: blankURL,
            rawName: "",
            affiliation: ""
          )
        )
    }

    return fetchedCharacters
  }

  private func fetchAffiliations(for characters: [Character]) {
    let group = DispatchGroup()
    var updatedCharacters: [Character] = []

    for character in characters {
      group.enter()

      let task = URLSession.shared.dataTask(with: character.profileURL) {
        data,
        _,
        error in
        defer { group.leave() }

        guard let data = data,
          error == nil,
          let html = String(data: data, encoding: .utf8)
        else { return }

        do {
          let document = try SwiftSoup.parse(html)

          if let affiliationElement = try? document.select("#affiliation a").first(),
            let affiliation = try? affiliationElement.text()
          {
            updatedCharacters
              .append(
                Character(
                  name: "\(character.name) (\(affiliation))",
                  profileURL: character.profileURL,
                  avatarURL: (try? document.select("#left img").first()?.attr("data-src"))
                    .flatMap { URL(string: $0) } ?? character.avatarURL,
                  rawName: character.name,
                  affiliation: affiliation
                )
              )
          } else {
            updatedCharacters.append(character)
          }
        } catch {
          updatedCharacters.append(character)
        }
      }

      task.resume()
    }

    group.notify(queue: .main) {
      self.characters = updatedCharacters
    }
  }
}
