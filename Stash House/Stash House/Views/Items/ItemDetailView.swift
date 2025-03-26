//
//  ItemDetailView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//


import SwiftUI
import CoreData

struct ItemDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let item: Item
    @State private var scannedBarcode: String?
    
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
            
            // Display scanned barcode
            if let barcode = scannedBarcode {
                Text("Barcode: \(barcode)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding()
            }
            
            // New button to navigate to Barcode Scanner
            NavigationLink(destination: BarcodeScanScreen(scannedCode: $scannedBarcode)) {
                Text("Scan Barcode")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Item Details")
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    
    let sampleItem = Item(context: context)
    sampleItem.name = "Vintage Watch"
    sampleItem.category = "Accessories"
    sampleItem.notes = "This is a limited edition timepiece."
    
    // Optional: Include mock image
    if let image = UIImage(systemName: "clock") {
        sampleItem.image = image.pngData()
    }
    
    return NavigationView {
        ItemDetailView(item: sampleItem)
            .environment(\.managedObjectContext, context)
    }
}
