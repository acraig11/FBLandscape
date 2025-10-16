import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = VideoViewModel()
    @StateObject private var viewModel2 = InstagramViewModel()
    @StateObject private var viewModel3 = VideoViewModel2()
    @StateObject private var fbViewModel = FacebookVideoViewModel()   // NEW
    
    private let readableMax: CGFloat = 820
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    TitleBar()
                    
                    VStack(alignment: .center, spacing: 12) {
                        Text("Hard at work")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        // Video 1 (YouTube)
                    /*   if let id = viewModel.videoID {
                            YouTubePlayerView(videoID: id)
                                .aspectRatio(16.0/9.0, contentMode: .fit)
                                .frame(maxWidth: readableMax)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Loading Video 1…")
                                .frame(maxWidth: readableMax)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        } */
                        if let html = fbViewModel.iframeHTML {
                            FacebookReelEmbedView(iframeHTML: html)
                                .frame(width: 276, height: 476)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(radius: 4)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)   // ← center the webview
                        } else {
                            Text("Loading Facebook Reel…")
                                .frame(maxWidth: .infinity, alignment: .center)   // ← center the placeholder
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 20)
                        }
                    }
                    .frame(maxWidth: .infinity)   // ← ensure the container spans full width
                    .padding(.horizontal)

                        // -----------------------------------------------
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 12)
                .frame(maxWidth: .infinity)
            }
            
            
            // Instagram (kept commented)
            /*
             if let url = viewModel2.postURL {
             InstagramWebView(urlString: url)
             .frame(maxWidth: readableMax)
             .frame(maxWidth: .infinity)
             .aspectRatio(1.0, contentMode: .fit)
             .fixedSize(horizontal: false, vertical: true)
             } else {
             Text("Loading Instagram post…")
             }
             */
            
            .safeAreaInset(edge: .bottom) {
                NavigationLink(destination: BookingView()) {
                    Text("Book a Landscaping Service")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                .background(Color(.systemBackground))
            }
            .onAppear {
                viewModel.fetchVideoID()
                viewModel3.fetchVideoID()
                // viewModel2.fetchPostURL()
                fbViewModel.fetchIframeHTML()   // NEW
            }
        }
    }
    

