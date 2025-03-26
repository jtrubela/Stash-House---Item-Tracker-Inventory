
//
//  Collectibles.swift
//  Stash House
//
//  Created by Justin Trubela on 3/2/25.
//

import SwiftUI
import Foundation

struct Collection: Identifiable {
    let id = UUID()
    let name: String
    let items: [Collectible]
}

enum CollectionType: String, CaseIterable, Identifiable {
    case cards = "Cards"
    case media = "Media"
    case other = "Other"
    
    var id: String { self.rawValue }
}

struct Collectible: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct CollectibleItem: Identifiable, Hashable, Equatable {
    var id: UUID = .init()
    var name: String
    var imageName: String
}

struct CollectibleCard: Identifiable, Codable, Hashable {
    var id: UUID = UUID() // Generated if not provided by JSON
    var cardNumber: Int
    var cardTitle: String
    var cardImage: String
    
    private enum CodingKeys: String, CodingKey {
        case cardNumber, cardTitle, cardImage
    }
}



let BaseballCards: [Collectible] = [
    Collectible(name: "Babe Ruth", imageName: "babe_ruth"),
    Collectible(name: "Jackie Robinson", imageName: "jackie_robinson")
]

let baseballCardItems: [Collectible] = [
    Collectible(name: "Babe Ruth", imageName: "babe_ruth"),
    Collectible(name: "Jackie Robinson", imageName: "jackie_robinson")
]

