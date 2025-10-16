import SwiftUI

struct PartnerView: View {
    @State private var showForm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TitleBar()
                Text("Join The Coast Life Brand")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                VStack(spacing: 16) {
                    Text("""
                    Coast Life offers management, branding, recreational operations, and entertainment facility partnerships!

                    Typical opportunities include experiences on or near the water(but are not limited to):

                    • Hotels  
                    • Resorts  
                    • Theme Parks  
                    • Golf Courses  
                    • Marinas  
                    • Hunting Lodges  
                    • Gaming Establishments  
                    • Concert Arenas  
                    • Sports Arenas  
                    • Sports Teams
                    """)
                    .font(.body)
                    .padding(.horizontal)

                    Button(action: {
                        showForm = true
                    }) {
                        Text("Request Partner & Licensing Info")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .sheet(isPresented: $showForm) {
            PartnerRequestFormView()
        }
    }
}

#Preview {
    PartnerView()
}

