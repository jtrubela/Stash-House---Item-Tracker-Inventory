//
//  TMDBAuthManager.swift
//  Stash House
//
//  Created by Justin Trubela on 3/24/25.
//


import Foundation
import Combine
import TMDBSwift

class TMDBAuthManager: ObservableObject {
    static let shared = TMDBAuthManager()
    
    @Published var apiKey: String = ""

    init() {
        fetchKey()
    }

    func fetchKey() {
        let key = Environments.tmdbAPIKey
        self.apiKey = key
        TMDBConfig.apikey = key // ✅ Set global config
        print("📦 TMDB API Key set: \(key)")
    }
}
