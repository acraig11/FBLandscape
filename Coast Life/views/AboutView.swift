import SwiftUI
import SafariServices



struct AboutView: View {
    @State private var showForm = false

    // In-app browser state
    @State private var showSafari = false
    @State private var safariURL: URL?

    private let links: [(title: String, url: String, symbol: String)] = [
        ("Instagram", "https://instagram.com/coastlifellc", "camera"),
        ("Facebook",  "https://www.facebook.com/share/1J7PS9GhRr/?mibextid=wwXIfr", "globe"),
        ("YouTube",   "http://youtube.com/@thecoastlife", "play.rectangle"),
        ("LinkedIn",  "https://www.linkedin.com/company/coast-life", "link.circle"),
        ("X",         "https://x.com/coastlifellc", "xmark.circle") // neutral fallback
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                TitleBar()

                // Social links (now buttons -> in-app Safari)
                VStack(spacing: 8) {
                    Text("Follow us:")
                        .font(.headline)

                    HStack(spacing: 24) {
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
                                .frame(minWidth: 56, minHeight: 56)
                                .contentShape(Rectangle())
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(Text(item.title))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.top, 4)

                // Headline + blurb
                Text("COAST LIFE™️ Entertainment Experiences")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("Putting Families, Friends, and Executives on the water! Enjoy live events, vacations, and recreational activities through our Apple iOS app or on our social media channels.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Art & Toys
                VStack(alignment: .leading, spacing: 12) {
                    Text("Art & Toys")
                        .font(.title)
                        .bold()
                        .padding(.top)

                    Label("ART Work by World Renowned artist Barbara Craig", systemImage: "paintpalette")
                    Label("Custom 3D printed items and toys", systemImage: "cube.transparent")

                    HStack(spacing: 12) {
                        Image("artwork1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(12)

                        Image("artwork2")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)

                    Button {
                        showForm = true
                    } label: {
                        Text("Request Art & Toys")
                            .font(.body)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
        // Sheets
        .sheet(isPresented: $showForm) { MerchandiseFormView() }
        .sheet(isPresented: $showSafari) {
            if let url = safariURL { SafariView(url: url).ignoresSafeArea() }
        }
    }
}

#Preview { AboutView() }

