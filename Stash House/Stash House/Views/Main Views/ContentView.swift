//
//  ContentView.swift
//  Stash House
//
//  Created by Justin Trubela on 6/30/23.
//
import SwiftUI

struct ContentView: View {
    //Inject Core Data into this view
    @Environment(\.managedObjectContext) private var viewContext
    @State private var scannedCode: String? = nil
    @State private var scannedItems: [ScannedItem] = []
    @State private var isScanning = false
    @State private var showFileImporter = false
    @State private var searchText = ""
    @State private var selectedTab: Int = 0 // 0: Library, 1: MyCollections
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Main content based on the selected tab
                if selectedTab == 0 {
                    LibraryView(
                        isScanning: $isScanning,
                        showFileImporter: $showFileImporter,
                        searchText: $searchText
                    )

                } else {
                    MyCollection()
                }
                
                // Bottom toolbar for switching views
                HStack {
                    Spacer()
                    Button(action: { selectedTab = 0 }) {
                        VStack {
                            Image(systemName: "books.vertical")
                            Text("Library")
                        }
                    }
                    Spacer()
                    Button(action: { selectedTab = 1 }) {
                        VStack {
                            Image(systemName: "list.bullet")
                            Text("My Collections")
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.systemGray6))
            }
            .navigationBarTitle(selectedTab == 0 ? "Library" : "My Collections", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

    }
}


//
//  LibraryView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//

//import SwiftUI
import CoreData

struct LibraryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default
    ) private var items: FetchedResults<Item>
    
    
    //scanned code
    @State private var scannedCode: String? = nil

    @Binding var isScanning: Bool
    @Binding var showFileImporter: Bool
    @Binding var searchText: String
    
    //Add item button
    @State private var showAddOptions = false
    @State private var showManualAddView = false
    @State private var showSearchView = false
    
    
    // Selection state
    @State private var isEditing = false
    @State private var selectedItems: Set<Item> = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                    ForEach(items.filter { searchText.isEmpty || ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false) }) { item in
                        ZStack(alignment: .topTrailing) {
                            NavigationLink(destination: EditCollectibleView(item: item)) {
                                VStack {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                        .cornerRadius(10)
                                    Text(item.title ?? "Untitled")
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                    Text(item.category ?? "")
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.2)))
                            }
                            .opacity(isEditing ? 0.6 : 1)
                            
                            if isEditing {
                                Button(action: {
                                    toggleSelection(for: item)
                                }) {
                                    Image(systemName: selectedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedItems.contains(item) ? .blue : .gray)
                                        .padding(6)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Library")
            .searchable(text: $searchText)
            .toolbar {
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
                            Button(action: deleteSelectedItems) {
                                Image(systemName: "trash")
                            }
                        }
                        
                        Button(action: {
                            showAddOptions = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .actionSheet(isPresented: $showAddOptions) {
                            ActionSheet(title: Text("Add New Item"), buttons: [
                                .default(Text("Scan a Barcode")) {
                                    isScanning = true
                                },
                                .default(Text("Search for an Item")) {
                                    showSearchView = true
                                },
                                .default(Text("Add Manually")) {
                                    showManualAddView = true
                                },
                                .cancel()
                            ])
                        }
                        
                        Button(action: { showFileImporter = true }) {
                            Image(systemName: "folder.badge.plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $isScanning) {
                BarcodeScanScreen(scannedCode: $scannedCode)
            }

            
            .sheet(isPresented: $showManualAddView) {
                AddCollectibleView() // Manual form view you already created
            }
            
            .sheet(isPresented: $showSearchView) {
                //SearchCollectibleView() // Replace with your actual search view
            }
            
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json]) { result in
                switch result {
                    case .success(let url):
                        importJSON(from: url)
                    case .failure(let error):
                        print("❌ File import failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Selection
    
    private func toggleSelection(for item: Item) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }
    
    private func deleteSelectedItems() {
        for item in selectedItems {
            viewContext.delete(item)
        }
        
        do {
            try viewContext.save()
            selectedItems.removeAll()
            isEditing = false
        } catch {
            print("❌ Error deleting items: \(error.localizedDescription)")
        }
    }
    
    // MARK: - JSON Import
    
    private func importJSON(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decodedCards = try JSONDecoder().decode([CollectibleCard].self, from: data)
            
            for card in decodedCards {
                let newItem = Item(context: viewContext)
                newItem.id = UUID()
                newItem.title = card.cardTitle
                newItem.barcode = "\(card.cardNumber)"
                newItem.category = "Trading Card"
                newItem.timestamp = Date()
                newItem.notes = "Imported from file"
            }
            
            try viewContext.save()
        } catch {
            print("❌ Error decoding JSON: \(error.localizedDescription)")
        }
    }
}




//import SwiftUI

struct AddCollectibleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory = "Movie"
    @State private var title = ""
    @State private var barcode = ""
    @State private var notes = ""
    
    // Custom fields
    @State private var director = ""
    @State private var releaseYear = ""
    @State private var cardNumber = ""
    @State private var playerName = ""
    @State private var platform = ""
    @State private var publisher = ""
    
    let categories = ["Movie", "Trading Card", "Video Game", "Comic Book", "Toy"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category")) {
                    Picker("Select Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Basic Info")) {
                    TextField("Title", text: $title)
                    TextField("Barcode", text: $barcode)
                }
                
                // Custom Fields by Category
                if selectedCategory == "Movie" {
                    Section(header: Text("Movie Info")) {
                        TextField("Director", text: $director)
                        TextField("Release Year", text: $releaseYear)
                    }
                } else if selectedCategory == "Trading Card" {
                    Section(header: Text("Card Info")) {
                        TextField("Player Name", text: $playerName)
                        TextField("Card Number", text: $cardNumber)
                    }
                } else if selectedCategory == "Video Game" {
                    Section(header: Text("Game Info")) {
                        TextField("Platform", text: $platform)
                        TextField("Publisher", text: $publisher)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Collectible")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func saveItem() {
        let newItem = Item(context: viewContext)
        newItem.id = UUID()
        newItem.title = title
        newItem.barcode = barcode
        newItem.category = selectedCategory
        newItem.timestamp = Date()
        
        // Combine notes + custom fields
        var combinedNotes = notes
        if selectedCategory == "Movie" {
            combinedNotes += "\nDirector: \(director)\nYear: \(releaseYear)"
        } else if selectedCategory == "Trading Card" {
            combinedNotes += "\nPlayer: \(playerName)\nCard #: \(cardNumber)"
        } else if selectedCategory == "Video Game" {
            combinedNotes += "\nPlatform: \(platform)\nPublisher: \(publisher)"
        }
        
        newItem.notes = combinedNotes
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("❌ Failed to save item: \(error.localizedDescription)")
        }
    }
}


struct EditCollectibleView: View {
    @ObservedObject var item: Item
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                TextField("Title", text: Binding($item.title, default: ""))
                TextField("Barcode", text: Binding($item.barcode, default: ""))
                TextField("Category", text: Binding($item.category, default: ""))
            }
            
            Section(header: Text("Notes")) {
                TextEditor(text: Binding($item.notes, default: ""))
                    .frame(height: 100)
            }
            
            Section {
                Button("Save Changes") {
                    saveItem()
                }
                .foregroundColor(.blue)
            }
        }
        .navigationTitle("Edit Collectible")
    }
    
    func saveItem() {
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("❌ Error saving changes: \(error.localizedDescription)")
        }
    }
}

extension Binding {
    init(_ source: Binding<Value?>, default defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}




//
//  MyCollection.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//


//import SwiftUI
import CodeScanner  // ✅ Import CodeScanner framework
import AVFoundation


struct MyCollection: View {
    @State private var selectedType: CollectionType = .cards
    @State private var isScanning = false
    @State private var scannedItems: [ScannedItem] = []
    @State private var scannedCode: String? = nil

    
    var collections: [Collection] {
        switch selectedType {
            case .cards:
                return [
                    Collection(name: "Pokemon", items: [
                        Collectible(name: "Pikachu", imageName: "pikachu"),
                        Collectible(name: "Charizard", imageName: "charizard")
                    ]),
                    Collection(name: "Yu-Gi-Oh", items: [
                        Collectible(name: "Dark Magician", imageName: "dark_magician"),
                        Collectible(name: "Blue-Eyes White Dragon", imageName: "blue_eyes")
                    ]),
                    Collection(name: "Baseball Cards", items: baseballCardItems)
                ]
            case .media:
                return [
                    Collection(name: "Nintendo Consoles", items: [
                        Collectible(name: "Nintendo Switch", imageName: "switch"),
                        Collectible(name: "GameCube", imageName: "gamecube")
                    ]),
                    Collection(name: "Movies - DVD", items: [
                        Collectible(name: "The Matrix", imageName: "matrix"),
                        Collectible(name: "Inception", imageName: "inception")
                    ])
                ]
            case .other:
                return [
                    Collection(name: "Stamps", items: [
                        Collectible(name: "Rare Stamp A", imageName: "stamp_a"),
                        Collectible(name: "Rare Stamp B", imageName: "stamp_b")
                    ])
                ]
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Select Type", selection: $selectedType) {
                    ForEach(CollectionType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                ScrollView(.vertical) {
                    HStack(spacing: 16) {
                        ForEach(collections) { collection in
                            NavigationLink(destination: CollectionViewer(images: collection.items)) {
                                VStack {
                                    if collection.items.first != nil {
                                        PlaceholderView()
                                    }
                                    Text(collection.name)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Collections")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isScanning = true }) {
                        Image(systemName: "barcode.viewfinder")
                    }
                }
            }
            .sheet(isPresented: $isScanning) {
                BarcodeScannerView(
                    scannedCode: $scannedCode,
                    barcodeType: .ean13,
                    onScanComplete: { code in
                        print("Scanned: \(code)")
                    },
                    isFlashlightOn: .constant(false)
                )
            }
        }
    }
}




struct CollectionsViewer: View {
    @State var images: [Collectible]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(images) { item in
                    NavigationLink(destination: CollectibleDetailView(item: item)) {
                        HStack {
                            Image(item.imageName)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                            Text(item.name)
                                .font(.headline)
                        }
                        .padding()
                    }
                }
            }
            .padding()
        }
    }
}

struct CollectibleDetailView: View {
    let item: Collectible
    
    var body: some View {
        VStack(spacing: 20) {
            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .cornerRadius(12)
            Text(item.name)
                .font(.title)
                .bold()
            Spacer()
        }
        .padding()
        .navigationTitle(item.name)
    }
}





struct CollectionViewer: View {
    @State var images: [Collectible]  // Updated from CollectibleItem to Collectible
    @State var flipDegrees: Double = 0
    @State var offset: CGSize = .zero
    @State var isTopCardSelected: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                ZStack {
                    ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                        CardView(image)
                            .offset(index == 0 ? offset : CGSize(width: CGFloat(index) * -10, height: CGFloat(index) * -7))
                            .rotation3DEffect(.degrees(index == 0 ? flipDegrees : 0), axis: (x: 0, y: 1, z: 0))
                            .zIndex(Double(images.count - index))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if index == 0 || isTopCardSelected {
                                            offset = value.translation
                                        }
                                    }
                                    .onEnded { value in
                                        if index == 0 || isTopCardSelected {
                                            let direction: CGFloat = value.translation.width > 0 ? 1 : -1
                                            swipeCard(direction: direction)
                                        }
                                    }
                            )
                    }
                }
                .frame(width: 200, height: 300)
                .padding(.horizontal)
            }
        }
    }
    
    func swipeCard(direction: CGFloat) {
        withAnimation(.easeInOut(duration: 1.0)) {
            flipDegrees += 360 * direction
            offset = CGSize(width: direction * 500, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                if let removedCard = images.first {
                    images.append(removedCard)
                    images.removeFirst()
                }
                flipDegrees = 0
                offset = .zero
                isTopCardSelected = false
            }
        }
    }
}

@ViewBuilder
func CardView(_ collectibleItem: Collectible) -> some View {
    Image(collectibleItem.imageName)
        .resizable()
        .scaledToFit()
        .frame(width: 180, height: 250)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(radius: 5)
        )
}


//
//  MyCollectionsView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//

//import SwiftUI

struct MyCollectionsView: View {
    @State private var selectedType: CollectionType = .cards
    @State private var isScanning = false
    @State private var scannedItems: [ScannedItem] = []
    @State private var scannedCode: String? = nil

    
    var collections: [Collection] {
        switch selectedType {
            case .cards:
                return [
                    Collection(name: "Pokemon", items: [
                        Collectible(name: "Pikachu", imageName: "pikachu"),
                        Collectible(name: "Charizard", imageName: "charizard")
                    ]),
                    Collection(name: "Yu-Gi-Oh", items: [
                        Collectible(name: "Dark Magician", imageName: "dark_magician"),
                        Collectible(name: "Blue-Eyes White Dragon", imageName: "blue_eyes")
                    ]),
                    Collection(name: "Baseball Cards", items: BaseballCards) // ✅ Now Defined
                ]
            case .media:
                return [
                    Collection(name: "Nintendo Consoles", items: [
                        Collectible(name: "Nintendo Switch", imageName: "switch"),
                        Collectible(name: "GameCube", imageName: "gamecube")
                    ]),
                    Collection(name: "Movies - DVD", items: [
                        Collectible(name: "The Matrix", imageName: "matrix"),
                        Collectible(name: "Inception", imageName: "inception")
                    ])
                ]
            case .other:
                return [
                    Collection(name: "Stamps", items: [
                        Collectible(name: "Rare Stamp A", imageName: "stamp_a"),
                        Collectible(name: "Rare Stamp B", imageName: "stamp_b")
                    ])
                ]
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Select Type", selection: $selectedType) {
                    ForEach(CollectionType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                ScrollView(.horizontal) {
                    HStack(spacing: 16) {
                        ForEach(collections) { collection in
                            NavigationLink(destination: CollectionViewer(images: collection.items)) {
                                VStack {
                                    if collection.items.first != nil {
                                        PlaceholderView() // ✅ Acts as a placeholder for collection images
                                    }
                                    Text(collection.name)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Collections")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isScanning = true }) {
                        Image(systemName: "barcode.viewfinder")
                    }
                }
            }
            .sheet(isPresented: $isScanning) {
                BarcodeScanScreen(scannedCode: $scannedCode)
            }
        }
    }
}

struct MyCollectionsView_Previews: PreviewProvider {
    static var previews: some View {
        MyCollectionsView()
    }
}


//
//  PlaceholderView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//

import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 100, height: 100)
            .overlay(Text("Image\nPlaceholder").font(.caption).foregroundColor(.black))
    }
}
struct Placeholder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 100, height: 100)
            .overlay(Text("Image\nPlaceholder").font(.caption).foregroundColor(.black))
    }
}








/* Scanner Files

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

*/
