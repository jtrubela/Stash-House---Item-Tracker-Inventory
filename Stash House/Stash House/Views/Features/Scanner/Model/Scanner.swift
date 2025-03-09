//
//  Scanner.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//

import SwiftUI

// MARK: - Models & ScannerView
struct ScannedItem: Identifiable, Codable {
    var id: UUID
    var title: String
    var barcode: String
}
