//
//  ImageFieldPicker.swift
//  Stash House
//
//  Created by Justin Trubela on 4/8/25.
//


import SwiftUI
import PhotosUI

struct ImageFieldPicker: View {
    @Binding var selectedImageData: Data?
    @State private var showDocumentPicker = false
    @State private var showCamera = false
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        VStack {
            // Image picker buttons
            Section(header: Text("Image")) {
                // Photo library picker
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Pick from Photos")
                    }
                }
                .task(id: selectedItem) {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
                
                // Import image from Files
                Button {
                    showDocumentPicker = true
                } label: {
                    HStack {
                        Image(systemName: "folder")
                        Text("Import from Files")
                    }
                }
                .sheet(isPresented: $showDocumentPicker) {
                    ImageDocumentPicker { data in
                        selectedImageData = data
                    }
                }
                
                // Take photo with camera
                Button {
                    showCamera = true
                } label: {
                    HStack {
                        Image(systemName: "camera")
                        Text("Take a Photo")
                    }
                }
                .sheet(isPresented: $showCamera) {
                    CameraCaptureView { data in
                        selectedImageData = data
                    }
                }
            }
            
            // Show preview of selected image
            if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(8)
            }
        }
    }
}
