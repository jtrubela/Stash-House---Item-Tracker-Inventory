//
//  Stash_HouseApp.swift
//  Stash House
//
//  Created by Justin Trubela on 6/30/23.
//

import SwiftUI

@main
struct StashHouseApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
