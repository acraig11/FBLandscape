//
//  art_and_toys.swift
//  Coast Life
//
//  Created by alan craig on 9/1/25.
//

import SwiftUI

struct art_and_toys: View {
    @State private var showForm = false
    @Environment(\.dismiss) private var dismiss   // for Back button

    var body: some View {
        VStack( spacing: 12) {
            // Inline Back button (works whether presented in a sheet or pushed)
            TitleBar()
            Spacer(minLength: 40)
            
            VStack(alignment: .leading, spacing: 12) {
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
                Label("ART Work by World Renowned artist Barbara Klein Craig", systemImage: "paintpalette")
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
                .padding(.top, 4)
            }}
        .sheet(isPresented: $showForm) { MerchandiseFormView() }
        Spacer(minLength: 40)
    }
}

#Preview {
    art_and_toys()
}

