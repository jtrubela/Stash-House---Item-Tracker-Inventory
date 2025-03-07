//
//  BarcodeScanScreen.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//

import SwiftUI
import AVFoundation

struct BarcodeScanScreen: View {
    @Binding var scannedCode: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Scan a Barcode")
                .font(.title)
                .padding()

            BarcodeScannerView(scannedCode: $scannedCode, onScanComplete: { barcode in
                scannedCode = barcode
                presentationMode.wrappedValue.dismiss()
            })
            .edgesIgnoringSafeArea(.all)
        }
    }
}

// Preview for SwiftUI
struct BarcodeScanScreen_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScanScreen(scannedCode: .constant(nil))
    }
}
