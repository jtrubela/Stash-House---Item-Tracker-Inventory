//
//  ImageDocumentPicker.swift
//  Stash House
//
//  Created by Justin Trubela on 4/8/25.
//


import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ImageDocumentPicker: UIViewControllerRepresentable {
    var onImagePicked: (Data) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [
            .image,
            .jpeg,
            .png,
            .heic,
            .tiff,
            UTType("public.jpeg"),
            UTType("public.png")
        ].compactMap { $0 }


        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onImagePicked: (Data) -> Void
        
        init(onImagePicked: @escaping (Data) -> Void) {
            self.onImagePicked = onImagePicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Securely access file
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let data = try Data(contentsOf: url)
                onImagePicked(data)
            } catch {
                print("❌ Failed to load image data from file: \(error)")
            }
        }

    }
}
