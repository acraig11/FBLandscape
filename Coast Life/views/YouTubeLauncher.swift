//
//  YouTubeLauncher.swift
//  CoastLifeApp
//
//  Created by alan craig on 7/28/25.
//
import SwiftUI
import SafariServices

struct YouTubeLauncher: View {
    let videoID: String
    @State private var showSafari = false

    var body: some View {
        Button(action: {
            showSafari = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.9))
                    .frame(height: 200)
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $showSafari) {
            SafariView(url: URL(string: "https://www.youtube.com/watch?v=\(videoID)")!)
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}
