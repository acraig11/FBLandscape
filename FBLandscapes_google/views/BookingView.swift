import SwiftUI
import MessageUI

// MARK: - BookingView (no golf overlays/animations)
struct BookingView: View {
    @State private var selectedDates: Set<Date> = []
    @State private var showCalendarSheet = false
    @State private var showMailView = false
   
    @State private var selections: [String: Bool] = [
        "Lawn Care & Maint.": false,
        "Landscape Design": false,
        "Landscape Installation": false,
        "Tree Trimming": false,
        "Yard Cleanup": false,
        "Grading": false,
        "Erosion Control": false,
        "Fence Installation": false,
        "Outdoor Living": false,
        "Water Features": false,
        "Hard Scaping": false,
        "Mulching & Soil": false
    ]

    @State private var confirmedItems: [String] = []
    @State private var itemsToConfirm: [String] = []
    @State private var emailBody = ""
    @State private var lastMailResult: MFMailComposeResult? = nil

    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var location = ""
    @State private var attachedImages: [UIImage] = []
    private var selectedIDs: [String] {
        selections.filter { $0.value }.map { $0.key }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 10) {
                    TitleBar()

                    VStack(spacing: 16) {
                        Text("Landscaping Services")
                            .font(.title).bold()

                        // Selections grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(selections.keys.sorted(), id: \.self) { key in
                                SelectToggleRow(
                                    title: key,
                                    isOn: Binding(
                                        get: { selections[key] ?? false },
                                        set: { selections[key] = $0 }
                                    )
                                )
                            }
                        }
                        .padding(.horizontal)

                        Divider().padding(.vertical)

                        // Location input
                        Text("Input Location")
                            .font(.headline)
                        TextField("Location", text: $location)
                            .autocapitalization(.words)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .padding(.horizontal)

                        // Book button
                        Button(action: {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                            to: nil, from: nil, for: nil)
                            if selections.values.contains(true)  {
                                showCalendarSheet = true
                            }
                        }) {
                            Text("Request Selected Services")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    (selections.values.contains(true) && !location.isEmpty)
                                    ? Color.blue : Color.gray
                                )
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .disabled(!selections.values.contains(true))

                        // Confirmed items feedback
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
        }
        .sheet(isPresented: $showCalendarSheet) {
            GoogleCalendarSheet(
                selectedDates: $selectedDates,
                location: $location,
                name: $name,
                phoneNumber: $phoneNumber,
                attachedImages: $attachedImages,
                selectedItems: selections.filter { $0.value }.map { $0.key },
                onConfirm: handleBooking,
                onCancel: handleCalendarCancel
            )
        }
        .sheet(isPresented: $showMailView) {
            MailView(
                subject: "Booking Request from \(name)",
                body: """
                      Name: \(name)
                      Phone: \(phoneNumber)
                      Location: \(location)
                      Dates:
                      \(selectedDates.sorted().map {
                          DateFormatter.localizedString(from: $0, dateStyle: .long, timeStyle: .none)
                      }.joined(separator: "\n"))
                      """,
                recipients: ["bookings@coastlife.example"],
                images: attachedImages,                  // 👈 make sure this is non-empty
                resultHandler: { result in
                    print("Mail result:", result.rawValue)
                }
            )
        }
    }

    // MARK: - Actions
    private func handleBooking() {
        itemsToConfirm = selections.filter { $0.value }.map { $0.key }
        itemsToConfirm.forEach { selections[$0] = false }

        emailBody = """
        Booking Request:
        Location Requested: \(location)
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
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: date)
    }
}

// MARK: - Simple selectable row (no golf targets)
private struct SelectToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Button(action: { isOn.toggle() }) {
            HStack {
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                Text(title)
                Spacer()
            }
            .padding(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

