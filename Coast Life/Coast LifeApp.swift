//
//  Coast_LifeApp.swift
//  Coast Life
//
//  Created by alan craig on 7/29/25.
//

import SwiftUI
import AppTrackingTransparency
@main
struct Coast_LifeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task{
                    await requestATTIfNeeded()
                }
        }
    }
}
@MainActor
private func requestATTIfNeeded() async {
    guard #available(iOS 14.5, *) else { return }
    guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
    try? await Task.sleep(nanoseconds: 300_000_000) // brief delay after launch
    ATTrackingManager.requestTrackingAuthorization { _ in }
}
