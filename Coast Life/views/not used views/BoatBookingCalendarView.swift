import SwiftUI

struct BoatBookingCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var showConfirmation: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                }
            }

            // ✅ Add a boat image here
            Image("boat") // Ensure "boat" exists in your asset catalog
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .cornerRadius(12)
                .padding(.horizontal)

            Text("Select a date for your boat rental")
                .font(.headline)
                .padding(.top)

            DatePicker("Select a date", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .padding()

            Button("Confirm Booking") {
                showConfirmation = true
                dismiss()
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .padding()
    }
}

