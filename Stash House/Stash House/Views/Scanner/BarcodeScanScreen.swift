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

#Preview {
    ScannerView(
        isScanning: .constant(true),
        isBulkScan: .constant(false),
        scannedItems: .constant([
            ScannedItem(id: UUID(), title: "Mock Item", barcode: "123456789012")
        ])
    )
}




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

#Preview {
    ScanButtonView(
        action: { print("Scan Button Tapped") },
        destination: nil,
        iconName: "barcode.viewfinder",
        title: "Scan",
        foregroundColor: .white,
        backgroundColor: .blue,
        shadowColor: .blue.opacity(0.5)
    )
}



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



//
//  BarcodeScannerView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//
import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    
    @Binding var scannedCode: String?
    var barcodeType: AVMetadataObject.ObjectType
    var onScanComplete: ((String) -> Void)?
    @Binding var isFlashlightOn: Bool
    @State private var scanRectangleColor: UIColor = .red
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: BarcodeScannerView
        private var lastScannedBarcode: String?
        private var lastScanTime: Date = Date.distantPast
        private var audioPlayer: AVAudioPlayer?
        
        init(parent: BarcodeScannerView) {
            self.parent = parent
            super.init()
            self.prepareSound()
        }
        
        func prepareSound() {
            if let soundURL = Bundle.main.url(forResource: "scan_success", withExtension: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    audioPlayer?.prepareToPlay()
                } catch {
                    print("❌ Error loading scan sound")
                }
            }
        }
        
        func playScanSound() {
            audioPlayer?.play()
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
                DispatchQueue.main.async {
                    self.parent.scanRectangleColor = .red
                }
                return
            }
            
            if let barcode = metadataObject.stringValue {
                let currentTime = Date()
                if barcode == lastScannedBarcode && currentTime.timeIntervalSince(lastScanTime) < 1.5 {
                    return
                }
                
                lastScannedBarcode = barcode
                lastScanTime = currentTime
                
                DispatchQueue.main.async {
                    self.parent.scanRectangleColor = .green
                    self.parent.scannedCode = barcode
                    self.parent.onScanComplete?(barcode)
                    self.playScanSound()  // ✅ Play sound when a barcode is detected
                }
            }
        }
    }
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        let metadataOutput = AVCaptureMetadataOutput()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return UIViewController()
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return UIViewController()
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8]
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        let viewController = UIViewController()
        let previewView = UIView(frame: UIScreen.main.bounds)
        viewController.view.addSubview(previewView)
        previewLayer.frame = previewView.layer.bounds
        previewView.layer.addSublayer(previewLayer)
        
        let overlayView = createScanOverlay(in: viewController.view)
        overlayView.tag = 999
        viewController.view.addSubview(overlayView)
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let oldOverlay = uiViewController.view.viewWithTag(999) {
            oldOverlay.removeFromSuperview()
        }
        
        let newOverlay = createScanOverlay(in: uiViewController.view)
        newOverlay.tag = 999
        uiViewController.view.addSubview(newOverlay)
        
        toggleFlashlight(on: isFlashlightOn)
    }
    
    func createScanOverlay(in view: UIView) -> UIView {
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.clear
        
        let (scanWidth, scanHeight): (CGFloat, CGFloat) = {
            if barcodeType == .ean8 {
                return (view.bounds.width * 0.6, view.bounds.width * 0.3)
            } else {
                return (view.bounds.width * 0.8, view.bounds.width * 0.3)
            }
        }()
        
        let scanX = (view.bounds.width - scanWidth) / 2
        let scanY = (view.bounds.height - scanHeight) / 2
        
        let scanRect = UIView(frame: CGRect(x: scanX, y: scanY, width: scanWidth, height: scanHeight))
        scanRect.layer.borderColor = scanRectangleColor.cgColor
        scanRect.layer.borderWidth = 2.0
        scanRect.backgroundColor = UIColor.clear
        
        overlayView.addSubview(scanRect)
        return overlayView
    }
    
    func toggleFlashlight(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("❌ Error toggling flashlight")
        }
    }
    
    func dismissScanner() {
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    BarcodeScannerView(
        scannedCode: .constant(nil),
        barcodeType: .ean13,
        onScanComplete: { code in
            print("Scanned: \(code)")
        },
        isFlashlightOn: .constant(false)
    )
}
