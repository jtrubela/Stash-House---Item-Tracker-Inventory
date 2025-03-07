//
//  ItemListView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//

import SwiftUI
import CoreData

struct ItemListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Item.dateAdded, ascending: false)])
    private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        Text(item.name ?? "Unknown Item")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("My Collection")
            .toolbar {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
    }
    
    private func addItem() {
        let newItem = Item(context: viewContext)
        newItem.id = UUID()
        newItem.name = "New Item"
        newItem.dateAdded = Date()
        
        saveContext()
    }
    
    private func deleteItems(offsets: IndexSet) {
        offsets.map { items[$0] }.forEach(viewContext.delete)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock CoreData context for preview
        let context = PersistenceController.shared.container.viewContext
        
        // Add sample items for preview
        let newItem = Item(context: context)
        newItem.id = UUID()
        newItem.name = "Sample Item"
        newItem.category = "Books"
        newItem.dateAdded = Date()
        newItem.notes = "This is a sample note."
        
        return NavigationView {
            ItemListView()
                .environment(\.managedObjectContext, context)
        }
    }
}
