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
    @StateObject private var ebayAuthManager = EbayAuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            EbaySearchView()
                .environmentObject(ebayAuthManager)
        }
    }
}
