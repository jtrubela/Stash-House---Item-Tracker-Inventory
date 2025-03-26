//
//  MyCollectionsView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//

import SwiftUI

struct MyCollectionsView: View {
    @State private var selectedType: CollectionType = .cards
    @State private var isScanning = false
    @State private var scannedItems: [ScannedItem] = []
    
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
                ScannerView(isScanning: $isScanning, isBulkScan: .constant(false), scannedItems: $scannedItems)
            }
        }
    }
}
