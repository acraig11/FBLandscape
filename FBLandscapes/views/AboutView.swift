import SwiftUI
import SafariServices



struct AboutView: View {
    @State private var showForm = false
    @State private var showForm2 = false
    // In-app browser state
    @State private var showSafari = false
    @State private var safariURL: URL?

    private let links: [(title: String, url: String, symbol: String)] = [
        ("Instagram", "https://instagram.com/coastlifellc", "camera"),
        ("Facebook", "https://www.facebook.com/share/1J7PS9GhRr/?mibextid=wwXIfr", "f.cursive.circle"),
        ("YouTube",   "http://youtube.com/@thecoastlife", "play.rectangle"),
        ("LinkedIn",  "https://www.linkedin.com/company/coast-life", "link.circle"),
        ("X",         "https://x.com/coastlifellc", "xmark.circle") // neutral fallback
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                TitleBar()

                Spacer(minLength: 40)
                // Headline + blurb
                Text("Landscapes & More")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer(minLength: 20)
                Text("Enjoy Professional and courteous service with a smile. We offer a robust quantity of landscaping services to fit all needs.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Text("Flagler Beach Lanscapes & Tree Services LLC.")
                Text("Don or Megan 386-365-4031.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer(minLength: 40)
                // Social links (now buttons -> in-app Safari)
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        ForEach(links, id: \.title) { item in
                            Button {
                                if let url = URL(string: item.url) {
                                    safariURL = url
                                    showSafari = true
                                }
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: item.symbol)
                                        .font(.system(size: 28, weight: .regular))
                                    Text(item.title)
                                        .font(.caption2)
                                }
                                .frame(minWidth: 44, minHeight: 44)   // tighter but still accessible
                                .contentShape(Rectangle())
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(Text(item.title))
                            }
                            .buttonStyle(.plain)
                        }

                        // Inline "Art & Toys" button that opens the sheet

                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 4)

                
               
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
        // Sheets
      
        .sheet(isPresented: $showSafari) {
            if let url = safariURL { SafariView(url: url).ignoresSafeArea() }
        }
    }
}

#Preview { AboutView() }

