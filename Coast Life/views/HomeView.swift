import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = VideoViewModel()
    @StateObject private var viewModel2 = InstagramViewModel()

    // A "readable" max width so videos don't go ultra-wide on iPad
    private let readableMax: CGFloat = 820

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    TitleBar()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Entertainment Content")
                            .font(.title)

                        // YouTube — keep 16:9 and expand to available width up to readableMax
                        if let id = viewModel.videoID {
                            YouTubePlayerView(videoID: id)
                                .aspectRatio(16.0/9.0, contentMode: .fit)
                                .frame(maxWidth: readableMax)     // prevent over-wide iPad
                                .frame(maxWidth: .infinity)       // center within column
                        }

                        // Instagram — many posts are 1:1 or 4:5; use a flexible box
                        if let url = viewModel2.postURL {
                            InstagramWebView(urlString: url)
                                .frame(maxWidth: readableMax)
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1.0, contentMode: .fit) // start square…
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text("Loading Instagram post…")
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 12)
                .frame(maxWidth: .infinity)
            }
            // Pin the button safely above the home indicator
            .safeAreaInset(edge: .bottom) {
                NavigationLink(destination: BookingView()) {
                    Text("Book an Experience")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                .background(.ultraThinMaterial) // avoids overlapping content
            }
            .onAppear {
                viewModel.fetchVideoID()
                viewModel2.fetchPostURL()
            }
        }
    }
}

