//
//  FieldType.swift
//  Stash House
//
//  Created by Justin Trubela on 4/8/25.
//


import Foundation

enum FieldType: String, Codable {
    case text              // Basic single-line text input
    case richText          // Multiline text (TextEditor)
    case integer           // Whole number input
    case decimal           // Decimal number input
    case boolean           // Toggle (true/false)
    case image             // Image picker
    case file              // File attachment (not yet implemented)
    case selection         // Dropdown menu (uses options array)
    case email             // Email input
    case url               // URL input
    case phone             // Phone number input
    case location          // Location picker (future)
    case barcode           // Barcode entry or scanner
    case qrCode            // QR Code
    case date              // Date picker
    case dateTime          // Combined date and time picker
    case time              // Time-only picker
    case timeInterval      // Duration between two times
    case color             // Color picker
    case documentReference // Link to another document/item
}
