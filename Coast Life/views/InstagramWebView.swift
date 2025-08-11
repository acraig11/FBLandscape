//
//  InstagramWebView.swift
//  Coast Life
//
//  Created by alan craig on 7/30/25.
//
import SwiftUI
import WebKit

struct InstagramWebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            uiView.load(URLRequest(url: url))
        }
    }
}
