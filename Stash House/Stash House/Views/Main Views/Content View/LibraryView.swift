//
//  LibraryView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
/*
 ✅ What LibraryView Does
    Displays a scrollable, searchable grid of Core Data Item objects.
    Allows navigation to EditDocumentView for item editing.
    Offers item addition via:
    Barcode scan (BarcodeScanScreen)
    Manual add (AddDocumentView)
    Search (commented out SearchCollectibleView)
    JSON import.
    Supports multi-select delete in edit mode.
    Has custom fallback title logic via Item.displayTitle.
    Includes a custom bottom tab bar (LibraryTabToolBar).
 */
//

import SwiftUI
import CoreData


class SelectionManager<T: NSManagedObject & Hashable>: ObservableObject {
    @Published var selectedItems: Set<T> = []
    
    func toggle(_ item: T) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }
    
    func clear() {
        selectedItems.removeAll()
    }
    
    func isSelected(_ item: T) -> Bool {
        selectedItems.contains(item)
    }
    
    func deleteAll(using context: NSManagedObjectContext) {
        for item in selectedItems {
            context.delete(item)
        }
        do {
            try context.save()
            selectedItems.removeAll()
        } catch {
            print("❌ Error deleting items: \(error.localizedDescription)")
        }
    }

}


struct LibraryView: View {
    // Access to Core Data context
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: ContentViewModel
    
    // Fetch items from Core Data, sorted by timestamp (newest first)
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default
    ) private var items: FetchedResults<Item>
    
    
    @State private var selectedOption: AddOption? = nil  // This will track the selected option/category

    
    // Local state
    @State private var scannedCode: String? = nil
    @State private var scannedBarcodes: Set<String> = []
    @State private var showAddOptions = false
    @State private var showManualAddView = false
    @State private var showSearchView = false
    @State private var isEditing = false
    
    @StateObject private var selectionManager = SelectionManager<Item>()

    var body: some View {
        NavigationView {
            ScrollView {
                // Grid layout for items
                ItemGridView(
                    items: items.filter {
                        viewModel.searchText.isEmpty || ($0.title?.localizedCaseInsensitiveContains(viewModel.searchText) ?? false)
                    },
                    isEditing: isEditing,
                    selectedItems: selectionManager.selectedItems,
                    toggleSelection: selectionManager.toggle
                )
                .padding()
            }
            .navigationTitle("Library")
            .searchable(text: $viewModel.searchText)
            .toolbar {
                LibraryToolbar(
                    isEditing: $isEditing,
                    selectedItems: $selectionManager.selectedItems,
                    showAddOptions: $showAddOptions,
                    deleteAction: {
                        selectionManager.deleteAll(using: viewContext)
                        isEditing = false
                    },
                    importAction: { viewModel.showFileImporter = true }
                )
            }
            .sheet(isPresented: $showAddOptions) {
                AddOptionsModalView(
                    selectedOption: $selectedOption,
                    isScanning: $viewModel.isScanning
                )
            }




            // MARK: - Modal Sheets
            .sheet(isPresented: $viewModel.isScanning) {
                BarcodeScanScreen(
                    scannedCode: $scannedCode,
                    scannedBarcodes: $scannedBarcodes,
                    onScanComplete: { newBarcodes in
                        scannedBarcodes = newBarcodes
                    }
                )
            }
            
            .sheet(isPresented: $showManualAddView) {
                AddDocumentView()
            }
            
            .sheet(isPresented: $showSearchView) {
                // SearchCollectibleView()
            }
            
            .fileImporter(isPresented: $viewModel.showFileImporter, allowedContentTypes: [.json]) { result in
                switch result {
                    case .success(let url): viewModel.importJSON(from: url, into: viewContext)
                    case .failure(let error): print("❌ File import failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Item Title Fallback Display
extension Item {
    var displayTitle: String {
        if let title = title, !title.isEmpty {
            return title
        } else if let barcode = barcode, !barcode.isEmpty {
            return barcode
        } else if let name = name, !name.isEmpty {
            return name
        } else if let notes = notes, !notes.isEmpty {
            return notes
        } else {
            return "Untitled"
        }
    }
}

// MARK: - Bottom Tab Toolbar
struct LibraryTabToolBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()
                tabButton(for: tab)
                Spacer()
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
    }
    
    private func tabButton(for tab: Tab) -> some View {
        Button(action: { selectedTab = tab }) {
            VStack {
                Image(systemName: tab.systemImage)
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
                Text(tab.title)
                    .fontWeight(selectedTab == tab ? .bold : .regular)
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    LibraryView()
        .environment(\.managedObjectContext, context)
        .environmentObject(ContentViewModel())
}




struct LibraryToolbar: ToolbarContent {
    @Binding var isEditing: Bool
    @Binding var selectedItems: Set<Item>
    @Binding var showAddOptions: Bool
    var deleteAction: () -> Void
    var importAction: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(isEditing ? "Done" : "Edit") {
                isEditing.toggle()
                if !isEditing {
                    selectedItems.removeAll()
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack {
                if isEditing && !selectedItems.isEmpty {
                    Button(action: deleteAction) {
                        Image(systemName: "trash")
                    }
                }
                
                Button(action: { showAddOptions = true }) {
                    Image(systemName: "plus")
                }
                
                Button(action: importAction) {
                    Image(systemName: "folder.badge.plus")
                }
            }
        }
    }
}


struct ItemCardView: View {
    let item: Item
    let isEditing: Bool
    let isSelected: Bool
    let onToggleSelect: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(destination: EditDocumentView(item: item)) {
                VStack {
                    if let imageData = item.image, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(10)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(10)
                            .foregroundColor(.gray)
                    }
                    
                    Text(item.displayTitle)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Text(item.category ?? "")
                        .font(.subheadline)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.2))
                )
            }
            .opacity(isEditing ? 0.6 : 1)
            
            if isEditing {
                Button(action: onToggleSelect) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .padding(6)
                }
            }
        }
    }
}


struct ItemGridView: View {
    let items: [Item]
    let isEditing: Bool
    let selectedItems: Set<Item>
    let toggleSelection: (Item) -> Void
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
            ForEach(items) { item in
                ItemCardView(
                    item: item,
                    isEditing: isEditing,
                    isSelected: selectedItems.contains(item),
                    onToggleSelect: { toggleSelection(item) }
                )
            }
        }
        .padding()
    }
}

