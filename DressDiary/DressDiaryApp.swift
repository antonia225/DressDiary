//
//  DressDiaryApp.swift
//  DressDiary
//
//  Created by Antonia Stoica on 19.10.2025.
//

import SwiftUI

@main
struct DressDiaryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
