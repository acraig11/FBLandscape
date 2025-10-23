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
                VStack(spacing: 0) {
                    TitleBar()
                        .padding(.bottom,5)
                    VStack(alignment: .center, spacing: 1) {
                    Text("Hard at work")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        // Facebook Video
                        if let html = fbViewModel.iframeHTML {
                            FacebookReelEmbedView(iframeHTML: html)
                                .frame(width: 276, height: 476)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(radius: 4)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Text("Loading Facebook Reel…")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 20)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
                .padding(.top, 12)
                .frame(maxWidth: .infinity)
            }
            // ✅ Pinned navigation button in toolbar (works properly)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink(destination: BookingView()) {
                        Text("Book a Landscaping Service")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .onAppear {
                viewModel.fetchVideoID()
                viewModel3.fetchVideoID()
                fbViewModel.fetchIframeHTML()
            }
        }
    }
}

