//
//  Stash_HouseApp.swift
//  Stash House
//
//  Created by Justin Trubela on 6/30/23.
//

import SwiftUI
import TMDBSwift

@main
struct StashHouseApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ScannerContentView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
