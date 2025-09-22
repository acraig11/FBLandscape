import SwiftUI
import WebKit
import Combine

// MARK: - Store published state from WKWebView
final class WebViewStore: ObservableObject {
    @Published var progress: Double = 0
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    var webView: WKWebView?
}

// MARK: - SwiftUI wrapper for WKWebView (loads HTML)
struct WebView: UIViewRepresentable {
    let html: String
    @ObservedObject var store: WebViewStore

    func makeCoordinator() -> Coordinator { Coordinator(store: store) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.preferredContentMode = .mobile

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        // Observe progress & nav state
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)

        store.webView = webView

        // Load the HTML with your iframe
        webView.loadHTMLString(html, baseURL: nil)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    // MARK: - Coordinator
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let store: WebViewStore
        init(store: WebViewStore) { self.store = store }

        override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                   change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard let webView = object as? WKWebView else { return }
            switch keyPath {
            case "estimatedProgress":
                store.progress = webView.estimatedProgress
            case "canGoBack":
                store.canGoBack = webView.canGoBack
            case "canGoForward":
                store.canGoForward = webView.canGoForward
            default:
                break
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.scrollView.refreshControl?.endRefreshing()
        }

        @objc func handleRefresh(_ sender: UIRefreshControl) {
            (sender.superview as? WKWebView)?.reload()
        }
    }
}

// MARK: - Your view
struct RealEstateView: View {
    // ⬇️ Your exact iframe snippet wrapped in HTML
    private let iframeHTML = """
    <!doctype html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
      <style>
        html, body { margin: 0; padding: 0; height: 100%; }
        iframe { border: 0; width: 100%; height: 100%; display: block; }
      </style>
    </head>
    <body>
      <iframe src="https://stellar.mlsmatrix.com/Matrix/public/IDX.aspx?idx=fd456ff8"
              width="100%" height="50%" frameborder="0"
              marginwidth="0" marginheight="0">
      </iframe>
    </body>
    </html>
    """

    @StateObject private var web = WebViewStore()

    var body: some View {
        VStack(spacing: 0) {
            TitleBar()

            Text("Commercial & Residential Real Estate")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.vertical, 8)

            Text("Buy or sell your next property. Use this map to view existing listings.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.vertical, 8)

            if web.progress < 1.0 {
                ProgressView(value: web.progress)
                    .progressViewStyle(.linear)
                    .padding(.horizontal)
            }

            // Load your iframe HTML
            WebView(html: iframeHTML, store: web)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Toolbar
            HStack {
                Button { web.webView?.goBack() } label: {
                    Image(systemName: "chevron.left")
                }.disabled(!web.canGoBack)

                Button { web.webView?.goForward() } label: {
                    Image(systemName: "chevron.right")
                }.disabled(!web.canGoForward)

                Spacer()

                Button { web.webView?.reload() } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    RealEstateView()
}

