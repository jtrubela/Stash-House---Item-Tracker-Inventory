//
//  ImageFieldPicker.swift
//  Stash House
//
//  Created by Justin Trubela on 4/8/25.
//


import SwiftUI
import PhotosUI
//
//struct ImageFieldPicker: View {
//    @Binding var selectedImageData: Data?  // Binding to store the selected image data
//    @State private var showPickerOptions = false  // Toggle for the picker options
//    @State private var showDocumentPicker = false  // Flag to show document picker
//    @State private var showCamera = false  // Flag to show camera
//    @State private var showPhotoPicker = false  // Flag to show PhotosPicker sheet
//    
//    @State private var selectedItem: PhotosPickerItem? = nil  // The selected photo item
//    
//    var body: some View {
//        VStack {
//            Button(action: {
//                showPickerOptions.toggle()  // Show the picker options dialog
//            }) {
//                HStack {
//                    Image(systemName: "photo.on.rectangle")
//                    Text("Choose Image")
//                }
//                .padding()
//                .background(Color.blue.opacity(0.1))
//                .cornerRadius(10)
//            }
//            .confirmationDialog("Choose Image Source", isPresented: $showPickerOptions, titleVisibility: .visible) {
//                    Button(action: {
//                        DispatchQueue.main.async {
//                            showPhotoPicker = true
//                        }
//                    }) {
//                        Label("Pick from Photos", systemImage: "photo.on.rectangle")
//                    }
//                Button("Import from Files") {
//                    showDocumentPicker = true  // Show the document picker for file import
//                }
//                Button("Take a Photo") {
//                    showCamera = true  // Show camera for taking a new photo
//                }
//                Button("Cancel", role: .cancel) {}  // Cancel button
//            }
//            
//            // Display selected image preview if image data exists
//            if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 150)
//                    .cornerRadius(8)
//            }
//        }
//        // Photo Picker Sheet
//        .sheet(isPresented: $showPhotoPicker) {
//            PhotosPicker(
//                "show photo picker", selection: $selectedItem,
//                matching: .images,
//                photoLibrary: .shared()
//            )
//        }
//
//        .sheet(isPresented: $showDocumentPicker) {
//            // Document picker for file imports
//            ImageDocumentPicker { data in
//                selectedImageData = data
//            }
//        }
//        .sheet(isPresented: $showCamera) {
//            // Camera capture view for taking a new photo
//            CameraCaptureView { data in
//                selectedImageData = data
//            }
//        }
//        // Loading the image data after selection from PhotosPicker
//        .task(id: selectedItem) {
//            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
//                selectedImageData = data
//            }
//        }
//    }
//}


//struct PhotosPickerView: View {
//    @Binding var selectedItem: PhotosPickerItem?
//    @Binding var selectedImageData: Data?
//    
//    var body: some View {
//        PhotosPicker(
//            "Pick a photo", selection: $selectedItem,  // Bind the selection to selectedItem
//            matching: .images,  // Only show images
//            photoLibrary: .shared()  // Use the shared photo library
//        )
//        .onChange(of: selectedItem) { newItem in
//            Task {
//                // Load the image data after selection
//                if let data = try? await newItem?.loadTransferable(type: Data.self) {
//                    selectedImageData = data
//                }
//            }
//        }
//    }
//}
