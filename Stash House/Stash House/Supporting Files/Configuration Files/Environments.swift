//
//  Environment.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//

import Foundation

public struct Environments {
    enum Keys {
        static var tmdbAPIKey: String {
            return Configuration.value(for: "TMDB_API_KEY") ?? ""
        }
    }
    
    // Get the API
    static let tmdbAPIKey: String = {
        guard let APIKeyProperty = Bundle.main.object(
            forInfoDictionaryKey: Keys.tmdbAPIKey
        ) as? String else {
            fatalError("TMDB_API_KEY not found")
        }
        return APIKeyProperty
    }()
}

// MARK: - Configuration Helper

enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }
    
    static func value<T>(for key: String) -> T? where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            print("❌ Missing Environment Configuration key: \(key)")
            return nil
        }
        
        switch object {
            case let value as T:
                return value
            case let string as String:
                return T(string)
            default:
                print("❌ Invalid Environment Configuration value for key: \(key)")
                return nil
        }
    }
}
