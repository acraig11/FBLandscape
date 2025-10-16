import SwiftUI

struct BookingCalendarSheet: View {
    @Binding var selectedDates: Set<Date>
    @Binding var location: String
    @Binding var name: String
    @Binding var phoneNumber: String
    var selectedItems: [String]
    var onConfirm: () -> Void
    var onCancel: () -> Void

    @State private var visibleMonth: Date = Date()
    private enum FocusField { case name, phone }
    @FocusState private var focusedField: FocusField?

    // Force Gregorian calendar and English locale
    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US_POSIX")
        cal.firstWeekday = 1 // Sunday = 1
        return cal
    }()

    private let weekdayHeaders = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    private var startOfMonth: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: visibleMonth))!
    }

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let offset = firstWeekday - calendar.firstWeekday

        var days: [Date?] = []
        for _ in 0..<(offset < 0 ? offset + 7 : offset) { days.append(nil) }

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {

                // Name & Phone
                HStack {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                        .submitLabel(.next)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .focused($focusedField, equals: .name)

                    TextField("Phone#", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .submitLabel(.done)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .focused($focusedField, equals: .phone)


                    Spacer(minLength: 40)
                }

                if !selectedItems.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("You are booking:")
                            .font(.subheadline)
                        ForEach(selectedItems, id: \.self) { item in
                            Text("• \(item)")
                            Text("location: \(location)")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Divider()

                // Show calendar only when name & phone are filled (trimmed)
                if !(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                      phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {

                    // Month navigation
                    HStack {
                        Button(action: { changeMonth(by: -1) }) {
                            Image(systemName: "chevron.left").padding(4)
                        }
                        Spacer()
                        Text(formattedMonth(startOfMonth))
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: { changeMonth(by: 1) }) {
                            Image(systemName: "chevron.right").padding(4)
                        }
                    }
                    .padding(.horizontal)

                    // Weekday headers
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                        ForEach(weekdayHeaders, id: \.self) { symbol in
                            Text(symbol)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    // Calendar grid
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                                if let date = date {
                                    let isSelected = selectedDates.contains { calendar.isDate($0, inSameDayAs: date) }
                                    Button(action: { toggleDate(date) }) {
                                        Text("\(calendar.component(.day, from: date))")
                                            .frame(width: 35, height: 35)
                                            .background(Circle().fill(isSelected ? Color.blue : Color.clear))
                                            .overlay(Circle().stroke(Color.gray.opacity(isSelected ? 0 : 0.3), lineWidth: 1))
                                            .foregroundColor(isSelected ? .white : .primary)
                                    }
                                } else {
                                    Color.clear.frame(minHeight: 35)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }

                    if !selectedDates.isEmpty {
                        Divider()
                        Text("Selected Dates:")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)

                        ForEach(selectedDates.sorted(), id: \.self) { date in
                            HStack {
                                Text(formattedDate(date))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Button(action: { selectedDates.remove(date) }) {
                                    Image(systemName: "trash").foregroundColor(.red)
                                }
                            }
                        }
                    }

                } else {
                    // Placeholder while fields are incomplete
                    VStack(spacing: 8) {
                        Text("Enter your name and phone number to pick dates.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                Spacer()

                // Confirm button with inline gating (no extra vars)
                Button("Confirm Request") {
                    onConfirm()
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    (!selectedDates.isEmpty &&
                     !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                     !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        ? Color.blue
                        : Color.gray.opacity(0.4)
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(
                    selectedDates.isEmpty ||
                    name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
                .opacity(
                    (!selectedDates.isEmpty &&
                     !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                     !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        ? 1 : 0.6
                )
            }
            .contentShape(Rectangle())                // make the whole area tappable
            .onTapGesture { focusedField = nil }      // 👈 dismiss keyboard on background tap

            
            .padding()
            .navigationTitle("Booking Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func toggleDate(_ date: Date) {
        if let existing = selectedDates.first(where: { calendar.isDate($0, inSameDayAs: date) }) {
            selectedDates.remove(existing)
        } else {
            selectedDates.insert(date)
        }
    }

    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: visibleMonth) {
            visibleMonth = newMonth
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

