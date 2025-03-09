//
//  AddedItemDetailView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//


import SwiftUI

struct AddedItemDetailView: View {
    let barcode: String
    
    var body: some View {
        VStack {
            Text("Item Details")
                .font(.title)
                .padding()
            
            Text("Barcode: \(barcode)")
                .font(.headline)
                .padding()
            
            Button(action: {
                print("Perform action for \(barcode)")  // ✅ Replace with real action
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
        AddedItemDetailView(barcode: "0010086010589")
    }
}
