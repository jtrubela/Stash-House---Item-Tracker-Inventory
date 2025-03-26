//
//  ScannerContentView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//

import SwiftUI
import CodeScanner

struct ScannerContentView: View {
    @State private var showDetail = false
    @State private var scannedBarcode: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(
                    destination: AddedItemDetailView(barcode: scannedBarcode ?? ""),
                    isActive: $showDetail
                ) {
                    EmptyView()
                }
                .hidden()
                
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
                showDetail = true
            }
        }
    }
}

// Preview for SwiftUI
struct ScannerContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ScannerContentView()
            .environmentObject(EbayAuthManager.shared)
            .environmentObject(TMDBAuthManager.shared)
    }
}
