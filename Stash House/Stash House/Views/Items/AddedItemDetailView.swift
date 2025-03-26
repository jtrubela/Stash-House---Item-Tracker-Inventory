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
                print("Perform action for \(barcode)")
                navigateToSearches = true
            }) {
                Text("Perform Action")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct AddItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AddedItemDetailView(barcode: "00100860105891")
    }
}
