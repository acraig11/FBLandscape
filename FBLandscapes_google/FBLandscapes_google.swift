//
//  FBLandscapes_google.swift
//
//
//  Created by alan craig on 7/29/25.
//

import SwiftUI

@main
struct FBLandscapes_google: App {
  
        init() {
            print(Bundle.main.object(forInfoDictionaryKey: "GAPI_KEY") as? String ?? "missing")
            print(Bundle.main.object(forInfoDictionaryKey: "GCAL_ID") as? String ?? "missing")
        }


    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task{
                  
                }
        }
    }
}

