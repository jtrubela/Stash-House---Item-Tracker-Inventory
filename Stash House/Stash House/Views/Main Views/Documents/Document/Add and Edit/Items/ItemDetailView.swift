//
//  ItemListView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/25/25.
//

import SwiftUI
import CoreData

struct ItemListView: View {
    @State private var showAddOptions = false
    @State private var showManualAddView = false
    @State private var selectedOption: AddOption? = nil
    
    @EnvironmentObject var viewModel: ContentViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch items from Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default
    ) private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationView {
            VStack {
                // Grid layout for items
                ItemGridView(
                    items: items.filter {
                        viewModel.searchText.isEmpty || ($0.title?.localizedCaseInsensitiveContains(viewModel.searchText) ?? false)
                    },
                    isEditing: false, // Editing state controlled by toolbar
                    selectedItems: Set<Item>(), // Placeholder for selection logic
                    toggleSelection: { _ in }
                )
                
                // Add button for options (modal)
                Button(action: {
                    showAddOptions = true
                }) {
                    Text("Add New Item")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .sheet(isPresented: $showAddOptions) {
                    AddOptionsModalView(selectedOption: $selectedOption, isScanning: $viewModel.isScanning)
                }

                
                // Show AddDocumentView when an option is selected
                /*
                 if let option = selectedOption {
                 AddDocumentView(preselectedCategory: option.rawValue) // Pass selected category to AddDocumentView
                 }
                 */
            }
        }
    }
}


//
//  ItemDetailView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//


struct ItemDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let item: Item
    @State private var scannedBarcode: String?
    @State private var scannedBarcodes: Set<String> = []
    
    var body: some View {
        VStack {
            Text(item.name ?? "Unknown Item")
                .font(.largeTitle)
                .padding()
            
            if let imageData = item.image, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            } else {
                Text("No Image Available")
                    .foregroundColor(.gray)
            }
            
            Text("Category: \(item.category ?? "N/A")")
                .font(.headline)
            
            Text("Notes: \(item.notes ?? "No Notes")")
                .padding()
            
            // Display scanned barcode
            if let barcode = scannedBarcode {
                Text("Barcode: \(barcode)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding()
            }
            
            // New button to navigate to Barcode Scanner
            NavigationLink(destination: BarcodeScanScreen(scannedCode: $scannedBarcode, scannedBarcodes: $scannedBarcodes)) {
                Text("Scan Barcode")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Item Details")
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    
    let sampleItem = Item(context: context)
    sampleItem.name = "Vintage Watch"
    sampleItem.category = "Accessories"
    sampleItem.notes = "This is a limited edition timepiece."
    
    // Optional: Include mock image
    if let image = UIImage(systemName: "clock") {
        sampleItem.image = image.pngData()
    }
    
    return NavigationView {
        ItemDetailView(item: sampleItem)
            .environment(\.managedObjectContext, context)
    }
}




//
//  AddedItemDetailView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//


import SwiftUI

struct AddedItemDetailView: View {
    let barcode: String
    @State private var navigateToSearches = false
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isAdded = false
    
    @Environment(\.dismiss) private var dismiss
    var onComplete: (([String]) -> Void)? = nil
    
    @State private var navigateToSingleAdd = false
    
    
    
    var body: some View {
        VStack {
            NavigationLink(
                //                destination: ItemDetailSearchesView(barcode: barcode)
                //                    .environmentObject(EbayAuthManager.shared)
                //                    .environmentObject(TMDBAuthManager.shared),
                destination: EmptyView(),
                isActive: $navigateToSearches
            ) {
                EmptyView()
            }
            .hidden()
            
            Text("Item Details")
                .font(.title)
                .padding()
            
            Text("Barcode: \(barcode)")
                .font(.headline)
                .padding()
            
            Button(action: {
                let newItem = Item(context: viewContext)
                newItem.id = UUID()
                newItem.barcode = barcode
                newItem.name = "New Item from Barcode"
                newItem.notes = "Manually added from scan."
                newItem.category = "Unknown"
                
                do {
                    try viewContext.save()
                    isAdded = true
                    onComplete?([barcode])
                    dismiss() // ✅ Dismisses the BarcodeScanScreen sheet
                } catch {
                    print("❌ Error saving item: \(error.localizedDescription)")
                }
            }) {
                Text(isAdded ? "✅ Added!" : "Add to Library")
                    .padding()
                    .background(isAdded ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isAdded)
            .padding()
        }
    }
}

struct AddItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AddedItemDetailView(barcode: "00100860105891")
    }
}


//
//  BulkAddDetailsView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//


//import SwiftUI

struct BulkAddDetailsView: View {
    @State var scannedBarcodes: [String]
    var selectedBarcode: String?  // ✅ Highlights the selected barcode
    var onComplete: (([String]) -> Void)?
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var isAdded = false
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Add Details")
                    .font(.title)
                    .padding()
                
                List {
                    ForEach(scannedBarcodes, id: \.self) { barcode in
                        NavigationLink(destination: AddedItemDetailView(barcode: barcode)) {
                            Text(barcode)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(barcode == selectedBarcode ? Color.yellow.opacity(0.3) : Color.clear)  // ✅ Highlight selected barcode
                        }
                    }
                    .onDelete(perform: deleteBarcode)
                }
                
                Button(action: {
                    for barcode in scannedBarcodes {
                        let newItem = Item(context: viewContext)
                        newItem.id = UUID()
                        newItem.name = "New Item"
                        newItem.notes = "Scanned in bulk add."
                        newItem.barcode = barcode
                        newItem.category = "Uncategorized"
                    }
                    
                    do {
                        try viewContext.save()
                        isAdded = true
                        onComplete?([])
                        dismiss() // ✅ This will dismiss the BarcodeScanScreen sheet
                    } catch {
                        print("❌ Failed to save bulk items: \\(error)")
                    }
                }) {
                    Text(isAdded ? "✅ Added to Library" : "Add All to Library")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isAdded ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isAdded)
                .padding()
                
                
            }
        }
    }
    
    // ✅ Allows deletion of a barcode
    func deleteBarcode(at offsets: IndexSet) {
        scannedBarcodes.remove(atOffsets: offsets)
    }
}

struct BulkAddDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            BulkAddDetailsView(
                scannedBarcodes: ["123456789012", "987654321098", "555555555555"],
                selectedBarcode: "987654321098",
                onComplete: { selected in
                    print("Selected: \(selected)")
                }
                
            )    }
    }
}



struct ItemDetailsSheet: View {
    @Binding var itemName: String
    @Binding var itemCategory: String
    @Binding var itemNotes: String
    
    var body: some View {
        NavigationView {
            Form{
                TextField("Item Name", text: $itemName)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                TextField("Category", text: $itemCategory)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                TextEditor(text: $itemNotes)
                    .frame(height: 150)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AnimatedSearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            TextField("Search...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .onTapGesture {
                    self.isEditing = true
                }
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
            
            if isEditing {
                Button("Cancel") {
                    self.isEditing = false
                    self.text = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .transition(.move(edge: .trailing))
                .animation(.default, value: isEditing)
            }
        }
        .padding(.horizontal)
    }
}


struct TitleTextView: View {
    let titleText: String
    
    var body: some View {
        Text(titleText)
            .font(.title3)
            .fixedSize(horizontal: false, vertical: true)
    }
}


struct PosterImageView: View {
    let path: String?
    
    var body: some View {
        if let path = path, let url = URL(string: "https://image.tmdb.org/t/p/w92\(path)") {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 100, maxHeight: .infinity)
                    .cornerRadius(6)
                
            } placeholder: {
                Color.gray.opacity(0.2)
                    .frame(maxWidth: 60, maxHeight: .infinity)
                    .cornerRadius(6)
            }
            .padding(.leading, 5)
            .padding(.vertical, 5)
        }
    }
}

struct ReleaseDateView: View {
    let dateString: String
    
    var body: some View {
        Text("Release: \(dateString)")
            .foregroundColor(.secondary)
    }
}

struct RatingSummaryView: View {
    let rating: String
    
    var body: some View {
        Text(rating)
            .foregroundColor(.secondary)
    }
}

struct OverviewTextView: View {
    let overviewText: String
    
    var body: some View {
        Text(overviewText)
            .foregroundColor(.gray)
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
    }
}



