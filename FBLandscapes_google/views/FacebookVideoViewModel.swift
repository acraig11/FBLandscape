//
import Foundation
import Combine

final class FacebookVideoViewModel: ObservableObject {
    @Published var iframeHTML: String? = nil

    // TODO: point this to your real raw GitHub file
    // e.g. https://raw.githubusercontent.com/<org-or-user>/<repo>/main/facebook_reel_iframe.html
    private let githubRawURL = URL(string:
        "https://raw.githubusercontent.com/acraig11/FBLandscape/main/reels.txt"
    )!

    func fetchIframeHTML() {
        let req = URLRequest(url: githubRawURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        URLSession.shared.dataTask(with: req) { [weak self] data, _, error in
            guard let self = self else { return }
            if let data = data, let html = String(data: data, encoding: .utf8), !html.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.async { self.iframeHTML = html }
            } else {
                // Optional: log/handle error
                DispatchQueue.main.async { self.iframeHTML = nil }
            }
        }.resume()
    }
}
