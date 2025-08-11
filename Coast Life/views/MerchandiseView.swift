import SwiftUI

struct MerchandiseView: View {
    @State private var showForm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TitleBar()
                
                Text("Art & Toys")
                    .font(.title)
                    .bold()
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("• ART Work by World Renowned artist Barbara Craig")
                    Text("• Custom 3D printed items and toys")
                    Text("For more information or to request one of these items, tap the button below:")
                    
                    Button(action: {
                        showForm = true
                    }) {
                        Text("Request Merchandise")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .font(.title3)
                .padding(.horizontal, 24)
                
                HStack(spacing: 12) {
                    VStack(spacing: 12) {
                        Image("artwork1")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .frame(height: 150)
                        
                        Image("artwork2")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .frame(height: 150)
                    }
                    
                    VStack(spacing: 12) {
                        Image("3dboat")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .frame(height: 150)
                        
                        Spacer(minLength: 150)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 20)
            }
            .padding(.top)
            .padding(.bottom, 60)
        }
        .sheet(isPresented: $showForm) {
            MerchandiseFormView()
        }
    }
}

