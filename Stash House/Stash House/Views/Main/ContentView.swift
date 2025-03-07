//
//  ContentView.swift
//  Stash House
//
//  Created by Justin Trubela on 6/30/23.
//

import SwiftUI

struct ContentView: View {
    @State private var scannedBarcode: String?
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, world!")
                
                // New button to navigate to Barcode Scanner
                NavigationLink(destination: BarcodeScanScreen(scannedCode: $scannedBarcode)) {
                    Text("Scan Barcode")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
            .navigationTitle("Stash House")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
