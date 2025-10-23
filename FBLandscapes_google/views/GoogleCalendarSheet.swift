import SwiftUI
import PhotosUI
import UIKit

struct GoogleCalendarSheet: View {
    @Binding var selectedDates: Set<Date>
    @Binding var location: String
    @Binding var name: String
    @Binding var phoneNumber: String
    @Binding var attachedImages: [UIImage]

    let selectedItems: [String]
    let onConfirm: () -> Void
    let onCancel: () -> Void

    @State private var visibleMonth: Date = Date()
    @State private var eventsByDay: [Date: [GCalEvent]] = [:]
    @State private var isLoading = false
    @State private var loadError: String?

    // Photos picker state
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var isLoadingPhotos = false

    // Fixed Gregorian, Sunday-start, device tz
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        cal.locale = Locale(identifier: "en_US_POSIX")
        cal.firstWeekday = 1 // Sunday
        return cal
    }

    // Today (start of day) used for "no past dates" rule
    private var today: Date { stripTime(Date()) }

    private var startOfMonth: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: visibleMonth))!
    }
    private var endOfMonth: Date {
        calendar.date(byAdding: DateComponents(month: 1), to: startOfMonth)!
    }
    private var daysGrid: [Date?] {
        var cells: [Date?] = []
        let weekdayOfFirst = calendar.component(.weekday, from: startOfMonth) // 1..7
        let leadingEmpty = (weekdayOfFirst - calendar.firstWeekday + 7) % 7
        cells.append(contentsOf: Array(repeating: nil, count: leadingEmpty))
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        for d in range {
            if let date = calendar.date(byAdding: .day, value: d - 1, to: startOfMonth) {
                cells.append(date)
            }
        }
        return cells
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                // Month header
                HStack {
                    Button { visibleMonth = calendar.date(byAdding: .month, value: -1, to: visibleMonth)! } label: {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text(monthYearString(visibleMonth)).font(.title2).bold()
                    Spacer()
                    Button { visibleMonth = calendar.date(byAdding: .month, value: 1, to: visibleMonth)! } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)

                // Weekday headers
                HStack {
                    ForEach(["Sun","Mon","Tue","Wed","Thu","Fri","Sat"], id: \.self) { w in
                        Text(w).font(.footnote).frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 8)

                // Calendar grid (no past date selection)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                    ForEach(daysGrid.indices, id: \.self) { idx in
                        if let day = daysGrid[idx] {
                            let dayKey = stripTime(day)
                            let isPast = dayKey < today

                            DayCell(
                                date: day,
                                isSelected: selectedDates.contains(dayKey),
                                isInThisMonth: calendar.isDate(day, equalTo: visibleMonth, toGranularity: .month),
                                events: eventsByDay[dayKey] ?? [],
                                isDisabled: isPast
                            )
                            .onTapGesture {
                                guard !isPast else { return } // block taps on past days
                                if selectedDates.contains(dayKey) { selectedDates.remove(dayKey) }
                                else { selectedDates.insert(dayKey) }
                            }
                        } else {
                            Rectangle().opacity(0).frame(height: 44)
                        }
                    }
                }
                .padding(.horizontal, 8)

                if isLoading {
                    ProgressView().padding(.top, 4)
                } else if let e = loadError {
                    VStack(spacing: 6) {
                        Text("Couldn’t load events: \(e)")
                            .foregroundStyle(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                        Button("Retry") { Task { await loadMonth() } }
                            .buttonStyle(.bordered)
                    }
                }

                // Booking details + Photos
                VStack(spacing: 10) {
                    TextField("Your Name", text: $name)
                        .textContentType(.name)
                        .padding(10).background(Color(.secondarySystemBackground)).cornerRadius(8)

                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .padding(10).background(Color(.secondarySystemBackground)).cornerRadius(8)

                    TextField("Location", text: $location)
                        .textInputAutocapitalization(.words)
                        .padding(10).background(Color(.secondarySystemBackground)).cornerRadius(8)

                    // Photos Picker
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            PhotosPicker(
                                selection: $photoItems,
                                maxSelectionCount: 6,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Label(attachedImages.isEmpty ? "Add Photos" : "Add More Photos",
                                      systemImage: "photo.on.rectangle.angled")
                            }
                            .buttonStyle(.bordered)

                            if isLoadingPhotos {
                                ProgressView().padding(.leading, 4)
                            }

                            if !attachedImages.isEmpty {
                                Button(role: .destructive) {
                                    attachedImages.removeAll()
                                } label: {
                                    Label("Clear", systemImage: "trash")
                                }
                                .buttonStyle(.bordered)
                            }
                        }

                        // Thumbnails
                        if !attachedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(attachedImages.indices, id: \.self) { idx in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: attachedImages[idx])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 72, height: 72)
                                                .clipped()
                                                .cornerRadius(10)

                                            Button {
                                                attachedImages.remove(at: idx)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .imageScale(.small)
                                                    .foregroundStyle(.white)
                                                    .shadow(radius: 1)
                                            }
                                            .offset(x: 6, y: -6)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Actions
                HStack {
                    Button("Cancel") { onCancel() }
                        .buttonStyle(.bordered)

                    Spacer()

                    Button("Confirm") {
                        // belt-and-suspenders: drop any past days before confirming
                        selectedDates = selectedDates.filter { $0 >= today }
                        onConfirm()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedDates.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .navigationTitle("Select Dates")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: startOfMonth) {
                await loadMonth()
                // sanitize any past selections whenever month loads/changes
                selectedDates = selectedDates.filter { $0 >= today }
            }
            .onChange(of: photoItems) { _, newItems in
                Task { await loadPickedPhotos(items: newItems) }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Load month events
    private func loadMonth() async {
        isLoading = true; loadError = nil
        do {
            let events = try await GoogleCalendarService.fetchEvents(
                start: startOfMonth,
                end: endOfMonth,
                timeZone: .current,
                retries: 3
            )
            var bucket: [Date: [GCalEvent]] = [:]
            var dayCal = Calendar(identifier: .gregorian)
            dayCal.timeZone = .current
            for ev in events {
                var day = dayCal.startOfDay(for: ev.start)
                while day < ev.end {
                    bucket[day, default: []].append(ev)
                    day = dayCal.date(byAdding: .day, value: 1, to: day)!
                }
            }
            eventsByDay = bucket
        } catch {
            loadError = (error as NSError).localizedDescription
        }
        isLoading = false
    }

    // MARK: - Photos loading (Data-only; SDK-safe)
    @MainActor
    private func loadPickedPhotos(items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        isLoadingPhotos = true
        defer {
            isLoadingPhotos = false
            photoItems.removeAll()
        }

        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let img  = UIImage(data: data) {
                attachedImages.append(img)
                continue
            }
            if let url  = try? await item.loadTransferable(type: URL.self),
               let data = try? Data(contentsOf: url),
               let img  = UIImage(data: data) {
                attachedImages.append(img)
                continue
            }
        }
    }

    // MARK: - Helpers
    private func stripTime(_ d: Date) -> Date { calendar.startOfDay(for: d) }

    private func monthYearString(_ d: Date) -> String {
        let f = DateFormatter()
        f.calendar = calendar
        f.dateFormat = "LLLL yyyy"
        return f.string(from: d)
    }
}

// Day cell with event dots and disabled (past) handling
private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isInThisMonth: Bool
    let events: [GCalEvent]
    let isDisabled: Bool   // NEW

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.callout)
                .fontWeight(isSelected ? .bold : .regular)

            if !events.isEmpty {
                HStack(spacing: 2) {
                    ForEach(Array(events.prefix(3)), id: \.self) { _ in
                        Circle().frame(width: 5, height: 5)
                    }
                    if events.count > 3 {
                        Text("+\(events.count - 3)").font(.system(size: 8))
                    }
                }
                .padding(.bottom, 2)
            }
        }
        .foregroundStyle(isDisabled ? .secondary : (isInThisMonth ? .primary : .secondary))
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected && !isDisabled ? Color.blue : .clear, lineWidth: 2)
        )
        .contentShape(Rectangle())
        .opacity(isDisabled ? 0.35 : 1.0)        // dim past days
        .allowsHitTesting(!isDisabled)           // block taps on past days
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityText))
        .accessibilityHint(isDisabled ? Text("Past date. Unavailable.") : Text(""))
    }

    private var accessibilityText: String {
        let df = DateFormatter(); df.dateStyle = .full
        let base = df.string(from: date)
        if isDisabled { return "\(base). Past date. Unavailable." }
        if events.isEmpty { return base }
        let titles = events.prefix(3).map { $0.summary }.joined(separator: ", ")
        return "\(base). \(events.count) events. \(titles)"
    }
}

