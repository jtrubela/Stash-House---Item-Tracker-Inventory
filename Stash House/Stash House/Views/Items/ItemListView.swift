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
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)])
    private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        VStack(alignment: .leading) {
                            Text(item.name ?? "Unknown")
                                .font(.headline)
                            Text(item.notes ?? "No details available")
                                .font(.subheadline)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .navigationTitle("Saved Movies")
        }
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    
    let item1 = Item(context: context)
    item1.id = UUID()
    item1.name = "The Matrix"
    item1.notes = "Sci-fi movie with Keanu Reeves"
    
    let item2 = Item(context: context)
    item2.id = UUID()
    item2.name = "Inception"
    item2.notes = "Dream within a dream"
    
    return ItemListView()
        .environment(\.managedObjectContext, context)
}
