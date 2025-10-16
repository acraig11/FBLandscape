import SwiftUI
import WebKit

struct InstagramWebView: UIViewRepresentable {
    let urlString: String

    class Coordinator: NSObject {
        weak var webView: WKWebView?

        @objc func pauseVideo() {
            webView?.evaluateJavaScript("""
                document.querySelectorAll('video').forEach(v => { v.pause(); v.currentTime = 0; });
            """, completionHandler: nil)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true  // ✅ Force inline playback
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = []
        } else {
            config.requiresUserActionForMediaPlayback = false
        }
        config.allowsPictureInPictureMediaPlayback = false

        let webView = WKWebView(frame: .zero, configuration: config)
        context.coordinator.webView = webView

        // Load Instagram post
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }

        // Listen for pause signal
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pauseVideo),
            name: .pauseInstagram,
            object: nil
        )

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        NotificationCenter.default.removeObserver(coordinator, name: .pauseInstagram, object: nil)
    }
}

extension Notification.Name {
    static let pauseInstagram = Notification.Name("PauseInstagram")
}

