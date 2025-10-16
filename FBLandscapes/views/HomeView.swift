import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = VideoViewModel()
    @StateObject private var viewModel2 = InstagramViewModel()
    @StateObject private var viewModel3 = VideoViewModel2()
    @StateObject private var fbViewModel = FacebookVideoViewModel()   // NEW
   
    private let readableMax: CGFloat = 820
    private let reelIframe = """
       <iframe src="https://www.facebook.com/plugins/video.php?height=476&href=https%3A%2F%2Fwww.facebook.com%2Freel%2F1347333760347076%2F&show_text=false&width=267&t=0"
           width="267" height="476"
           style="border:none;overflow:hidden"
           scrolling="no"
           frameborder="0"
           allowfullscreen="true"
           allow="autoplay; clipboard-write; encrypted-media; picture-in-picture; web-share">
       </iframe>
       """
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
                        }
                     

                        // Video 2 (YouTube)
                        if let id = viewModel3.videoID {
                            YouTubePlayerView(videoID: id)
                                .aspectRatio(16.0/9.0, contentMode: .fit)
                                .frame(maxWidth: readableMax)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Loading Video 2…")
                                .frame(maxWidth: readableMax)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        }
                         */
                        // Facebook Video (NEW)
                        if let fbURL = fbViewModel.videoURL {
                            FacebookPlayerView(videoURL: fbURL)
                                .aspectRatio(16.0/9.0, contentMode: .fit)
                                .frame(maxWidth: readableMax)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Loading Facebook Video1…")
                                .frame(maxWidth: readableMax)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        }
                       
                        FacebookReelEmbedView(iframeHTML: reelIframe)
                                  .frame(width: 267, height: 476)
                                  .clipShape(RoundedRectangle(cornerRadius: 16))
                                  .shadow(radius: 4)
                                  .padding()
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
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 12)
                .frame(maxWidth: .infinity)
            }
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
                fbViewModel.fetchVideoURL()   // NEW
            }
        }
    }

