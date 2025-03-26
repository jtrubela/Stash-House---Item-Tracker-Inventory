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
