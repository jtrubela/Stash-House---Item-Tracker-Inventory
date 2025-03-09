//
//  AddItemView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//

import SwiftUI
import TMDBSwift
import TMDb

struct AddItemAndSearchView: View {
    @State private var itemName: String = ""
    @State private var itemCategory: String = ""
    @State private var itemNotes: String = ""
    @State private var barcode: String?
    @State private var searchResults: [MovieMDB] = []
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Item Name", text: $itemName)
                    .onChange(of: itemName) { newValue in
                        if newValue.count > 2 {
                            searchMovies(title: newValue)
                        } else {
                            searchResults = []
                        }
                    }
                TextField("Category", text: $itemCategory)
                TextField("Notes", text: $itemNotes)

                if !searchResults.isEmpty {
                    Section(header: Text("Search Results")) {
                        List(searchResults, id: \.safeID) { movie in // ✅ Use safeID instead of id
                            Button(action: {
                                getMovieDetails(movieID: movie.id ?? -1) { movieDetail in
                                    if let movie = movieDetail {
                                        itemName = movie.title ?? "Unknown Title"
                                        itemCategory = "Movie"
                                        itemNotes = movie.overview ?? "No description available"
                                    }
                                }
                            }) {
                                VStack(alignment: .leading) {
                                    Text(movie.title ?? "Unknown")
                                        .font(.headline)
                                    Text(movie.release_date ?? "Unknown Release Date")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle("Add Item")
        }
    }
    
    private func saveMovieToCoreData(movie: MovieDetailedMDB) {
        let newItem = Item(context: PersistenceController.shared.container.viewContext)
        newItem.id = UUID()
        newItem.name = movie.title ?? "Unknown Title"
        newItem.category = "Movie"
        newItem.notes = """
    \(movie.overview ?? "No description available.")
    
    - Release Date: \(movie.release_date ?? "Unknown")
    - Runtime: \(movie.runtime ?? 0) minutes
    - Rating: \(movie.vote_average ?? 0.0) / 10 (\(movie.vote_count ?? 0) votes)

    - Status: \(movie.status ?? "Unknown")
    - Revenue: $\(movie.revenue ?? 0)
    """
        
        do {
            try PersistenceController.shared.container.viewContext.save()
            print("✅ Movie saved to CoreData: \(movie.title ?? "Unknown Title")")
        } catch {
            print("❌ Error saving movie to CoreData: \(error)")
        }
    }

    private func searchMovies(title: String) {
        SearchMDB.movie(query: title, language: "en", page: 1, includeAdult: false, year: nil, primaryReleaseYear: nil) { clientReturn, movieArray in
            if let movies = movieArray {
                DispatchQueue.main.async {
                    searchResults = movies
                }
            } else {
                print("No movies found for query: \(title)")
            }
        }
    }
    
        private func extractGenreNames(from genres: [GenreMDB]?) -> String {
            guard let genres = genres else { return "Unknown" }
            
            return genres.map { genre in
                let mirror = Mirror(reflecting: genre)
                if let nameProperty = mirror.children.first(where: { $0.label == "name" })?.value as? String {
                    return nameProperty
                }
                return "Unknown"
            }.joined(separator: ", ")
        }

    
        private func getMovieDetails(movieID: Int, completion: @escaping (MovieDetailedMDB?) -> Void) {
            MovieMDB.movie(movieID: movieID, language: "en") { clientReturn, movieDetail in
                if let movie = movieDetail {
                    // ✅ Use reflection to extract genre names
                    let genreNames = extractGenreNames(from: movie.genres)
                    
                    print("""
            -------------------------------
            MOVIE DETAILS:
            Title: \(movie.title ?? "Unknown")
            Release Date: \(movie.release_date ?? "Unknown")
            Overview: \(movie.overview ?? "No description available")
            Genres: \(genreNames)
            Runtime: \(movie.runtime ?? 0) minutes
            -------------------------------
            """)
                    
                    DispatchQueue.main.async {
                        itemName = movie.title ?? "Unknown Title"
                        itemCategory = "Movie"
                        itemNotes = """
                \(movie.overview ?? "No description available.")
                
                - Release Date: \(movie.release_date ?? "Unknown")
                - Runtime: \(movie.runtime ?? 0) minutes
                - Genres: \(genreNames)
                """
                    }
                    
                    completion(movie)
                } else {
                    print("No details found for movie ID: \(movieID)")
                    completion(nil)
                }
            }
        }




}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemAndSearchView()
    }
}
