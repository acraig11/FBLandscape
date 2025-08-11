import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = VideoViewModel()
    @StateObject private var viewModel2 = InstagramViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TitleBar()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Entertainment Videos")
                        .font(.headline)
                        .padding(.leading)

                    if let url1 = viewModel.videoID {
                        YouTubePlayerView(videoID: url1)
                            .frame(height: 200)
                    }

                    if let url = viewModel2.postURL {
                        InstagramWebView(urlString: url)
                            .frame(height: 300)
                    } else {
                        Text("Loading Instagram post...")
                    }
                }

             
                
                // ✅ Navigation button to BookingView at the bottom
                NavigationLink(destination: BookingView()) {
                    Text("Book an Experience")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .onAppear {
                viewModel.fetchVideoID()
                
                viewModel2.fetchPostURL()
            }
        }
    }
}

