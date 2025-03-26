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
