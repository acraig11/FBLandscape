import SwiftUI
import MessageUI

// MARK: - Notifications
private extension Notification.Name {
    static let clubWiggle = Notification.Name("ClubWiggle")
}

// MARK: - Tee / resting-ball positioning constants (shared)
private enum TeeConstants {
    static let size: CGFloat = 22        // tee image/vector height
    static let yOffset: CGFloat = 10     // distance above the target view
}
private enum RestingBallConstants {
    static let size: CGFloat = 24        // static ball on the tee
    static let overlapIntoTee: CGFloat = 0
}
private enum ClubConstants {
    static let size = CGSize(width: 40, height: 40) // club graphic size
    static let rotation: Double = -30                // lean toward the ball from the LEFT
    static let dxFromBall: CGFloat = -RestingBallConstants.size * 1.0 // left of ball
    static let dyFromBall: CGFloat = 6
}
private enum TargetConstants {
    static let labelRightPadding: CGFloat = 20
    static let rightScreenMargin: CGFloat = 12
}

// MARK: - Motion + Debug (slow-mo for inspection)
private enum Motion {
    static let slowMo: Bool = true
    static let pauseAtStart: Double = slowMo ? 0.35 : 0.0
    static let phase1Duration: Double = slowMo ? 1.00 : 0.35
    static let phase2DelayAfterPhase1: Double = slowMo ? 0.20 : 0.00
    static let phase2Duration: Double = slowMo ? 1.10 : 0.45
}
// MARK: - Club wiggle settings
private enum Wiggle {
    static let amplitude: Double = 8                    // degrees left/right from base
    static let cycles: Int = 2                          // number of left-right pairs
    static let stepDuration: Double = Motion.slowMo ? 0.25 : 0.10
    static var totalDuration: Double { Double(cycles * 2) * stepDuration }
}

private enum Debug {
    static let showOriginMarker: Bool = true
    static let showLabelFrames: Bool = true   // draw green boxes for label anchors
}

// MARK: - BookingView
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

    private var selectedIDs: [String] {
        selections.filter { $0.value }.map { $0.key }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 10) {
                    TitleBar()

                    VStack(spacing: 16) {
                        Text("Vacation Entertainment")
                            .font(.title).bold()

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

                        // 🧍 Name Input — (no longer the tee anchor)
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
                        Spacer(minLength: 40)
                        // BOOK BUTTON — now the anchor for tee/ball/club
                        Button(action: {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                            to: nil, from: nil, for: nil)
                            if selections.values.contains(true) && !phoneNumber.isEmpty && !name.isEmpty {
                                showCalendarSheet = true
                            }
                        }) {
                            Text("Book Selected Experiences")
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
                        .golfPuttTarget(id: "BookButton") // CHANGED: add tee anchor here ✅

                        ForEach(confirmedItems, id: \.self) { item in
                            Text("✅ \(item) booking requested for \(selectedDates.map { formattedDate($0) }.joined(separator: ", "))")
                                .font(.footnote)
                                .foregroundColor(.green)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding()

                // Balls/tee overlay attached to the SCROLLING VStack
                .overlayPreferenceValue(GolfPuttTargetKey.self) { anchors in
                    GeometryReader { proxy in
                        ZStack {
                            // ⛳️ Static tee + resting ball + club (with wiggle)
                            TeeMarkerOverlay(proxy: proxy, anchors: anchors)

                            // ⛳️ Animated balls (start at resting ball center; land at label end)
                            MultiBallPuttOverlay(
                                selectedIDs: selectedIDs,
                                teeInset: .init(width: 24, height: 24),
                                proxy: proxy,
                                anchors: anchors
                            )
                        }
                        .allowsHitTesting(false)
                    }
                }
            }
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
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: date)
    }
}

// MARK: - Row that marks itself as a putt target (custom row, reliable label anchor)
private struct SelectToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Button(action: { isOn.toggle() }) {
            HStack {
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                Text(title)
                    .golfPuttLabelTarget(id: title)
                Spacer()
            }
            .padding(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .golfPuttTarget(id: title)
    }
}

// MARK: - Preference key & helpers
private struct GolfPuttTargetKey: PreferenceKey {
    static var defaultValue: [AnyHashable: Anchor<CGRect>] = [:]
    static func reduce(value: inout [AnyHashable: Anchor<CGRect>],
                       nextValue: () -> [AnyHashable: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
private extension View {
    func golfPuttTarget<ID: Hashable>(id: ID) -> some View {
        anchorPreference(key: GolfPuttTargetKey.self, value: .bounds) { [AnyHashable(id): $0] }
    }
    func golfPuttLabelTarget<ID: Hashable>(id: ID) -> some View {
        anchorPreference(key: GolfPuttTargetKey.self, value: .bounds) { [AnyHashable("label:\(id)"): $0] }
    }
}

// MARK: - Tee marker overlay (TEE + RESTING BALL + CLUB above Book button)
private struct TeeMarkerOverlay: View {
    let proxy: GeometryProxy
    let anchors: [AnyHashable: Anchor<CGRect>]

    // Wiggle state
    @State private var isWiggling = false
    @State private var wiggleLeft = false

    private var clubRotation: Double {
        let base = ClubConstants.rotation
        guard isWiggling else { return base }
        return base + (wiggleLeft ? -Wiggle.amplitude : Wiggle.amplitude)
    }

    var body: some View {
        if let a = anchors[AnyHashable("BookButton")] { // CHANGED: anchor to Book button ✅
            let r = proxy[a]
            let teeCenter = CGPoint(x: r.midX, y: r.minY - TeeConstants.yOffset)

            let ballOffsetY =
                -(TeeConstants.size / 2)
                - (RestingBallConstants.size / 2)
                + RestingBallConstants.overlapIntoTee

            ZStack {
                // Tee
                Group {
                    if UIImage(named: "golf_tee") != nil {
                        Image("golf_tee").resizable().aspectRatio(contentMode: .fit)
                    } else {
                        TeeVector()
                    }
                }
                .frame(width: TeeConstants.size, height: TeeConstants.size)
                .zIndex(0)

                // Static/resting ball
                GolfBallView()
                    .frame(width: RestingBallConstants.size, height: RestingBallConstants.size)
                    .offset(y: ballOffsetY)
                    .zIndex(1)

                // Club (image or vector) with wiggle rotation — render LAST so it stays on top
                Group {
                    if UIImage(named: "golf_club") != nil {
                        Image("golf_club")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        ClubVector()
                    }
                }
                .frame(width: ClubConstants.size.width, height: ClubConstants.size.height)
                .rotationEffect(.degrees(clubRotation))
                .offset(x: ClubConstants.dxFromBall,
                        y: ballOffsetY + ClubConstants.dyFromBall)
                .scaleEffect(1.05)        // slight perspective cue "in front"
                .opacity(0.98)
                .shadow(radius: 1, y: 0.5)
                .zIndex(2)                // ensure club renders above ball & tee
            }
            .position(teeCenter)
            .shadow(radius: 2, y: 1)
            .accessibilityHidden(true)
            // Listen for wiggle trigger
            .onReceive(NotificationCenter.default.publisher(for: .clubWiggle)) { _ in
                startWiggle()
            }
        }
    }

    private func startWiggle() {
        guard !isWiggling else { return }
        isWiggling = true
        // Toggle left/right for the configured number of steps
        for i in 0..<(Wiggle.cycles * 2) {
            let delay = Double(i) * Wiggle.stepDuration
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: Wiggle.stepDuration)) {
                    wiggleLeft.toggle()
                }
            }
        }
        // Settle back to base after total duration
        DispatchQueue.main.asyncAfter(deadline: .now() + Wiggle.totalDuration) {
            withAnimation(.easeOut(duration: Wiggle.stepDuration)) {
                isWiggling = false
                wiggleLeft = false
            }
        }
    }
}

// Simple vector tee fallback (red tee)
private struct TeeVector: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 1.2)
                .fill(Color.red)
                .frame(width: 4, height: 14)
                .offset(y: 3)
            Path { p in
                p.move(to: CGPoint(x: 11, y: 5))
                p.addLine(to: CGPoint(x: 4,  y: 10))
                p.addLine(to: CGPoint(x: 18, y: 10))
                p.closeSubpath()
            }
            .fill(Color.red)
        }
    }
}

// Simple vector club fallback (shaft + head)
private struct ClubVector: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 1.2)
                .fill(Color.gray.opacity(0.9))
                .frame(width: 3.5, height: 22)
                .offset(y: 2)
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color.black.opacity(0.9))
                .frame(width: 4.5, height: 6)
                .offset(y: -8)
            Capsule()
                .fill(Color.gray.opacity(0.95))
                .frame(width: 14, height: 8)
                .offset(x: 7, y: 9)
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(0.25), lineWidth: 0.8)
                        .frame(width: 14, height: 8)
                        .offset(x: 7, y: 9)
                )
        }
    }
}

// MARK: - Multi-ball overlay (origin = RESTING BALL CENTER; aim at label end)
private struct MultiBallPuttOverlay: View {
    struct BallState {
        var pos: CGPoint?
        var rollDeg: CGFloat = 0
        var visible: Bool = false
    }

    let selectedIDs: [String]
    let teeInset: CGSize
    let proxy: GeometryProxy
    let anchors: [AnyHashable: Anchor<CGRect>]

    @State private var balls: [String: BallState] = [:]
    @State private var lastSelected: Set<String> = []

    // detect compact–portrait to add more right padding only in portrait
    @Environment(\.horizontalSizeClass) private var hSize
    @Environment(\.verticalSizeClass) private var vSize

    var body: some View {
        ZStack {
            if Debug.showOriginMarker, let o = teeRestingBallCenter() {
                Circle()
                    .stroke(Color.blue.opacity(0.9), lineWidth: 2)
                    .frame(width: 10, height: 10)
                    .position(o)
            }

            if Debug.showLabelFrames {
                ForEach(Array(anchors.keys.compactMap { $0 as? String }.filter { $0.hasPrefix("label:") }), id: \.self) { key in
                    if let a = anchors[AnyHashable(key)] {
                        let r = proxy[a]
                        Rectangle()
                            .stroke(.green, lineWidth: 1.5)
                            .frame(width: r.width, height: r.height)
                            .position(CGPoint(x: r.midX, y: r.midY))
                    }
                }
            }

            ForEach(Array(balls.keys), id: \.self) { id in
                if let s = balls[id], s.visible, let p = s.pos {
                    GolfBallView()
                        .frame(width: 22, height: 22)
                        .rotationEffect(.degrees(s.rollDeg))
                        .position(p)
                        .shadow(radius: 2, y: 1)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        .id("ball-\(id)")
                }
            }
        }
        .onAppear {
            lastSelected = Set(selectedIDs)
            syncAdded(added: lastSelected, animateNewOnes: false)
        }
        .onChange(of: selectedIDs) { newIDs in
            let newSet = Set(newIDs)
            let added = newSet.subtracting(lastSelected)
            let removed = lastSelected.subtracting(newSet)
            lastSelected = newSet

            syncRemoved(removed: removed)
            syncAdded(added: added, animateNewOnes: true)
            snapBallsToTargets()
        }
    }

    // MARK: - Anchor helpers
    private func teeRestingBallCenter() -> CGPoint? {
        guard let a = anchors[AnyHashable("BookButton")] else { return nil } // CHANGED ✅
        let r = proxy[a]
        let teeCenterY = r.minY - TeeConstants.yOffset
        let restingBallCenterY =
            teeCenterY
            - (TeeConstants.size / 2)
            - (RestingBallConstants.size / 2)
            + RestingBallConstants.overlapIntoTee
        return CGPoint(x: r.midX, y: restingBallCenterY)
    }

    // dynamic padding — more space in compact portrait
    private func effectivePadding() -> CGFloat {
        let isCompactPortrait =
            (hSize == .compact && vSize == .regular) ||
            (proxy.size.width < proxy.size.height && proxy.size.width < 500)
        return isCompactPortrait ? 32 : TargetConstants.labelRightPadding
    }

    private func targetPoint(for id: String, preferLabel: Bool = true) -> CGPoint? {
        if let la = anchors[AnyHashable("label:\(id)")] {
            let lr = proxy[la]
            var x = lr.maxX + effectivePadding()
            x = min(x, proxy.size.width - TargetConstants.rightScreenMargin)
            return CGPoint(x: x, y: lr.midY)
        }
        if preferLabel { return nil }
        if let ra = anchors[AnyHashable(id)] {
            let rr = proxy[ra]
            return CGPoint(x: rr.midX, y: rr.midY)
        }
        return nil
    }

    private func fallbackTee() -> CGPoint {
        CGPoint(
            x: proxy.safeAreaInsets.leading + teeInset.width,
            y: proxy.size.height - proxy.safeAreaInsets.bottom - teeInset.height
        )
    }

    // MARK: - Sync logic
    private func syncAdded(added: Set<String>, animateNewOnes: Bool) {
        for id in added {
            balls[id] = BallState(pos: nil, rollDeg: 0, visible: false)
            trySpawnAndAnimate(id: id, animated: animateNewOnes)
        }
    }

    private func syncRemoved(removed: Set<String>) {
        for id in removed {
            withAnimation(.easeOut(duration: 0.18)) {
                balls[id]?.visible = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                balls.removeValue(forKey: id)
            }
        }
    }

    // Wait until both origin and target exist (retry), then animate.
    // Wiggle the club first, then launch. Fade the ball after landing.
    private func trySpawnAndAnimate(id: String, animated: Bool, attempt: Int = 0) {
        let preferLabel = attempt < 8

        let start = teeRestingBallCenter() ?? (attempt > 1 ? fallbackTee() : nil)
        let target = targetPoint(for: id, preferLabel: preferLabel)

        // schedule the fade-out+removal shortly after final leg begins
        func scheduleFadeOut() {
            let fadeOutStart = DispatchTime.now() + Motion.phase2Duration + 0.02
            DispatchQueue.main.asyncAfter(deadline: fadeOutStart) {
                withAnimation(.easeOut(duration: 0.28)) {
                    balls[id]?.visible = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                    balls.removeValue(forKey: id)
                }
            }
        }

        if let s = start, let t = target {
            if balls[id]?.pos == nil { balls[id]?.pos = s }

            // Trigger club wiggle and delay launch until wiggle completes
            NotificationCenter.default.post(name: .clubWiggle, object: nil)

            withAnimation(.linear(duration: 0.0001)) {
                balls[id]?.visible = true
                balls[id]?.pos = s
            }
            // include a pre-launch pause + wiggle time
            let phase1Start = DispatchTime.now() + Motion.pauseAtStart + Wiggle.totalDuration

            let (mid, distance) = midPoint(from: s, to: t)
            DispatchQueue.main.asyncAfter(deadline: phase1Start) {
                withAnimation(.easeInOut(duration: Motion.phase1Duration)) {
                    balls[id]?.pos = mid
                    balls[id]?.rollDeg += distance * 0.6
                }
                let phase2Start = DispatchTime.now() + Motion.phase1Duration + Motion.phase2DelayAfterPhase1
                DispatchQueue.main.asyncAfter(deadline: phase2Start) {
                    withAnimation(.easeInOut(duration: Motion.phase2Duration)) {
                        balls[id]?.pos = t
                        balls[id]?.rollDeg += distance * 0.7
                    }
                    scheduleFadeOut()
                }
            }
        } else if attempt < 10 {
            DispatchQueue.main.async {
                trySpawnAndAnimate(id: id, animated: animated, attempt: attempt + 1)
            }
        } else {
            // Last resort: row center
            let s = balls[id]?.pos ?? fallbackTee()
            let t = targetPoint(for: id, preferLabel: false) ?? s

            // Trigger wiggle here too for consistency
            NotificationCenter.default.post(name: .clubWiggle, object: nil)

            balls[id]?.pos = s
            let (mid, distance) = midPoint(from: s, to: t)
            withAnimation(.linear(duration: 0.0001)) {
                balls[id]?.visible = true
                balls[id]?.pos = s
            }
            let phase1Start = DispatchTime.now() + Motion.pauseAtStart + Wiggle.totalDuration
            DispatchQueue.main.asyncAfter(deadline: phase1Start) {
                withAnimation(.easeInOut(duration: Motion.phase1Duration)) {
                    balls[id]?.pos = mid
                    balls[id]?.rollDeg += distance * 0.6
                }
                let phase2Start = DispatchTime.now() + Motion.phase1Duration + Motion.phase2DelayAfterPhase1
                DispatchQueue.main.asyncAfter(deadline: phase2Start) {
                    withAnimation(.easeInOut(duration: Motion.phase2Duration)) {
                        balls[id]?.pos = t
                        balls[id]?.rollDeg += distance * 0.7
                    }
                    scheduleFadeOut()
                }
            }
        }
    }

    private func snapBallsToTargets() {
        for id in lastSelected {
            if let t = targetPoint(for: id, preferLabel: true) {
                withAnimation(.easeOut(duration: 0.12)) {
                    balls[id]?.pos = t
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                    if let t2 = targetPoint(for: id, preferLabel: true) {
                        withAnimation(.easeOut(duration: 0.12)) {
                            balls[id]?.pos = t2
                        }
                    }
                }
            }
        }
    }

    private func midPoint(from start: CGPoint, to target: CGPoint) -> (CGPoint, CGFloat) {
        let dx = target.x - start.x
        let dy = target.y - start.y
        let distance = sqrt(dx*dx + dy*dy)
        let mid = CGPoint(x: start.x + dx * 0.6,
                          y: start.y + dy * 0.6 - min(24, distance * 0.08))
        return (mid, distance)
    }
}

// MARK: - Golf ball view
private struct GolfBallView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [Color.white, Color(white: 0.92)],
                                     center: .center, startRadius: 2, endRadius: 16))
            Circle()
                .stroke(Color(white: 0.8).opacity(0.7), lineWidth: 0.6)
            Circle()
                .fill(.white.opacity(0.9))
                .blur(radius: 0.5)
                .frame(width: 8, height: 8)
                .offset(x: -4, y: -4)
        }
    }
}

