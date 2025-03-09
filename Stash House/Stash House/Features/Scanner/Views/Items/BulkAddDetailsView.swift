//
//  BulkAddDetailsView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//


import SwiftUI

struct BulkAddDetailsView: View {
    @State var scannedBarcodes: [String]
    var selectedBarcode: String?  // ✅ Highlights the selected barcode
    var onComplete: (([String]) -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Bulk Add Details")
                    .font(.title)
                    .padding()
                
                List {
                    ForEach(scannedBarcodes, id: \.self) { barcode in
                        NavigationLink(destination: AddedItemDetailView(barcode: barcode)) {
                            Text(barcode)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(barcode == selectedBarcode ? Color.yellow.opacity(0.3) : Color.clear)  // ✅ Highlight selected barcode
                        }
                    }
                    .onDelete(perform: deleteBarcode)
                }
                
                Button(action: {
                    onComplete?(scannedBarcodes)  // ✅ Send selected barcodes to ContentView
                }) {
                    Text("Add to Inventory")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
    
    // ✅ Allows deletion of a barcode
    func deleteBarcode(at offsets: IndexSet) {
        scannedBarcodes.remove(atOffsets: offsets)
    }
}
