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

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        
        let sampleItem = Item(context: context)
        sampleItem.id = UUID()
        sampleItem.name = "Vintage Camera"
        sampleItem.category = "Photography"
        sampleItem.dateAdded = Date()
        sampleItem.notes = "A classic film camera in mint condition."
        
        // Mock image (optional)
        if let image = UIImage(systemName: "camera") {
            sampleItem.image = image.pngData()
        }
        
        return NavigationView {
            ItemDetailView(item: sampleItem)
        }
    }
}
