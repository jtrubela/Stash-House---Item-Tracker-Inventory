//
//  Environment.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//

import Foundation

public struct Environments {
    // MARK: - Friendly key mapper
    private static let keyMap: [String: String] = [
        "redirectURI": "EBAY_REDIRECT_URI",
        "clientID": "EBAY_CLIENT_ID",
        "clientSecret": "EBAY_CLIENT_SECRET",
        "scope":"EBAY_SCOPE",
        "tmdbAPIKey":"TMDB_API_KEY"
    ]
    
    // Generic getter with mapping
    static func get(_ key: String) -> String {
        let actualKey = keyMap[key] ?? key
        return Configuration.value(for: actualKey) ?? ""
    }
    
    //TMDB CONFIGURATIONS
    static var tmdbAPIKey: String {
        return get("TMDB_API_KEY")
    }
    
    //EBAY CONFIGURATIONS
    static var ebayRedirectURI: String {
        return get("EBAY_REDIRECT_URI")
    }
    static var ebayClientID: String {
        return get("EBAY_CLIENT_ID")
    }
    static var ebayClientSecret: String {
        return get("EBAY_CLIENT_SECRET")
    }
    static var ebayScope: String {
        return get("EBAY_SCOPE")
    }
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
