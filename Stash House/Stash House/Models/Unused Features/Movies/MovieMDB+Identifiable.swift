//
//  MovieMDB+Identifiable.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//

import TMDBSwift
import TMDb

extension MovieMDB: Identifiable {
    public var safeID: Int {
        return self.id ?? -1 // Provide a fallback non-optional ID
    }
}
