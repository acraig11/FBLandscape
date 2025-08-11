//
//  VideoViewModel.swift
//  testgithubsocialmedialinks
//
//  Created by alan craig on 7/31/25.
//
import Foundation

class VideoViewModel: ObservableObject {
    @Published var videoID: String?
   

    private let githubFileURL = "https://raw.githubusercontent.com/acraig11/coast-life-user-content/main/reels.txt"
   

    func fetchVideoID() {
        guard let url = URL(string: githubFileURL) else {
            print("❌ Invalid GitHub URL.")
            return
        }

        print("🌐 Fetching video URL from: \(githubFileURL)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("🔁 HTTP status code: \(httpResponse.statusCode)")
            }

            guard let data = data,
                  let rawURL = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\"", with: "")
                    .replacingOccurrences(of: "'", with: "") else {
                print("❌ Failed to decode data from GitHub")
                return
            }

            print("📥 Raw URL string from GitHub: '\(rawURL)'")

            DispatchQueue.main.async {
                self.videoID = rawURL
            }
        }.resume()
    }


}
