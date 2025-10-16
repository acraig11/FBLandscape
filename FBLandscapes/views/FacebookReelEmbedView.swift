//
//  FacebookReelEmbedView.swift
//  FBLandscapes
//
//  Created by alan craig on 10/15/25.
//


import SwiftUI
import WebKit

struct FacebookReelEmbedView: UIViewRepresentable {
    let iframeHTML: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        if #available(iOS 16.4, *) {
            config.mediaTypesRequiringUserActionForPlayback = []
        }

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Wrap the iframe in basic HTML to make sure it scales correctly
        let html = """
        <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
              body {
                margin: 0;
                padding: 0;
                background-color: transparent;
              }
              iframe {
                border: none;
                width: 100%;
                height: 100%;
              }
            </style>
          </head>
          <body>
            \(iframeHTML)
          </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}
