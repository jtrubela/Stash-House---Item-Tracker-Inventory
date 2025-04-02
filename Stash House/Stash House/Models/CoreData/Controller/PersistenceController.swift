//
//  PersistenceController.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // MARK: - Sample Collectibles
        let sampleItems = [
            ("The Dark Knight", "0001234567890", "Movie", "Director: Nolan\nRelease Year: 2008"),
            ("Ken Griffey Jr. Card", "1234567890123", "Trading Card", "Player: Ken Griffey Jr.\nCard #: 41"),
            ("Spider-Man #1", "998877665544", "Comic Book", "Writer: Stan Lee\nIssue #: 1")
        ]
        
        for (name, barcode, category, notes) in sampleItems {
            let item = Item(context: context)
            item.id = UUID()
            item.name = name
            item.barcode = barcode
            item.category = category
            item.notes = notes
            item.timestamp = Date()
        }
        
        do {
            try context.save()
        } catch {
            fatalError("❌ Failed to preload preview data: \(error)")
        }
        
        return controller
    }()
    

    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // ⚠️ This name MUST match your .xcdatamodeld filename exactly (without the extension)
        container = NSPersistentContainer(name: "StashHouse")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("❌ Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // Optional: Easier access to the main context
    var context: NSManagedObjectContext {
        return container.viewContext
    }
}
