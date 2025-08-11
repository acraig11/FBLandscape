//
//  VacationBookingCalendarView.swift
//  Coast Life
//
//  Created by alan craig on 8/6/25.
//


import SwiftUI
import MessageUI

struct VacationBookingCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var showConfirmation: Bool

    @State private var showMailComposer = false
    @State private var showMailErrorAlert = false
    @Environment(\.dismiss) private var dismiss   // ✅ Ad
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
                HStack {
                    Image("home") // Ensure "boat" exists in your asset catalog
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    Image("boat") // Ensure "boat" exists in your asset catalog
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(12)
                    .padding(.horizontal)}

                DatePicker(
                    "Select a date for your vacation",
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
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Book a Vacation Experience")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showMailComposer) {
            MailView(
                subject: "Vacation Booking Confirmation",
                body: "✅ Your vacation (boat + home) is booked for \(formattedDate).\nThank you for choosing Coast Life!",
                recipients: ["coastlifellc@gmail.com"]
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
