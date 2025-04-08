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
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("Pick from Photos", systemImage: "photo.on.rectangle")
            }
            
            Button {
                showDocumentPicker = true
            } label: {
                Label("Import from Files", systemImage: "folder")
            }
            
            Button {
                showCamera = true
            } label: {
                Label("Take a Photo", systemImage: "camera")
            }
            
            if let imageData = selectedImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(8)
            }
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            ImageDocumentPicker { data in
                selectedImageData = data
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView { data in
                selectedImageData = data
            }
        }
    }
}
