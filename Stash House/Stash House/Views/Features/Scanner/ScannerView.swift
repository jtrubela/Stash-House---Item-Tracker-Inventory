//
//  ScannerView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//

import SwiftUI
import CodeScanner

struct ScannerView: View {
    @Binding var isScanning: Bool
    @Binding var isBulkScan: Bool
    @Binding var scannedItems: [ScannedItem]
    
    var body: some View {
        CodeScannerView(codeTypes: [.qr, .ean13, .ean8, .upce], completion: handleScan)
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
            case .success(let scanResult):
                let newItem = ScannedItem(id: UUID(), title: "Scanned Item", barcode: scanResult.string)
                scannedItems.append(newItem)
                if !isBulkScan {
                    isScanning = false
                }
            case .failure(let error):
                print("Scan failed: \(error.localizedDescription)")
                isScanning = false
        }
    }
}
