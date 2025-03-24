//
//  EbayAPIService.swift
//  Stash House
//
//  Created by Justin Trubela on 3/23/25.
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
