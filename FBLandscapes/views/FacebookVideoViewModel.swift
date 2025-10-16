//
//  FacebookVideoViewModel.swift
//  FBLandscapes
//
//  Created by alan craig on 10/15/25.
//import Foundation
import Foundation

final class FacebookVideoViewModel: ObservableObject {
    @Published var videoURL: String? = nil
    
    func fetchVideoURL() {
        // TODO: Replace with your fetch (GitHub raw, Firebase, your API, etc.)
        // Must be a PUBLIC Facebook video post URL.
        // Example structure (replace with your own):
        self.videoURL = "https://www.facebook.com/flaglerbeach.landscapes/videos/1121400856816829"
    }
}

