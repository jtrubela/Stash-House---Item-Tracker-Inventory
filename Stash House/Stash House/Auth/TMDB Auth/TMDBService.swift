//
//  TMDBService.swift
//  Stash House
//
//  Created by Justin Trubela on 3/24/25.
//


import Foundation
import TMDBSwift

class TMDBService {
    
    static func searchMovies(query: String, completion: @escaping ([MovieMDB]) -> Void) {
        SearchMDB.movie(query: query, language: "en", page: 1, includeAdult: false, year: nil, primaryReleaseYear: nil) { _, movieArray in
            completion(movieArray ?? [])
        }
    }

    static func getMovieDetails(movieID: Int, completion: @escaping (MovieDetailedMDB?) -> Void) {
        MovieMDB.movie(movieID: movieID, language: "en") { _, movieDetail in
            completion(movieDetail)
        }
    }

    static func extractGenreNames(from genres: [GenreMDB]?) -> String {
        guard let genres = genres else { return "Unknown" }
        return genres.compactMap {
            Mirror(reflecting: $0).children.first(where: { $0.label == "name" })?.value as? String
        }.joined(separator: ", ")
    }

    static func saveMovieToCoreData(_ movie: MovieDetailedMDB) {
        let context = PersistenceController.shared.container.viewContext
        let newItem = Item(context: context)
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
            try context.save()
            print("✅ Movie saved: \(movie.title ?? "Unknown")")
        } catch {
            print("❌ Save error: \(error)")
        }
    }
}
