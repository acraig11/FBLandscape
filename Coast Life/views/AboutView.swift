//
//  AboutView.swift
//  CoastLifeApp
//
//  Created by alan craig on 7/28/25.
//



import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            TitleBar()

            Spacer()

            Text("COAST LIFE™️ Entertainment Experiences")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Putting Families, Friends, and Executives on the water! Enjoy live events, vacations, and recreational activities through our Apple iOS app or on our social media channels.")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
            
            // Social Media Links
            VStack(spacing: 10) {
                Text("Follow us:")
                    .font(.headline)

                HStack(spacing: 30) {
                    Link(destination: URL(string: "https://instagram.com/coastlifellc")!) {
                        Image(systemName: "camera")
                            .font(.title)
                    }

                    Link(destination: URL(string: "https://www.facebook.com/share/1J7PS9GhRr/?mibextid=wwXIfr")!) {
                        Image(systemName: "f.circle")
                            .font(.title)
                    }

                    Link(destination: URL(string: "http://youtube.com/@thecoastlife")!) {
                        Image(systemName: "play.rectangle")
                            .font(.title)
                    }
                    Link(destination: URL(string: "https://www.linkedin.com/company/coast-life")!) {
                        Image(systemName: "link.circle") // Placeholder icon
                            .font(.title)
                    }

                    Link(destination: URL(string: "https://x.com/coastlifellc")!) {
                        Image(systemName: "x.circle") // SF Symbol (generic "X")
                            .font(.title)
                    }
                    

                }
            }

            Spacer()
        }
    }
}

#Preview {
    AboutView()
}

