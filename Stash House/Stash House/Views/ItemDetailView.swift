//
//  ItemDetailView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//


import SwiftUI
import CoreData

struct ItemDetailView: View {
    let item: Item

    var body: some View {
        VStack {
            Text(item.name ?? "Unknown Item")
                .font(.largeTitle)
                .padding()

            if let imageData = item.image, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            } else {
                Text("No Image Available")
                    .foregroundColor(.gray)
            }

            Text("Category: \(item.category ?? "N/A")")
                .font(.headline)

            Text("Notes: \(item.notes ?? "No Notes")")
                .padding()

            Spacer()
        }
        .navigationTitle("Item Details")
    }
}
