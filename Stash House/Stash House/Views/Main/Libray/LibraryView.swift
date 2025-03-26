//
//  LibraryView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//

import SwiftUI
import CodeScanner

struct LibraryView: View {
    @Binding var scannedItems: [ScannedItem]
    @Binding var isScanning: Bool
    @Binding var showFileImporter: Bool
    @Binding var searchText: String
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                    ForEach(scannedItems) { item in
                        VStack {
                            // Replace with your actual image loading if available
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .cornerRadius(10)
                            Text(item.title)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            HStack {
                                Button(action: { deleteItem(item) }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10)
                            .fill(Color.secondary.opacity(0.2)))
                    }
                }
                .padding()
            }
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: shareLibrary) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Button(action: { isScanning = true }) {
                            Image(systemName: "plus")
                        }
                        Button(action: { showFileImporter = true }) {
                            Image(systemName: "folder.badge.plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $isScanning) {
                ScannerView(isScanning: $isScanning,
                            isBulkScan: .constant(false),
                            scannedItems: $scannedItems)
            }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json]) { result in
                switch result {
                    case .success(let url):
                        importJSON(from: url)
                    case .failure(let error):
                        print("Failed to import file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func deleteItem(_ item: ScannedItem) {
        scannedItems.removeAll { $0.id == item.id }
    }
    
    func shareLibrary() {
        let jsonEncoder = JSONEncoder()
        if let jsonData = try? jsonEncoder.encode(scannedItems),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let activityVC = UIActivityViewController(activityItems: [jsonString],
                                                      applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        }
    }
    
    func importJSON(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            // Debug: Print the JSON file's contents
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON file contents:\n\(jsonString)")
            } else {
                print("Unable to convert data to string")
            }
            // Decode into CollectibleCard objects which match your JSON structure.
            let decodedCards = try JSONDecoder().decode([CollectibleCard].self, from: data)
            // Convert them to ScannedItem objects for the UI.
            let scannedItemsFromCards = convertToScannedItems(from: decodedCards)
            DispatchQueue.main.async {
                scannedItems.append(contentsOf: scannedItemsFromCards)
            }
        } catch {
            print("Error decoding JSON: \(error.localizedDescription)")
        }
    }
    
    func convertToScannedItems(from cards: [CollectibleCard]) -> [ScannedItem] {
        return cards.map { card in
            // Use cardTitle as the title and cardNumber (converted to string) as the barcode.
            ScannedItem(id: card.id, title: card.cardTitle, barcode: "\(card.cardNumber)")
        }
    }
}

