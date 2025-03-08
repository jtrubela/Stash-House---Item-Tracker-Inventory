//
//  Environment.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//

import Foundation

public struct Environments {
    enum Keys {
        static let apikey = "TMDB_API_KEY"
    }
    
    // Get the API
    static let apikey: String = {
        guard let APIKeyProperty = Bundle.main.object(
            forInfoDictionaryKey: Keys.apikey
        ) as? String else {
            fatalError("TMDB_API_KEY not found")
        }
        return APIKeyProperty
    }()
}
