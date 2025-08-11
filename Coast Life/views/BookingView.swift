import SwiftUI
import MessageUI

import SwiftUI
import MessageUI

import SwiftUI
import MessageUI

import SwiftUI
import MessageUI

struct BookingView: View {
    @State private var selectedDates: Set<Date> = []
    @State private var showCalendarSheet = false
    @State private var showMailView = false

    @State private var selections: [String: Bool] = [
        "Home": false, "Boat": false, "Golf": false,
        "Fishing": false, "Tennis": false, "Swimming": false,
        "Skiing": false, "Hiking": false, "Biking": false,
        "Surfing": false, "Pickle Ball": false, "Beach": false
    ]

    @State private var confirmedItems: [String] = []
    @State private var itemsToConfirm: [String] = []
    @State private var emailBody = ""
    @State private var lastMailResult: MFMailComposeResult? = nil

    @State private var name = ""
    @State private var phoneNumber = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                TitleBar()

                VStack(spacing: 16) {
                    Image(systemName: "airplane")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .foregroundColor(.blue)

                    Text("Vacation Experiences")
                        .font(.title)
                        .bold()

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(selections.keys.sorted(), id: \.self) { key in
                            Toggle(isOn: Binding(
                                get: { selections[key] ?? false },
                                set: { selections[key] = $0 }
                            )) {
                                Text(key)
                            }
                        }
                    }
                    .toggleStyle(CustomCheckboxToggleStyle())
                    .padding(.horizontal)

                    Divider().padding(.vertical)

                    // 🧍 Name Input
                    TextField("Your Name", text: $name)
                        .autocapitalization(.words)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    // 📱 Phone Input
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    // 🚀 Book Button
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        if selections.values.contains(true) && !phoneNumber.isEmpty && !name.isEmpty {
                            showCalendarSheet = true
                        }
                    }) {
                        Text("Book Selected Items")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                (selections.values.contains(true) && !phoneNumber.isEmpty && !name.isEmpty)
                                ? Color.blue : Color.gray
                            )
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(!selections.values.contains(true) || phoneNumber.isEmpty || name.isEmpty)

                    ForEach(confirmedItems, id: \.self) { item in
                        Text("✅ \(item) booking requested for \(selectedDates.map { formattedDate($0) }.joined(separator: ", "))")
                            .font(.footnote)
                            .foregroundColor(.green)
                    }
                }

                Spacer(minLength: 40)
            }
            .padding()
        }
        .sheet(isPresented: $showCalendarSheet) {
            BookingCalendarSheet(
                selectedDates: $selectedDates,
                selectedItems: selections.filter { $0.value }.map { $0.key },
                onConfirm: handleBooking,
                onCancel: handleCalendarCancel
            )
        }
        .sheet(isPresented: $showMailView, onDismiss: handleMailDismiss) {
            MailView(
                subject: "Booking Request",
                body: emailBody,
                recipients: ["coastlifellc@gmail.com"],
                resultHandler: handleMailResult
            )
        }
    }

    private func handleBooking() {
        itemsToConfirm = selections.filter { $0.value }.map { $0.key }
        itemsToConfirm.forEach { selections[$0] = false }

        emailBody = """
        Booking Request:

        Name: \(name)
        Phone Number: \(phoneNumber)

        Items:
        \(itemsToConfirm.map { "• \($0)" }.joined(separator: "\n"))

        Dates:
        \(selectedDates.sorted().map { formattedDate($0) }.joined(separator: "\n"))
        """

        showCalendarSheet = false
        showMailView = true
    }

    private func handleCalendarCancel() {
        selections = selections.mapValues { _ in false }
        selectedDates.removeAll()
        showCalendarSheet = false
    }

    private func handleMailResult(_ result: MFMailComposeResult) {
        lastMailResult = result
    }

    private func handleMailDismiss() {
        if lastMailResult == .sent {
            confirmedItems.append(contentsOf: itemsToConfirm)
        }

        itemsToConfirm.removeAll()
        selectedDates.removeAll()
        phoneNumber = ""
        name = ""
        lastMailResult = nil
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}







struct CustomCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                configuration.label
                Spacer()
            }
            .padding(8)
        }
        .buttonStyle(.plain)
    }
}

