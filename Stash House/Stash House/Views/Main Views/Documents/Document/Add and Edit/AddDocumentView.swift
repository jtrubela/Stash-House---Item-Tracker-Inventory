//
//  AddDocumentView.swift
//  Stash House
//
//  Created by Justin Trubela on 4/8/25.
//

import SwiftUI
import PhotosUI

struct AddDocumentView: View {
    // Fetch list of categories from Core Data
    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
    ) var categories: FetchedResults<Category>
    @State private var selectedCategory: Category?
    
    // Core Data and dismissal environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // User input fields
    @State private var title = ""
    @State private var barcode = ""
    
    // Image selection states
    @State private var image = Image(systemName: "question.mark")
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showDocumentPicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showCamera = false
    
    var preselectedCategory: String? = nil

    
    @State private var notes = ""
    
    // Custom fields for categories
    @State private var director = ""
    @State private var releaseYear = ""
    @State private var cardNumber = ""
    @State private var playerName = ""
    @State private var platform = ""
    @State private var publisher = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Basic item info
                Section(header: Text("Basic Info")) {
                    TextField("Title", text: $title)
                }
                
                // Image input options
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
                    
                    // Show preview of selected image
                    if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(8)
                    }
                }
                
                // Optional barcode input
                Section(header: Text("Additional fields")){
                    TextField("Barcode", text: $barcode)
                }
                
                // Category selection and related fields
                Section(header: Text("Category")) {
                    Picker("Select a Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.name ?? "Unnamed").tag(category as Category?)
                        }
                    }
                    // Show conditional fields based on selected category
                    categorySpecificFields()
                }
                
                // General notes
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Collectible")
            .toolbar {
                // Save button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                }
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        // Auto-seed default categories if none exist
        .onAppear{
            seedDefaultCategoriesIfNeeded()

            if let preselected = preselectedCategory {
                selectedCategory = categories.first(where: { $0.name == preselected })
            }
        }
    }
    
    // Save the new item into Core Data
    func saveItem() {
        print("Selected Category: \(selectedCategory?.name ?? "nil")")
        
        let newItem = Item(context: viewContext)
        newItem.id = UUID()
        newItem.title = title
        newItem.barcode = barcode
        newItem.timestamp = Date()
        
        // Default to "Uncategorized" if no category selected
        let finalCategory = selectedCategory ?? categories.first(where: { $0.name == "Uncategorized" }) ?? {
            let uncategorized = Category(context: viewContext)
            uncategorized.id = UUID()
            uncategorized.name = "Uncategorized"
            return uncategorized
        }()
        
        newItem.categoryEntity = finalCategory
        
        // Merge base notes with extra info depending on category
        var combinedNotes = notes
        if finalCategory.name == "Movie" {
            combinedNotes += "\nDirector: \(director)\nYear: \(releaseYear)"
        } else if finalCategory.name == "Trading Card" {
            combinedNotes += "\nPlayer: \(playerName)\nCard #: \(cardNumber)"
        } else if finalCategory.name == "Video Game" {
            combinedNotes += "\nPlatform: \(platform)\nPublisher: \(publisher)"
        }
        newItem.notes = combinedNotes
        
        // Attach selected image
        if let imageData = selectedImageData {
            newItem.image = imageData
        }
        
        // Attempt to save and dismiss
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("❌ Failed to save item: \(error.localizedDescription)")
        }
    }
    
    // Seed Core Data with default categories if none exist
    func seedDefaultCategoriesIfNeeded() {
        let defaults = ["Movie", "Trading Card", "Video Game", "Comic Book", "Toy"]
        for name in defaults {
            if !categories.contains(where: { $0.name == name }) {
                let newCat = Category(context: viewContext)
                newCat.id = UUID()
                newCat.name = name
            }
        }
        try? viewContext.save()
    }
    
    // Conditional custom fields per category
    @ViewBuilder
    func categorySpecificFields() -> some View {
        if selectedCategory?.name == "Movie" {
            Section(header: Text("Movie Info")) {
                TextField("Director", text: $director)
                TextField("Release Year", text: $releaseYear)
            }
        } else if selectedCategory?.name == "Trading Card" {
            Section(header: Text("Card Info")) {
                TextField("Player Name", text: $playerName)
                TextField("Card Number", text: $cardNumber)
            }
        } else if selectedCategory?.name == "Video Game" {
            Section(header: Text("Game Info")) {
                TextField("Platform", text: $platform)
                TextField("Publisher", text: $publisher)
            }
        }
    }
}
