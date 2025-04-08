//
//  ImageSourceSelectorView.swift
//  Stash House
//
//  Created by Justin Trubela on 4/8/25.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import UIKit

struct ImageSourceSelectorView: View {
    @Binding var selectedImageData: Data?
    
    @State private var showDocumentPicker = false
    @State private var showCamera = false
    
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        Section(header: Text("Image")) {
            // ✅ Native PhotosPicker (no .sheet)
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("Pick from Photos", systemImage: "photo.on.rectangle")
            }
            
            // 📁 Import from Files (uses .sheet)
            Button {
                showDocumentPicker = true
            } label: {
                Label("Import from Files", systemImage: "folder")
            }
            
            // 📷 Take a Photo (uses .sheet)
            Button {
                showCamera = true
            } label: {
                Label("Take a Photo", systemImage: "camera")
            }
            
            // Image preview
            if let imageData = selectedImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(8)
            }
        }
        // Show Document Picker
        .sheet(isPresented: $showDocumentPicker) {
            ImageDocumentPicker { data in
                selectedImageData = data
            }
        }
        // Show Camera Capture view
        .sheet(isPresented: $showCamera) {
            CameraCaptureView { data in
                selectedImageData = data
            }
        }
        // Get image result from PhotosPicker
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }
}





import SwiftUI
import PhotosUI
import UIKit
import UniformTypeIdentifiers

struct ImageSourceActionSheet: UIViewControllerRepresentable {
    @Binding var selectedImageData: Data?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate {
        var parent: ImageSourceActionSheet
        
        init(parent: ImageSourceActionSheet) {
            self.parent = parent
        }
        
        // MARK: UIImagePickerControllerDelegate (Photo + Camera)
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.8) {
                parent.selectedImageData = data
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        // MARK: UIDocumentPickerDelegate (Files)
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                if let data = try? Data(contentsOf: url) {
                    parent.selectedImageData = data
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Library", style: .default) { _ in
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = context.coordinator
                controller.present(picker, animated: true)
            })
            
            alert.addAction(UIAlertAction(title: "File", style: .default) { _ in
                let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .jpeg, .png])
                documentPicker.delegate = context.coordinator
                controller.present(documentPicker, animated: true)
            })
            
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.cameraCaptureMode = .photo
                picker.delegate = context.coordinator
                controller.present(picker, animated: true)
            })
            
            alert.addAction(UIAlertAction(title: "Paste", style: .default) { _ in
                if let image = UIPasteboard.general.image,
                   let data = image.jpegData(compressionQuality: 0.8) {
                    selectedImageData = data
                }
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            controller.present(alert, animated: true)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}





struct MyImagePickerView: View {
    @State private var selectedImageData: Data?
    @State private var showActionSheet = false
    
    var body: some View {
        VStack {
            Button("Choose Image") {
                showActionSheet = true
            }
            .font(.headline)
            .padding()
//            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            
            if let data = selectedImageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(8)
            }
        }
        .sheet(isPresented: $showActionSheet) {
            ImageSourceActionSheet(selectedImageData: $selectedImageData)
        }
    }
}
