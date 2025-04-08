//
//  ContentView.swift
//  Stash House
//
//  Created by Justin Trubela on 6/30/23.
//

import SwiftUI
import CoreData


class ContentViewModel: ObservableObject {
    @Published var selectedTab: Tab = .library
    @Published var isScanning: Bool = false
    @Published var showFileImporter: Bool = false
    @Published var searchText: String = ""
    
    func importJSON(from url: URL, into context: NSManagedObjectContext) {
        do {
            let data = try Data(contentsOf: url)
            let decodedCards = try JSONDecoder().decode([CollectibleCard].self, from: data)
            for card in decodedCards {
                let newItem = Item(context: context)
                newItem.id = UUID()
                newItem.title = card.cardTitle
                newItem.barcode = "\(card.cardNumber)"
                newItem.category = "Trading Card"
                newItem.timestamp = Date()
                newItem.notes = "Imported from file"
            }
            try context.save()
        } catch {
            print("❌ Error decoding JSON: \(error.localizedDescription)")
        }
    }

}

struct ContentView: View {
    // Inject Core Data context into this view
    @Environment(\.managedObjectContext) private var viewContext
    
    // State variables for controlling scanning, file import, search, and tab selection
    @StateObject private var viewModel = ContentViewModel()

    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                selectedTabView
                LibraryTabToolBar(selectedTab: $viewModel.selectedTab)
            }
            .navigationBarTitle(viewModel.selectedTab.title, displayMode: .inline)
        }
        .environmentObject(viewModel)
    }
    
    // Dynamically switch between LibraryView and MyCollection
    @ViewBuilder
    private var selectedTabView: some View {
        switch viewModel.selectedTab {
            case .library:
                LibraryView()
            case .myCollections:
                MyCollection()
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

// MARK: - Enum for Tab Bar Options
enum Tab: Int, CaseIterable {
    case library = 0
    case myCollections = 1
    
    var title: String {
        switch self {
            case .library: return "Library"
            case .myCollections: return "My Collections"
        }
    }
    
    var systemImage: String {
        switch self {
            case .library: return "books.vertical"
            case .myCollections: return "list.bullet"
        }
    }
}


func importJSON(from url: URL, into context: NSManagedObjectContext) {
    do {
        let data = try Data(contentsOf: url)
        let decodedCards = try JSONDecoder().decode([CollectibleCard].self, from: data)
        for card in decodedCards {
            let newItem = Item(context: context)
            newItem.id = UUID()
            newItem.title = card.cardTitle
            newItem.barcode = "\(card.cardNumber)"
            newItem.category = "Trading Card"
            newItem.timestamp = Date()
            newItem.notes = "Imported from file"
        }
        try context.save()
    } catch {
        print("❌ Error decoding JSON: \(error.localizedDescription)")
    }
}
