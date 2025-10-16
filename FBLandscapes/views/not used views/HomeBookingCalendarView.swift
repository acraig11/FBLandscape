//
//  HomeBookingCalendarView.swift
//  Coast Life
//
//  Created by alan craig on 8/6/25.
//


import SwiftUI
import MessageUI

struct HomeBookingCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var showConfirmation: Bool
    @Environment(\.dismiss) private var dismiss   // 
    @State private var showMailComposer = false
    @State private var showMailErrorAlert = false
   
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                
                Image("home") // Ensure "boat" exists in your asset catalog
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(12)
                    .padding(.horizontal)

                Text("Select a date for your home rental")
                    .font(.headline)
                    .padding(.top)
                DatePicker(
                    "Select a date",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

                Button("Confirm Booking for \(formattedDate)") {
                    showConfirmation = true
                    if MFMailComposeViewController.canSendMail() {
                        showMailComposer = true
                    } else {
                        showMailErrorAlert = true
                    }
                }
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Book a Home")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showMailComposer) {
            MailView(
                subject: "Home Booking Confirmation",
                body: "✅ Your home has been booked for \(formattedDate).\nThank you for choosing Coast Life!",
                recipients: ["coastlifellc@gmail.com"],
              
            )
        }
        .alert("Email Not Available", isPresented: $showMailErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please configure an email account in the Mail app to send booking confirmations.")
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: selectedDate)
    }
}
