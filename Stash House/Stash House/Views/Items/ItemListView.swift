//
//  ItemListView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//

import SwiftUI
import CoreData
struct ItemListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)])
    private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        VStack(alignment: .leading) {
                            Text(item.name ?? "Unknown")
                                .font(.headline)
                            Text(item.notes ?? "No details available")
                                .font(.subheadline)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .navigationTitle("Saved Movies")
        }
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    
    let item1 = Item(context: context)
    item1.id = UUID()
    item1.name = "The Matrix"
    item1.notes = "Sci-fi movie with Keanu Reeves"
    
    let item2 = Item(context: context)
    item2.id = UUID()
    item2.name = "Inception"
    item2.notes = "Dream within a dream"
    
    return ItemListView()
        .environment(\.managedObjectContext, context)
}


//
//  ItemDetailView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//


import SwiftUI
import CoreData

struct ItemDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let item: Item
    @State private var scannedBarcode: String?
    
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
            NavigationLink(destination: BarcodeScanScreen(scannedCode: $scannedBarcode)) {
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
//  ItemDetailSearchesView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/25/25.
//


//
//  ItemDetailSearchesView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/25/25.
//


import SwiftUI
import TMDBSwift

struct ItemDetailSearchesView: View {
    let barcode: String
    
    @EnvironmentObject var tmdbAuthManager: TMDBAuthManager
    @EnvironmentObject var ebayAuthManager: EbayAuthManager
    
    @State private var searchText: String = ""
    @State private var tmdbResults: [MovieMDB] = []
    @State private var ebayResults: [EbayProduct] = []
    @State private var isLoadingTMDB = false
    @State private var isLoadingEbay = false
    @State private var hasSearched = false
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    TextField("Search by title or barcode...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button("Search") {
                        performSearch(with: searchText)
                    }
                    .padding(.trailing)
                }
                
                if isLoadingTMDB || isLoadingEbay {
                    ProgressView("Searching...")
                }
                
                if !tmdbResults.isEmpty {
                    Text("🎬 TMDB Results")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    SearchResultDropdown(
                        searchResults: tmdbResults,
                        isLoading: isLoadingTMDB,
                        onSelect: { selectedMovie in
                            TMDBService.getMovieDetails(movieID: selectedMovie.id ?? -1) { detailed in
                                if let movie = detailed {
                                    TMDBService.saveMovieToCoreData(movie)
                                }
                            }
                        }
                    )
                }
                
                if !ebayResults.isEmpty {
                    Text("🛒 eBay Results")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(ebayResults) { product in
                        VStack(alignment: .leading) {
                            Text(product.title)
                                .font(.headline)
                            
                            if let imageURL = product.imageURL, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                            
                            Text(product.price)
                            Link("View on eBay", destination: URL(string: product.itemWebUrl)!)
                                .font(.caption)
                        }
                        .padding(.horizontal)
                        Divider()
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Item Lookup")
        .onAppear {
            // Only assign barcode once, when first loaded
            if !hasSearched {
                searchText = barcode
                performSearch(with: barcode)
                hasSearched = true
            }
        }
    }
    
    func performSearch(with query: String) {
        // TMDB search
        if query.count > 2 {
            isLoadingTMDB = true
            TMDBService.searchMovies(query: query) { results in
                DispatchQueue.main.async {
                    self.tmdbResults = results
                    self.isLoadingTMDB = false
                }
            }
        }
        
        // eBay search
        isLoadingEbay = true
        EbayAPIService.fetchProducts(keyword: query, token: ebayAuthManager.bearerToken) { results in
            DispatchQueue.main.async {
                self.ebayResults = results
                self.isLoadingEbay = false
            }
        }
    }
}


#Preview {
    ItemDetailSearchesView(barcode: "0123456789012")
        .environmentObject(TMDBAuthManager.shared)
        .environmentObject(EbayAuthManager.shared)
}


//
//  BulkAddDetailsView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//


import SwiftUI

struct BulkAddDetailsView: View {
    @State var scannedBarcodes: [String]
    var selectedBarcode: String?  // ✅ Highlights the selected barcode
    var onComplete: (([String]) -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Bulk Add Details")
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
                    onComplete?(scannedBarcodes)  // ✅ Send selected barcodes to ContentView
                }) {
                    Text("Add to Inventory")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
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


//
//  AddItemView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//

import SwiftUI
import TMDBSwift


struct AddItemAndSearchView: View {
    
    init(barcode: String) {
        _itemName = State(initialValue: barcode)
        _searchResults = State(initialValue: [])
    }
    
    @EnvironmentObject var tmdbAuthManager: TMDBAuthManager
    
    init(mockSearchResults: [MovieMDB] = []) {
        _searchResults = State(initialValue: mockSearchResults)
    }
    
    @State private var itemName: String = ""
    @State private var itemCategory: String = ""
    @State private var itemNotes: String = ""
    @State private var searchResults: [MovieMDB] = []
    @State private var isLoading = false
    @State private var showItemSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    AnimatedSearchBar(text: $itemName)
                        .onChange(of: itemName) { newValue in
                            if newValue.count > 2 {
                                isLoading = true
                                TMDBService.searchMovies(query: newValue) { results in
                                    DispatchQueue.main.async {
                                        self.searchResults = results
                                        self.isLoading = false
                                    }
                                }
                            } else {
                                searchResults = []
                            }
                        }
                    
                    if !searchResults.isEmpty {
                        SearchResultDropdown(
                            searchResults: searchResults,
                            isLoading: isLoading,
                            onSelect: { selectedMovie in
                                TMDBService.getMovieDetails(movieID: selectedMovie.id ?? -1) { detailedMovie in
                                    guard let movie = detailedMovie else { return }
                                    print(self.itemNotes)
                                    let genreString = TMDBService.extractGenreNames(from: movie.genres)
                                    TMDBService.saveMovieToCoreData(movie)
                                    
                                    DispatchQueue.main.async {
                                        self.itemName = movie.title ?? "Unknown Title"
                                        self.itemCategory = "Movie"
                                        self.itemNotes = """
                                        \(movie.overview ?? "")
                                        
                                        - Release Date: \(movie.release_date ?? "Unknown")
                                        - Runtime: \(movie.runtime ?? 0) minutes
                                        - Genres: \(genreString)
                                        """
                                        self.searchResults = []
                                        self.showItemSheet = true
                                    }
                                }
                            }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut, value: searchResults)
                    }
                }
            }
            .padding(.top)
            .onAppear {
                if itemName.count > 2 && searchResults.isEmpty {
                    isLoading = true
                    TMDBService.searchMovies(query: itemName) { results in
                        DispatchQueue.main.async {
                            self.searchResults = results
                            self.isLoading = false
                        }
                    }
                }
            }
            
            
            Spacer()
        }
        .sheet(isPresented: $showItemSheet) {
            ItemDetailsSheet(
                itemName: $itemName,
                itemCategory: $itemCategory,
                itemNotes: $itemNotes
            )
        }
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

struct SearchResultsSheet: View {
    @Binding var searchText: String
    @Binding var results: [MovieMDB]
    @Binding var isLoading: Bool
    
    var onSelect: (MovieMDB) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search...", text: $searchText)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                        .onChange(of: searchText) { newValue in
                            if newValue.count > 2 {
                                isLoading = true
                                TMDBService.searchMovies(query: newValue) { fetched in
                                    DispatchQueue.main.async {
                                        results = fetched
                                        isLoading = false
                                    }
                                }
                            } else {
                                results = []
                            }
                        }
                    
                    Button("Cancel") {
                        onCancel()
                    }
                }
                .padding()
                
                if isLoading {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(results, id: \.safeID) { movie in
                            Button {
                                onSelect(movie)
                            } label: {
                                SearchResultRow(movie: movie)
                                    .padding(.horizontal,15)
                                    .padding(.vertical, 4)
                            }
                            Divider()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}



struct SearchResultDropdown: View {
    
    let searchResults: [MovieMDB]
    let isLoading: Bool
    let onSelect: (MovieMDB) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isLoading {
                ProgressView("Searching TMDB...")
                    .padding()
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(searchResults, id: \.safeID) { movie in
                            Button(action: {
                                onSelect(movie)
                                if let movieID = movie.id {
                                    print("🎬 Selected Movie ID: \(movieID)")
                                } else {
                                    print("⚠️ Movie has no ID")
                                }
                            }) {
                                SearchResultRow(movie: movie)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider()
                        }
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 6)
        .padding(.horizontal)
        .frame(maxHeight: 200)
    }
}

struct SearchResultRow: View {
    let movie: MovieMDB
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            PosterImageView(path: movie.poster_path)
            
            VStack(alignment: .leading, spacing: 6) {
                TitleTextView(titleText: movie.formattedTitle)
                
                ReleaseDateView(dateString: movie.formattedReleaseDate)
                
                if let rating = movie.ratingSummary {
                    RatingSummaryView(rating: rating)
                }
                
                OverviewTextView(overviewText: movie.overviewText)
            }
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.all,10)
        }
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


#Preview {
    AddItemAndSearchView(mockSearchResults: [
        MovieMDB.mock(id: 1, title: "Inception"),
        MovieMDB.mock(id: 2, title: "Interstellar"),
        MovieMDB.mock(id: 3, title: "The Matrix")
    ])
    .environmentObject(TMDBAuthManager.shared)
}




extension MovieMDB: @retroactive Equatable {
    public static func == (lhs: MovieMDB, rhs: MovieMDB) -> Bool {
        return lhs.id == rhs.id
    }
}

extension MovieMDB {
    var formattedTitle: String {
        title ?? "Unknown"
    }
    
    var formattedReleaseDate: String {
        release_date ?? "Unknown Release Date"
    }
    
    var ratingSummary: String? {
        guard let avg = vote_average, let count = vote_count else { return nil }
        return "⭐️ \(String(format: "%.1f", avg)) (\(count) votes)"
    }
    
    var overviewText: String {
        overview ?? "No overview available."
    }
    
    var posterURL: URL? {
        guard let path = poster_path else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w92\(path)")
    }
    
    
    struct MockMovie: Identifiable {
        let id: Int
        let title: String
        let releaseDate: String
        let overview: String
        let posterPath: String
        let voteAverage: Double
        let voteCount: Int
    }
    
    static func mock(id: Int = 1, title: String = "Inception") -> MovieMDB {
        let json = """
        {
            "id": \(id),
            "title": "\(title)",
            "release_date": "2010-07-16",
            "overview": "A mind-bending thriller.",
            "poster_path": "/poster.jpg",
            "vote_average": 8.8,
            "vote_count": 12345
        }
        """.data(using: .utf8)!
        
        do {
            return try JSONDecoder().decode(MovieMDB.self, from: json)
        } catch {
            fatalError("❌ Failed to decode mock MovieMDB: \(error)")
        }
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
    
    var body: some View {
        VStack {
            NavigationLink(
                destination: ItemDetailSearchesView(barcode: barcode)
                    .environmentObject(EbayAuthManager.shared)
                    .environmentObject(TMDBAuthManager.shared),
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
                print("Perform action for \(barcode)")
                navigateToSearches = true
            }) {
                Text("Perform Action")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct AddItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AddedItemDetailView(barcode: "00100860105891")
    }
}
