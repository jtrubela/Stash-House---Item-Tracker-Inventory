//
//  AddedItemDetailView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//


import SwiftUI

struct AddedItemDetailView: View {
    let barcode: String
    @State private var navigateToSearches = false
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isAdded = false
    
    @Environment(\.dismiss) private var dismiss
    var onComplete: (([String]) -> Void)? = nil
    
    @State private var navigateToSingleAdd = false
    
    
    
    var body: some View {
        VStack {
            NavigationLink(
                destination: ItemDetailSearchesView(barcode: barcode)
                    .environmentObject(EbayAuthManager.shared)
                    .environmentObject(TMDBAuthManager.shared),
                isActive: $navigateToSearches
            ) {
                EmptyView()
            }
            .hidden()
            
            Text("Item Details")
                .font(.title)
                .padding()
            
            Text("Barcode: \(barcode)")
                .font(.headline)
                .padding()
            
            Button(action: {
                let newItem = Item(context: viewContext)
                newItem.id = UUID()
                newItem.barcode = barcode
                newItem.name = "New Item from Barcode"
                newItem.notes = "Manually added from scan."
                newItem.category = "Unknown"
                
                do {
                    try viewContext.save()
                    isAdded = true
                    onComplete?([barcode])
                    dismiss() // ✅ Dismisses the BarcodeScanScreen sheet
                } catch {
                    print("❌ Error saving item: \(error.localizedDescription)")
                }
            }) {
                Text(isAdded ? "✅ Added!" : "Add to Library")
                    .padding()
                    .background(isAdded ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isAdded)
            .padding()
        }
    }
}

struct AddItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AddedItemDetailView(barcode: "00100860105891")
    }
}
