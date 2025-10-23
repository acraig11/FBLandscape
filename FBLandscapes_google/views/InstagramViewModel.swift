//
//  InstagramViewModel.swift
//  Coast Life
//
//  Created by alan craig on 8/2/25.
//

import Foundation
class InstagramViewModel: ObservableObject {
    @Published var postURL: String?

    private let githubFileURL = "https://raw.githubusercontent.com/acraig11/coast-life-user-content/main/instagram.txt"

    func fetchPostURL() {
        guard let url = URL(string: githubFileURL) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,
                  let rawURL = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                  error == nil else {
                print("❌ Error fetching Instagram URL")
                return
            }

            DispatchQueue.main.async {
                self.postURL = rawURL
            }
        }.resume()
    }
}
