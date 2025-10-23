import Foundation

// MARK: - Public model
struct GCalEvent: Identifiable, Hashable {
    let id: String
    let summary: String
    let start: Date
    let end: Date
    let allDay: Bool
}

final class GoogleCalendarService {

    // ===== CONFIG (plist-based) =====
    private static var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "GAPI_KEY") as? String ?? ""
    }
    private static var calendarId: String {
        Bundle.main.object(forInfoDictionaryKey: "GCAL_ID") as? String ?? ""
    }

    // Minimal toggle-able debug logging
    private static let debugLog = true

    // Optional: quick debug line to confirm config at runtime
    static func debugSummary() -> String {
        let key = apiKey
        let masked = key.isEmpty ? "<empty>" : "\(key.prefix(6))…\(key.suffix(4))"
        return "KeySource=Info.plist, APIKey=\(masked), CalendarID=\(calendarId)"
    }

    // ===== API models =====
    private struct APIErrorEnvelope: Decodable {
        struct GError: Decodable { let code: Int; let message: String }
        let error: GError
    }
    private struct APIEventList: Decodable {
        struct Item: Decodable {
            struct DateTime: Decodable { let date: String?; let dateTime: String?; let timeZone: String? }
            let id: String
            let summary: String?
            let start: DateTime
            let end: DateTime
        }
        let items: [Item]?
    }

    // RFC3339 parsers (fractional and non-fractional)
    private static let isoFrac: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    private static let isoNoFrac: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
    private static func parseRFC3339(_ s: String) -> Date? {
        isoFrac.date(from: s) ?? isoNoFrac.date(from: s)
    }

    // MARK: - Public fetch
    /// Fetch events in [start, end) for the device timezone, with retry/backoff.
    static func fetchEvents(start: Date, end: Date, timeZone: TimeZone = .current, retries: Int = 3) async throws -> [GCalEvent] {
        guard !apiKey.isEmpty, !calendarId.isEmpty else {
            throw make("Missing GAPI_KEY or GCAL_ID in Info.plist")
        }
        let (req, session) = makeRequest(start: start, end: end, tz: timeZone)

        var lastError: Error?
        for attempt in 1...max(1, retries) {
            do {
                let (data, resp) = try await session.data(for: req)

                if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                    if let apiErr = try? JSONDecoder().decode(APIErrorEnvelope.self, from: data) {
                        throw make("Google API \(apiErr.error.code): \(apiErr.error.message)")
                    } else {
                        let snippet = String(data: data.prefix(1024), encoding: .utf8) ?? "<non-utf8>"
                        throw make("HTTP \(http.statusCode). Body: \(snippet)")
                    }
                }

                if debugLog {
                    if let http = resp as? HTTPURLResponse {
                        print("GCal HTTP \(http.statusCode) → \(http.url?.absoluteString ?? "")")
                        print("GCal Content-Type:", http.value(forHTTPHeaderField: "Content-Type") ?? "nil")
                    }
                    if let snippet = String(data: data.prefix(1024), encoding: .utf8) {
                        print("GCal Body (first 1KB):\n\(snippet)")
                    }
                }

                // Decode events
                let decoded = try JSONDecoder().decode(APIEventList.self, from: data)
                let items = decoded.items ?? []

                var results: [GCalEvent] = []
                for it in items {
                    // All-day
                    if let d = it.start.date {
                        guard let (sd, ed) = buildAllDayRange(startDateString: d, endDateString: it.end.date ?? d, timeZone: timeZone) else { continue }
                        results.append(GCalEvent(id: it.id, summary: it.summary ?? "(No title)", start: sd, end: ed, allDay: true))
                        continue
                    }
                    // Timed
                    if let s = it.start.dateTime, let e = it.end.dateTime,
                       let sd = parseRFC3339(s), let ed = parseRFC3339(e) {
                        results.append(GCalEvent(id: it.id, summary: it.summary ?? "(No title)", start: sd, end: ed, allDay: false))
                    }
                }
                return results

            } catch {
                lastError = error
                if let ue = error as? URLError {
                    let transient: Set<URLError.Code> = [
                        .networkConnectionLost, .timedOut, .cannotFindHost,
                        .cannotConnectToHost, .dnsLookupFailed, .notConnectedToInternet,
                        .internationalRoamingOff, .callIsActive, .dataNotAllowed
                    ]
                    if transient.contains(ue.code), attempt < retries {
                        // Exponential backoff: 0.6s, 1.2s, 2.4s…
                        let delay = UInt64(600_000_000) << (attempt - 1)
                        if debugLog { print("Retrying (\(attempt))/\(retries) after \(Double(delay)/1e9)s due to \(ue.code.rawValue)") }
                        try? await Task.sleep(nanoseconds: delay)
                        continue
                    }
                }
                throw error
            }
        }
        throw lastError ?? make("Network error")
    }

    // MARK: - URL / Session builder (PERCENT-ENCODES calendarId)
    private static func makeRequest(start: Date, end: Date, tz: TimeZone) -> (URLRequest, URLSession) {
        // Percent-encode calendarId for PATH (avoid "/")
        var pathAllowed = CharacterSet.urlPathAllowed
        pathAllowed.remove(charactersIn: "/")
        let encodedId = calendarId.addingPercentEncoding(withAllowedCharacters: pathAllowed) ?? calendarId

        var comps = URLComponents()
        comps.scheme = "https"
        comps.host   = "www.googleapis.com"
        comps.path   = "/calendar/v3/calendars/\(encodedId)/events"

        let df = ISO8601DateFormatter()
        df.timeZone = tz
        df.formatOptions = [.withInternetDateTime]

        comps.queryItems = [
            URLQueryItem(name: "key",          value: apiKey),
            URLQueryItem(name: "singleEvents", value: "true"),
            URLQueryItem(name: "orderBy",      value: "startTime"),
            URLQueryItem(name: "timeMin",      value: df.string(from: start)),
            URLQueryItem(name: "timeMax",      value: df.string(from: end)),
            URLQueryItem(name: "maxResults",   value: "2500"),
            URLQueryItem(name: "alt",          value: "json")
        ]

        var req = URLRequest(url: comps.url!)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.timeoutInterval = 20

        let cfg = URLSessionConfiguration.ephemeral
        cfg.waitsForConnectivity = true
        cfg.timeoutIntervalForRequest  = 30
        cfg.timeoutIntervalForResource = 60
        cfg.allowsConstrainedNetworkAccess = true
        cfg.allowsExpensiveNetworkAccess   = true

        let session = URLSession(configuration: cfg)
        if debugLog { print("GCal REQUEST URL:", comps.url?.absoluteString ?? "<nil>") }
        return (req, session)
    }

    // MARK: - Helpers
    private static func buildAllDayRange(startDateString: String, endDateString: String, timeZone: TimeZone) -> (Date, Date)? {
        func mk(_ s: String) -> Date? {
            guard s.count == 10 else { return nil }
            let y = Int(s.prefix(4))!
            let m = Int(s.dropFirst(5).prefix(2))!
            let d = Int(s.suffix(2))!
            var comps = DateComponents()
            comps.timeZone = timeZone
            comps.year = y; comps.month = m; comps.day = d
            return Calendar(identifier: .gregorian).date(from: comps)
        }
        guard let sd = mk(startDateString), let ed = mk(endDateString) else { return nil }
        return (sd, ed) // end is exclusive (midnight next day)
    }

    private static func make(_ msg: String) -> NSError {
        NSError(domain: "GoogleCalendarService", code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
    }
}

