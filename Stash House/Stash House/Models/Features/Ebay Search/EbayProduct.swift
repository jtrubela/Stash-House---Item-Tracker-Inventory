//
//  EbayProduct.swift
//  Stash House
//
//  Created by Justin Trubela on 3/23/25.
//

import Foundation

struct EbayProduct: Codable, Identifiable {
    let id: String
    let title: String
    let price: String
    let imageURL: String?
    let itemWebUrl: String
}


struct EbayProductDetail: Identifiable {
    let rawJSON: [String: Any]?
    let imageURL: String?
    let id: String
    let title: String
    let shortDescription: String?
    let categoryPath: String?
    let categoryIdPath: String?
    let upc: [String]?
    let epid: String?
    let edition: String?
    let rating: String?
    let movieTitle: String?
    let directors: [String]?
    let format: String?
    let releaseYear: String?
    let genre: String?
    let subGenre: String?
    let numberOfDiscs: Int?
    let country: String?
    let language: String?
}

extension EbayProductDetail: Decodable {
    enum CodingKeys: String, CodingKey {
        case imageURL = "image"
        case id = "itemId"
        case title
        case shortDescription
        case categoryPath
        case categoryIdPath
        case gtin
        case epid
        case product
        case localizedAspects
    }
    
    enum ImageKeys: String, CodingKey {
        case imageUrl
    }
    
    enum ProductKeys: String, CodingKey {
        case additionalProductAttributes
    }
    
    enum AttributeKeys: String, CodingKey {
        case name
        case value
    }
    
    struct LocalizedAspect: Codable {
        let name: String
        let value: String
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Capture raw data for other fields
        if let jsonObject = try? JSONSerialization.jsonObject(with: decoder.userInfo[.dataKey] as! Data) as? [String: Any] {
            rawJSON = jsonObject
        } else {
            rawJSON = nil
        }
        
        if let imageContainer = try? container.nestedContainer(keyedBy: ImageKeys.self, forKey: .imageURL) {
            imageURL = try imageContainer.decodeIfPresent(String.self, forKey: .imageUrl)
        } else {
            imageURL = nil
        }
        
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription)
        
        categoryPath = try container.decodeIfPresent(String.self, forKey: .categoryPath)
        categoryIdPath = try container.decodeIfPresent(String.self, forKey: .categoryIdPath)
        
        
        // Decode GTIN (UPC) which might be a string or array
        if let gtinArray = try? container.decode([String].self, forKey: .gtin) {
            upc = gtinArray
        } else if let singleGTIN = try? container.decode(String.self, forKey: .gtin) {
            upc = [singleGTIN]
        } else {
            upc = nil
        }
        
        epid = try container.decodeIfPresent(String.self, forKey: .epid)
        
        
        var edition: String? = nil
        var rating: String? = nil
        var movieTitle: String? = nil
        var directors: [String]? = nil
        var format: String? = nil
        var releaseYear: String? = nil
        var genre: String? = nil
        var subGenre: String? = nil
        var numberOfDiscs: Int? = nil
        var country: String? = nil
        var language: String? = nil
        
        // First try: product.additionalProductAttributes
        if let productContainer = try? container.nestedContainer(keyedBy: ProductKeys.self, forKey: .product),
           var attributes = try? productContainer.nestedUnkeyedContainer(forKey: .additionalProductAttributes) {
            while !attributes.isAtEnd {
                let attr = try attributes.nestedContainer(keyedBy: AttributeKeys.self)
                let name = (try? attr.decode(String.self, forKey: .name))?.lowercased()
                let value = try? attr.decode(String.self, forKey: .value)
                
                switch name {
                    case "edition": edition = value
                    case "rating": rating = value
                    case "movie/tv title": movieTitle = value
                    case "director": directors = value?.components(separatedBy: ", ")
                    case "format": format = value
                    case "release year": releaseYear = value
                    case "genre": genre = value
                    case "sub-genre": subGenre = value
                    case "number of discs": numberOfDiscs = Int(value ?? "")
                    case "country/region of manufacture": country = value
                    case "language": language = value
                    default: break
                }
            }
        }
        
        // Second source: localizedAspects
        let localizedAspects = (try? container.decode([LocalizedAspect].self, forKey: .localizedAspects)) ?? []
        for aspect in localizedAspects {
            let name = aspect.name.lowercased()
            let value = aspect.value
            
            switch name {
                case "edition": edition = edition ?? value
                case "rating": rating = rating ?? value
                case "movie/tv title": movieTitle = movieTitle ?? value
                case "director": if directors == nil { directors = value.components(separatedBy: ", ") }
                case "format": format = format ?? value
                case "release year": releaseYear = releaseYear ?? value
                case "genre": genre = genre ?? value
                case "sub-genre": subGenre = subGenre ?? value
                case "number of discs": numberOfDiscs = numberOfDiscs ?? Int(value)
                case "country/region of manufacture": country = country ?? value
                case "language": language = language ?? value
                default: break
            }
        }
        
        self.edition = edition
        self.rating = rating
        self.movieTitle = movieTitle
        self.directors = directors
        self.format = format
        self.releaseYear = releaseYear
        self.genre = genre
        self.subGenre = subGenre
        self.numberOfDiscs = numberOfDiscs
        self.country = country
        self.language = language
    }
}

extension CodingUserInfoKey {
    static let dataKey = CodingUserInfoKey(rawValue: "rawData")!
}

