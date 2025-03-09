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
    @State private var bulkScanMode = false
    @State private var isFlashlightOn = false
    @State private var barcodeType: AVMetadataObject.ObjectType = .ean13
    @State private var manualEntryMode = false
    @State private var manualBarcode = ""
    @State private var scannedBarcodes: Set<String> = []
    @State private var navigateToBulkAdd = false
    @State private var selectedBarcode: String?
    @Environment(\.presentationMode) var presentationMode
    
    var onScanComplete: ((Set<String>) -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack {
                //Camera Preview
                VStack{
                    //Preview  - No Camera access given
                    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil{
                        VStack {
                            Text("Camera Preview")
                            Text("(Disabled in SwiftUI Preview)")
                        }
                        
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                    //Preview  - Camera access
                    else {
                        BarcodeScannerView(
                            scannedCode: $scannedCode,
                            barcodeType: barcodeType,
                            onScanComplete: { barcode in
                                scannedBarcodes.insert(barcode)
                                if !bulkScanMode {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            },
                            isFlashlightOn: $isFlashlightOn
                        )
                        
                        .edgesIgnoringSafeArea(.horizontal)
                    }
                }
                .padding(.bottom,50)
                
                
                
                
                Spacer()
                
                // Scan Settings Toolbar
                VStack{
                    ZStack {
                        Color(UIColor.systemGray6)
                            .edgesIgnoringSafeArea(.bottom)
                        
                        Divider()
                        
                        // Type Picker and Scan Settings Buttons
                        VStack{
                            
                            //Bulk Add Items View and List
                            HStack{
                                if !bulkScanMode && scannedBarcodes.isEmpty{
                                    VStack {
                                        VStack(alignment: .leading, spacing: 15) {  // ✅ Changed to .leading for better alignment
                                            Text("""
        1. Point Camera and center barcode within box.
        2. Box will turn green when barcode is scanned.
        3. Bulk Scan: Allows you to scan multiple items.
        4. Manual Entry: Enter barcode manually.
        """)
                                            .padding(.vertical)
                                            Text("""
        - Barcode must be upright.
        - Avoid shadows and glares.
        - Accepts 8 and 12 digit barcodes.
        """)
                                        }
                                        .multilineTextAlignment(.leading)  // ✅ Ensures text aligns correctly
                                        .fixedSize(horizontal: false, vertical: true)  // ✅ Prevents text from being clipped
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)  // ✅ Correct frame
                                    .font(.caption2)
                                    
                                }
                                else{
                                    // ✅ List of scanned Items - "View Scanned Items" Button
                                    NavigationLink(destination: BulkAddDetailsView(scannedBarcodes: Array(scannedBarcodes), onComplete: { newList in
                                        onScanComplete?(Set(newList))
                                        presentationMode.wrappedValue.dismiss()})){
                                            ScanButtonView(
                                                action: nil,  // ✅ No direct action needed since it's a NavigationLink
                                                destination: AnyView(BulkAddDetailsView(scannedBarcodes: Array(scannedBarcodes), onComplete: { newList in
                                                    onScanComplete?(Set(newList))
                                                    presentationMode.wrappedValue.dismiss()
                                                })),
                                                iconName: "list.bullet.rectangle",
                                                title: "Scanned Items",
                                                foregroundColor: Color.secondary,
                                                backgroundColor: Color.green,
                                                shadowColor: Color.green.opacity(0.5)
                                            )
                                            .frame(width: 90, height: 130, alignment: .center)
                                        }
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                    
                                    
                                    // View Scanned Items
                                    ScrollView {
                                        //View Scanned Items - Bulk Add Items List
                                        VStack {
                                            ForEach(Array(scannedBarcodes), id: \.self) { barcode in
                                                
                                                NavigationLink(destination: BulkAddDetailsView(scannedBarcodes: [barcode], onComplete: { newList in
                                                    onScanComplete?(Set(newList))
                                                })) {
                                                    Text(barcode)
                                                        .padding(.horizontal, 10) // ✅ Adds spacing inside the box
                                                        .padding(.vertical, 11) // ✅ Keeps height balanced
                                                        .background(Color.gray.opacity(0.2))
                                                        .cornerRadius(8)
                                                        .foregroundColor(.secondary)
                                                        .font(.system(size: 18, weight: .medium, design: .monospaced)) // ✅ Makes text look consistent
                                                    
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .frame(height: 110) // Bulk Add Items List scrollView size
                                }
              
                            }
                            
                            
                            
                            // Barcode Type Picker
                            Section(header: Text("Barcode Type")
                                .font(.caption).underline()
                                .padding(.top,25)
                            ){
                                Picker("Barcode Type", selection: $barcodeType) {
                                    Text("EAN-13").tag(AVMetadataObject.ObjectType.ean13)
                                    Text("EAN-8").tag(AVMetadataObject.ObjectType.ean8)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            
                            Divider()
                            
                            
                            // ✅ Scan Settings Section
                            Section(header: Text("Scan Settings")
                                .font(.caption).underline()
                            ) {
                                HStack(spacing: 30) {
                                    ScanButtonView(
                                        action: { bulkScanMode.toggle() },
                                        destination: nil,
                                        iconName:
                                            !bulkScanMode ? "person.crop.rectangle" : "person.crop.rectangle.stack.fill",
                                        title: "Bulk Scan",
                                        foregroundColor: Color.black,
                                        backgroundColor:
                                            bulkScanMode ? Color.red : Color.blue,
                                        shadowColor:
                                            bulkScanMode ? Color.red : Color.blue
                                    )
                                    
                                    ScanButtonView(
                                        action: { isFlashlightOn.toggle() },
                                        destination: nil,
                                        iconName: "flashlight.on.fill",
                                        title: "Flashlight",
                                        foregroundColor:
                                            isFlashlightOn ? Color.black : Color.black,
                                        backgroundColor:
                                            isFlashlightOn ? Color.yellow : Color.white,
                                        shadowColor:
                                            isFlashlightOn ? Color.yellow : Color.white
                                    )
                                    
                                    ScanButtonView(
                                        action: { manualEntryMode.toggle() },
                                        destination: nil,
                                        iconName: "dots.and.line.vertical.and.cursorarrow.rectangle",
                                        title: "Manual Entry",
                                        foregroundColor: Color.black,
                                        backgroundColor: Color.orange,
                                        shadowColor: Color.orange
                                    )
                                }
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                    }
                    Divider()
                        .sheet(isPresented: $manualEntryMode) {
                            VStack {
                                Text("Enter Barcode Manually")
                                    .font(.title)
                                    .padding()
                                
                                TextField("Enter Barcode", text: $manualBarcode)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                
                                Button(action: {
                                    scannedBarcodes.insert(manualBarcode)
                                    if !manualBarcode.isEmpty {
                                        scannedBarcodes.insert(manualBarcode)
                                        scannedCode = manualBarcode
                                        manualEntryMode = false
                                    }
                                }) {
                                    Text("Submit")
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                }
            }
        }.navigationBarBackButtonHidden()
    }
}


// ✅ SwiftUI Preview
struct BarcodeScanScreen_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScanScreen(scannedCode: .constant(nil))
    }
}


struct ScanButtonView: View {
    let action: (() -> Void)?  // ✅ Supports tap actions
    let destination: AnyView?  // ✅ Supports NavigationLink destinations (if applicable)
    let iconName: String
    let title: String
    let foregroundColor: Color
    let backgroundColor: Color
    let shadowColor: Color
    var frameWidth: CGFloat = 90  // ✅ Default width
    var frameHeight: CGFloat = 60 // ✅ Default height
    
    
    var body: some View {
        if let destination = destination {
            NavigationLink(destination: destination) {
                buttonContent()
            }
        } else if let action = action {
            Button(action: action) {
                buttonContent()
            }
        }
    }
    
    private func buttonContent() -> some View {
        VStack {
            Image(systemName: iconName)
                .font(.system(size: 30))
                .frame(width: frameWidth, height: frameHeight, alignment: .center)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(10)
            Text(title)
        }
        .shadow(color: shadowColor, radius: 5)
    }
}
