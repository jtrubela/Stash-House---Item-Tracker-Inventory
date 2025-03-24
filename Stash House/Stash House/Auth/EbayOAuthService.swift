//
//  EbayOAuthService.swift
//  Stash House
//
//  Created by Justin Trubela on 3/23/25.
//


import Foundation

class EbayOAuthService {
    static func fetchAccessToken(completion: @escaping (String?) -> Void) {
        let clientID = Environments.get("clientID")
        let clientSecret = Environments.get("clientSecret")
        
        guard let url = URL(string: "https://api.ebay.com/identity/v1/oauth2/token") else {
            completion(nil)
            return
        }
        
        let credentials = "\(clientID):\(clientSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            completion(nil)
            return
        }
        
        let base64Credentials = credentialsData.base64EncodedString()
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyString = "grant_type=client_credentials&scope=https://api.ebay.com/oauth/api_scope"
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Token request failed: \(error?.localizedDescription ?? "No error message")")
                completion(nil)
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                print("✅ Token retrieved")
                completion(tokenResponse.access_token)
            } catch {
                print("❌ Decoding token failed: \(error)")
                completion(nil)
            }
        }.resume()
    }
}

struct TokenResponse: Codable {
    let access_token: String
    let expires_in: Int
    let token_type: String
}
