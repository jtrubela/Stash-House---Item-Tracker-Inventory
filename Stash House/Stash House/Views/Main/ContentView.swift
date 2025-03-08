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
            VStack(spacing: 20) {
                Image(systemName: "barcode.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("Welcome to Stash House")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let barcode = scannedBarcode {
                    Text("Last Scanned Barcode: \(barcode)")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                } else {
                    Text("No barcode scanned yet.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                NavigationLink(destination: BarcodeScanScreen(scannedCode: $scannedBarcode)) {
                    Text("Scan Barcode")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Stash House")
        }
        .onChange(of: scannedBarcode) { newBarcode in
            if let barcode = newBarcode {
                print("Scanned Barcode: \(barcode)")  // ✅ Prints to console
            }
        }
    }
}

// Preview for SwiftUI
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
