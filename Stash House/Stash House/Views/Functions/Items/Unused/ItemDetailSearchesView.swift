//
//  AddItemAndSearchView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/25/25.
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
