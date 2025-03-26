//
//  EbayAPIService.swift
//  Stash House
//
//  Created by Justin Trubela on 3/23/25.
//
//


import Foundation

class EbayAPIService {
    static func fetchProducts(keyword: String, token: String, completion: @escaping ([EbayProduct]) -> Void) {
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.ebay.com/buy/browse/v1/item_summary/search?q=\(encodedKeyword)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            do {
                let raw = try JSONDecoder().decode(RawEbaySearchResponse.self, from: data)
                let products = raw.itemSummaries.map {
                    EbayProduct(
                        id: $0.itemId,
                        title: $0.title,
                        price: $0.price.value + " " + $0.price.currency,
                        imageURL: $0.image?.imageUrl,
                        itemWebUrl: $0.itemWebUrl
                    )
                }
                completion(products)
            } catch {
                print("Decoding error: \(error)")
                completion([])
            }
        }.resume()
    }
    
    // Add to EbayAPIService.swift
    static func fetchProductDetail(itemId: String, token: String, completion: @escaping (EbayProductDetail?) -> Void) {
        let urlString = "https://api.ebay.com/buy/browse/v1/item/\(itemId)"
        print("➡️ Fetching eBay item detail for ID: \(itemId)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("❌ No data returned")
                completion(nil)
                return
            }
            
            // Optional: print raw response
            // print(String(data: data, encoding: .utf8) ?? "Unreadable")
            
            do {
                let decoder = JSONDecoder()
                decoder.userInfo[.dataKey] = data
                let productDetail = try decoder.decode(EbayProductDetail.self, from: data)
                print("✅ Successfully decoded product detail: \(productDetail.title)")
                completion(productDetail)
            } catch {
                print("❌ Decoding failed: \(error)")
                print(String(data: data, encoding: .utf8) ?? "❌ Response not UTF-8")
                completion(nil)
            }
        }.resume()
    }
    
}


// MARK: - Raw eBay API Response
struct RawEbaySearchResponse: Codable {
    let itemSummaries: [RawItem]
}

struct RawItem: Codable {
    let itemId: String
    let title: String
    let price: RawPrice
    let image: RawImage?
    let itemWebUrl: String
}

struct RawPrice: Codable {
    let value: String
    let currency: String
}

struct RawImage: Codable {
    let imageUrl: String
}
