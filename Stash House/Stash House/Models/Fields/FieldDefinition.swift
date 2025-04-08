//
//  FieldDefinition.swift
//  Stash House
//
//  Created by Justin Trubela on 4/8/25.
//


import Foundation

struct FieldDefinition: Identifiable, Codable {
    let id: UUID
    let key: String             // Unique field identifier (e.g. "title", "platform")
    let label: String           // UI label (e.g. "Title", "Release Date")
    let icon: String            // SF Symbol for UI display
    let type: FieldType         // FieldType enum (text, image, etc.)
    let options: [String]?      // Optional choices for selection fields
    
    init(
        key: String,
        label: String,
        icon: String,
        type: FieldType,
        options: [String]? = nil
    ) {
        self.id = UUID()
        self.key = key
        self.label = label
        self.icon = icon
        self.type = type
        self.options = options
    }
}
