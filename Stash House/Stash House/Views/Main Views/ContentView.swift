//
//  ContentView.swift
//  Stash House
//
//  Created by Justin Trubela on 6/30/23.
//
import SwiftUI

struct ContentView: View {
    @State private var scannedItems: [ScannedItem] = []
    @State private var isScanning = false
    @State private var showFileImporter = false
    @State private var searchText = ""
    @State private var selectedTab: Int = 0 // 0: Library, 1: MyCollections
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Main content based on the selected tab
                if selectedTab == 0 {
                    LibraryView(scannedItems: $scannedItems,
                                isScanning: $isScanning,
                                showFileImporter: $showFileImporter,
                                searchText: $searchText)
                } else {
                    MyCollection()
                }
                
                // Bottom toolbar for switching views
                HStack {
                    Spacer()
                    Button(action: { selectedTab = 0 }) {
                        VStack {
                            Image(systemName: "books.vertical")
                            Text("Library")
                        }
                    }
                    Spacer()
                    Button(action: { selectedTab = 1 }) {
                        VStack {
                            Image(systemName: "list.bullet")
                            Text("My Collections")
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.systemGray6))
            }
            .navigationBarTitle(selectedTab == 0 ? "Library" : "My Collections", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}







//struct CollectionsViewer: View {
//    @State var images: [Collectible]
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                ForEach(images) { item in
//                    NavigationLink(destination: CollectibleDetailView(item: item)) {
//                        HStack {
//                            Image(item.imageName)
//                                .resizable()
//                                .frame(width: 60, height: 60)
//                                .cornerRadius(8)
//                            Text(item.name)
//                                .font(.headline)
//                        }
//                        .padding()
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//}


//struct CollectibleDetailView: View {
//    let item: Collectible
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(item.imageName)
//                .resizable()
//                .scaledToFit()
//                .cornerRadius(12)
//            Text(item.name)
//                .font(.title)
//                .bold()
//            Spacer()
//        }
//        .padding()
//        .navigationTitle(item.name)
//    }
//}
//
//


//
//struct CollectionViewer: View {
//    @State var images: [Collectible]  // Updated from CollectibleItem to Collectible
//    @State var flipDegrees: Double = 0
//    @State var offset: CGSize = .zero
//    @State var isTopCardSelected: Bool = false
//
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//            VStack {
//                ZStack {
//                    ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
//                        CardView(image)
//                            .offset(index == 0 ? offset : CGSize(width: CGFloat(index) * -10, height: CGFloat(index) * -7))
//                            .rotation3DEffect(.degrees(index == 0 ? flipDegrees : 0), axis: (x: 0, y: 1, z: 0))
//                            .zIndex(Double(images.count - index))
//                            .gesture(
//                                DragGesture()
//                                    .onChanged { value in
//                                        if index == 0 || isTopCardSelected {
//                                            offset = value.translation
//                                        }
//                                    }
//                                    .onEnded { value in
//                                        if index == 0 || isTopCardSelected {
//                                            let direction: CGFloat = value.translation.width > 0 ? 1 : -1
//                                            swipeCard(direction: direction)
//                                        }
//                                    }
//                            )
//                    }
//                }
//                .frame(width: 200, height: 300)
//                .padding(.horizontal)
//            }
//        }
//    }
//
//    func swipeCard(direction: CGFloat) {
//        withAnimation(.easeInOut(duration: 1.0)) {
//            flipDegrees += 360 * direction
//            offset = CGSize(width: direction * 500, height: 0)
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            withAnimation {
//                if let removedCard = images.first {
//                    images.append(removedCard)
//                    images.removeFirst()
//                }
//                flipDegrees = 0
//                offset = .zero
//                isTopCardSelected = false
//            }
//        }
//    }
//}
//
//@ViewBuilder
//func CardView(_ collectibleItem: Collectible) -> some View {
//    Image(collectibleItem.imageName)
//        .resizable()
//        .scaledToFit()
//        .frame(width: 180, height: 250)
//        .background(
//            RoundedRectangle(cornerRadius: 15)
//                .fill(Color.white)
//                .shadow(radius: 5)
//        )
//}
//
//
