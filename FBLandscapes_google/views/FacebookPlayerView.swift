//
//  FacebookPlayerView.swift
//  FBLandscapes
//
//  Created by alan craig on 10/15/25.
//
import SwiftUI
import WebKit

struct FacebookPlayerView: UIViewRepresentable {
    /// Public URL to the Facebook video post (e.g., https://www.facebook.com/.../videos/123...)
    let videoURL: String
    var showText: Bool = false   // show the post text above the player?
    var width: Int = 720         // Facebook uses pixel sizes in the URL
    var height: Int = 405        // 16:9 default
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        // Allow autoplay without user gesture (iOS 16+)
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let encodedHref = videoURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let showTextFlag = showText ? "1" : "0"
        let embed = "https://www.facebook.com/plugins/video.php?href=\(encodedHref)&show_text=\(showTextFlag)&width=\(width)&height=\(height)&autoplay=0&allowfullscreen=true"
        if let url = URL(string: embed) {
            uiView.load(URLRequest(url: url))
        }
    }
}
