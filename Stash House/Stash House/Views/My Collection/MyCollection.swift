//
//  MyCollection.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//


import SwiftUI
import CodeScanner  // ✅ Import CodeScanner framework

struct MyCollection: View {
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
                    Collection(name: "Baseball Cards", items: baseballCardItems)
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
                
                ScrollView(.vertical) {
                    HStack(spacing: 16) {
                        ForEach(collections) { collection in
                            NavigationLink(destination: CollectionViewer(images: collection.items)) {
                                VStack {
                                    if collection.items.first != nil {
                                        PlaceholderView()
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




struct CollectionsViewer: View {
    @State var images: [Collectible]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(images) { item in
                    NavigationLink(destination: CollectibleDetailView(item: item)) {
                        HStack {
                            Image(item.imageName)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                            Text(item.name)
                                .font(.headline)
                        }
                        .padding()
                    }
                }
            }
            .padding()
        }
    }
}

struct CollectibleDetailView: View {
    let item: Collectible
    
    var body: some View {
        VStack(spacing: 20) {
            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .cornerRadius(12)
            Text(item.name)
                .font(.title)
                .bold()
            Spacer()
        }
        .padding()
        .navigationTitle(item.name)
    }
}





struct CollectionViewer: View {
    @State var images: [Collectible]  // Updated from CollectibleItem to Collectible
    @State var flipDegrees: Double = 0
    @State var offset: CGSize = .zero
    @State var isTopCardSelected: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                ZStack {
                    ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                        CardView(image)
                            .offset(index == 0 ? offset : CGSize(width: CGFloat(index) * -10, height: CGFloat(index) * -7))
                            .rotation3DEffect(.degrees(index == 0 ? flipDegrees : 0), axis: (x: 0, y: 1, z: 0))
                            .zIndex(Double(images.count - index))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if index == 0 || isTopCardSelected {
                                            offset = value.translation
                                        }
                                    }
                                    .onEnded { value in
                                        if index == 0 || isTopCardSelected {
                                            let direction: CGFloat = value.translation.width > 0 ? 1 : -1
                                            swipeCard(direction: direction)
                                        }
                                    }
                            )
                    }
                }
                .frame(width: 200, height: 300)
                .padding(.horizontal)
            }
        }
    }
    
    func swipeCard(direction: CGFloat) {
        withAnimation(.easeInOut(duration: 1.0)) {
            flipDegrees += 360 * direction
            offset = CGSize(width: direction * 500, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                if let removedCard = images.first {
                    images.append(removedCard)
                    images.removeFirst()
                }
                flipDegrees = 0
                offset = .zero
                isTopCardSelected = false
            }
        }
    }
}

@ViewBuilder
func CardView(_ collectibleItem: Collectible) -> some View {
    Image(collectibleItem.imageName)
        .resizable()
        .scaledToFit()
        .frame(width: 180, height: 250)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(radius: 5)
        )
}


