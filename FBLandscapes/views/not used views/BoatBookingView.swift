//
//  BoatBookingView.swift
//  Coast Life
//
//  Created by alan craig on 8/6/25.
//

import SwiftUI

struct BoatBookingView: View {
    @State private var showDatePicker = false
    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: 20) {
            Text("Boat Rental Booking")
                .font(.title)
                .bold()

            Button(action: {
                showDatePicker.toggle()
            }) {
                Text("Book a Boat")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            if showDatePicker {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

                Button(action: {
                    confirmBooking()
                }) {
                    Text("Confirm Booking for \(formattedDate)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: selectedDate)
    }

    private func confirmBooking() {
        // You could integrate with your backend or booking system here
        print("📅 Boat booked for \(formattedDate)")
    }
}



#Preview {
    BoatBookingView()
}
