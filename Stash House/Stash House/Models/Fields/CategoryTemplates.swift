import Foundation

struct CategoryTemplates {
    static let movies = TemplateModel(
        name: "Movies",
        description: "Track your film collection.",
        fields: [
            FieldDefinition(key: "title", label: "Title", icon: "textformat", type: .text),
            FieldDefinition(key: "director", label: "Director", icon: "person", type: .text),
            FieldDefinition(key: "releaseDate", label: "Release Date", icon: "calendar", type: .date),
            FieldDefinition(key: "barcode", label: "Barcode", icon: "barcode", type: .barcode),
            FieldDefinition(key: "poster", label: "Poster", icon: "photo", type: .image),
            FieldDefinition(key: "summary", label: "Summary", icon: "text.justify", type: .richText)
        ]
    )
    
    static let games = PreviewTemplates.games
    
    static let books = TemplateModel(
        name: "Books",
        description: "Track your book collection.",
        fields: [
            FieldDefinition(key: "title", label: "Title", icon: "textformat", type: .text),
            FieldDefinition(key: "author", label: "Author", icon: "person", type: .text),
            FieldDefinition(key: "publisher", label: "Publisher", icon: "building.2", type: .text),
            FieldDefinition(key: "isbn", label: "ISBN", icon: "barcode.viewfinder", type: .barcode),
            FieldDefinition(key: "cover", label: "Cover", icon: "book", type: .image),
            FieldDefinition(key: "summary", label: "Summary", icon: "text.justify", type: .richText)
        ]
    )
    
    static let music = TemplateModel(
        name: "Music",
        description: "Catalog your music library.",
        fields: [
            FieldDefinition(key: "title", label: "Track or Album Title", icon: "textformat", type: .text),
            FieldDefinition(key: "artist", label: "Artist", icon: "person.2", type: .text),
            FieldDefinition(key: "genre", label: "Genre", icon: "music.note.list", type: .text),
            FieldDefinition(key: "releaseDate", label: "Release Date", icon: "calendar", type: .date),
            FieldDefinition(key: "cover", label: "Cover Art", icon: "photo", type: .image)
        ]
    )
    
    static let tvShows = TemplateModel(
        name: "TV Shows",
        description: "Keep track of your favorite shows.",
        fields: [
            FieldDefinition(key: "title", label: "Title", icon: "textformat", type: .text),
            FieldDefinition(key: "seasons", label: "Number of Seasons", icon: "number", type: .integer),
            FieldDefinition(key: "network", label: "Network", icon: "antenna.radiowaves.left.and.right", type: .text),
            FieldDefinition(key: "showrunner", label: "Showrunner", icon: "person", type: .text),
            FieldDefinition(key: "poster", label: "Poster", icon: "photo", type: .image),
            FieldDefinition(key: "summary", label: "Summary", icon: "text.justify", type: .richText)
        ]
    )
    
    static let toys = TemplateModel(
        name: "Toys",
        description: "Track collectible or vintage toys.",
        fields: [
            FieldDefinition(key: "title", label: "Name", icon: "textformat", type: .text),
            FieldDefinition(key: "brand", label: "Brand", icon: "building.2", type: .text),
            FieldDefinition(key: "series", label: "Series", icon: "square.stack.3d.up", type: .text),
            FieldDefinition(key: "releaseYear", label: "Release Year", icon: "calendar", type: .text),
            FieldDefinition(key: "image", label: "Photo", icon: "photo", type: .image),
            FieldDefinition(key: "notes", label: "Notes", icon: "text.justify", type: .richText)
        ]
    )
    
    
    static let tradingCard = TemplateModel(
        name: "Trading Card",
        description: "Track sports or collectible cards in detail.",
        fields: [
            FieldDefinition(key: "title", label: "Card Title", icon: "textformat", type: .text),
            FieldDefinition(key: "playerName", label: "Player Name", icon: "person", type: .text),
            FieldDefinition(key: "cardNumber", label: "Card Number", icon: "number", type: .text),
            FieldDefinition(key: "team", label: "Team", icon: "person.3", type: .text),
            FieldDefinition(key: "year", label: "Year", icon: "calendar", type: .text),
            FieldDefinition(key: "set", label: "Set", icon: "square.grid.2x2", type: .text),
            FieldDefinition(key: "grade", label: "Grade", icon: "star", type: .selection, options: ["Ungraded", "PSA 10", "PSA 9", "Beckett 10"]),
            FieldDefinition(key: "image", label: "Card Image", icon: "photo", type: .image),
            FieldDefinition(key: "notes", label: "Notes", icon: "text.justify", type: .richText)
        ]
    )

    
    static let contacts = TemplateModel(
        name: "Contacts",
        description: "Store important personal or business contacts.",
        fields: [
            FieldDefinition(key: "name", label: "Full Name", icon: "person", type: .text),
            FieldDefinition(key: "phone", label: "Phone", icon: "phone", type: .phone),
            FieldDefinition(key: "email", label: "Email", icon: "envelope", type: .email),
            FieldDefinition(key: "address", label: "Address", icon: "house", type: .text),
            FieldDefinition(key: "notes", label: "Notes", icon: "note.text", type: .richText)
        ]
    )
    
    static let expenses = TemplateModel(
        name: "Expenses",
        description: "Track recurring or one-time expenses.",
        fields: [
            FieldDefinition(key: "title", label: "Expense Name", icon: "textformat", type: .text),
            FieldDefinition(key: "amount", label: "Amount", icon: "dollarsign.circle", type: .decimal),
            FieldDefinition(key: "category", label: "Category", icon: "square.grid.2x2", type: .text),
            FieldDefinition(key: "date", label: "Date", icon: "calendar", type: .date),
            FieldDefinition(key: "notes", label: "Notes", icon: "note.text", type: .richText)
        ]
    )

    static let subscriptions = TemplateModel(
        name: "Subscriptions",
        description: "Manage all your recurring subscriptions.",
        fields: [
            FieldDefinition(key: "service", label: "Service Name", icon: "rectangle.stack", type: .text),
            FieldDefinition(key: "amount", label: "Monthly Cost", icon: "dollarsign.circle", type: .decimal),
            FieldDefinition(key: "renewalDate", label: "Renewal Date", icon: "calendar.badge.clock", type: .date),
            FieldDefinition(key: "notes", label: "Notes", icon: "note.text", type: .richText)
        ]
    )

    static let credentials = TemplateModel(
        name: "Credentials",
        description: "Keep track of login credentials.",
        fields: [
            FieldDefinition(key: "account", label: "Account Name", icon: "person.crop.circle", type: .text),
            FieldDefinition(key: "username", label: "Username", icon: "person.text.rectangle", type: .text),
            FieldDefinition(key: "password", label: "Password", icon: "key", type: .text),
            FieldDefinition(key: "url", label: "Website", icon: "link", type: .url),
            FieldDefinition(key: "notes", label: "Notes", icon: "note.text", type: .richText)
        ]
    )

    static let inventory = TemplateModel(
        name: "Inventory",
        description: "Track inventory or supply stock.",
        fields: [
            FieldDefinition(key: "itemName", label: "Item Name", icon: "archivebox", type: .text),
            FieldDefinition(key: "quantity", label: "Quantity", icon: "number", type: .integer),
            FieldDefinition(key: "location", label: "Location", icon: "map", type: .text),
            FieldDefinition(key: "sku", label: "SKU / Barcode", icon: "barcode", type: .barcode),
            FieldDefinition(key: "notes", label: "Notes", icon: "note.text", type: .richText)
        ]
    )

    static let notes = TemplateModel(
        name: "Notes",
        description: "Freeform note-taking for anything.",
        fields: [
            FieldDefinition(key: "title", label: "Title", icon: "textformat", type: .text),
            FieldDefinition(key: "body", label: "Note Body", icon: "doc.plaintext", type: .richText),
            FieldDefinition(key: "date", label: "Date", icon: "calendar", type: .date)
        ]
    )

    static let school = TemplateModel(
        name: "School",
        description: "Track school-related records and notes.",
        fields: [
            FieldDefinition(key: "subject", label: "Subject", icon: "book", type: .text),
            FieldDefinition(key: "instructor", label: "Instructor", icon: "person", type: .text),
            FieldDefinition(key: "classNotes", label: "Notes", icon: "note.text", type: .richText),
            FieldDefinition(key: "date", label: "Date", icon: "calendar", type: .date)
        ]
    )

    
    static func forCategory(_ category: String) -> TemplateModel {
        switch category {
            case "Movies": return CategoryTemplates.movies
            case "Games": return CategoryTemplates.games
            case "Books": return CategoryTemplates.books
            case "Music": return CategoryTemplates.music
            case "TV Shows": return CategoryTemplates.tvShows
            case "Toys": return CategoryTemplates.toys
            case "Trading Card": return CategoryTemplates.tradingCard
            case "Contacts": return CategoryTemplates.contacts
            case "Expenses": return CategoryTemplates.expenses
            case "Subscriptions": return CategoryTemplates.subscriptions
            case "Credentials": return CategoryTemplates.credentials
            case "Inventory": return CategoryTemplates.inventory
            case "Notes": return CategoryTemplates.notes
            case "School": return CategoryTemplates.school
            default:
                return TemplateModel(name: category, description: "Custom fields", fields: [])
        }
    }

}
