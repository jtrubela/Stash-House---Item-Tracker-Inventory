//
//  EbayProduct.swift
//  Stash House
//
//  Created by Justin Trubela on 3/23/25.
//

//import Foundation

struct EbayProduct: Codable, Identifiable {
    let id: String
    let title: String
    let price: String
    let imageURL: String?
    let itemWebUrl: String
}
