//
//  TemplateModel.swift
//  Stash House
//
//  Created by Justin Trubela on 4/8/25.
//


import SwiftUI
import Foundation


struct TemplateModel: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let fields: [FieldDefinition]
    
    init(name: String, description: String, fields: [FieldDefinition]) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.fields = fields
    }
}



// Sample Game Template
enum PreviewTemplates {
    static let games = TemplateModel(
        name: "Games",
        description: "Manage your video games.",
        fields: [
            FieldDefinition(key: "title", label: "Title", icon: "textformat", type: .text),
            FieldDefinition(key: "cover", label: "Cover", icon: "photo", type: .image),
            FieldDefinition(key: "platform", label: "Platform", icon: "desktopcomputer", type: .selection, options: ["PS5", "Xbox", "Switch"]),
            FieldDefinition(key: "genre", label: "Genre", icon: "music.note.list", type: .selection, options: ["Action", "RPG", "Sports"]),
            FieldDefinition(key: "releaseDate", label: "Release Date", icon: "calendar", type: .date),
            FieldDefinition(key: "summary", label: "Summary", icon: "text.justify", type: .text),
            FieldDefinition(key: "barcode", label: "Barcode", icon: "barcode", type: .barcode)
        ]
    )
}


#Preview {
    NavigationStack {
        TemplateFormView(template: PreviewTemplates.games)
    }
}
