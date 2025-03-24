//
//  EbayAuthManager.swift
//  Stash House
//
//  Created by Justin Trubela on 3/23/25.
//


import Foundation
import Combine

class EbayAuthManager: ObservableObject {
    static let shared = EbayAuthManager()
    
    @Published var bearerToken: String = ""
    
    init() {
        fetchToken()
    }
    
    func fetchToken() {
        EbayOAuthService.fetchAccessToken { token in
            DispatchQueue.main.async {
                self.bearerToken = token ?? ""
            }
        }
    }
}
