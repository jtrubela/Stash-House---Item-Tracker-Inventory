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
