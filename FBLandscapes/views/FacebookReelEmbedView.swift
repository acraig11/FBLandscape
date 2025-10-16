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
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let wrapped = """
        <!doctype html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            html,body { margin:0; padding:0; background:transparent; }
            .container { display:flex; justify-content:center; }
            .container iframe { width:100%; max-width:100%; display:block; }
          </style>
        </head>
        <body>
          <div class="container">
            \(iframeHTML)
          </div>
        </body>
        </html>
        """
        uiView.loadHTMLString(wrapped, baseURL: nil)
    }
}
