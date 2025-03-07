//
//  Untitled.swift
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
