//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by Mohsin khan on 09/11/2025.
//

import SwiftUI
import SwiftData

@main
struct HotProspectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(for : Prospect.self)
    }
}
