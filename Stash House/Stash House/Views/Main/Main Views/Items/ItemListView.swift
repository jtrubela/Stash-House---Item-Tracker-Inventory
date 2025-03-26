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
