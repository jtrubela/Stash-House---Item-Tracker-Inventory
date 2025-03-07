//
//  AddItemView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/7/25.
//

import SwiftUI
import CoreData

struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var itemName: String = ""
    @State private var itemCategory: String = ""
    @State private var itemNotes: String = ""
    @State private var barcode: String?
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Item Name", text: $itemName)
                TextField("Category", text: $itemCategory)
                TextField("Notes", text: $itemNotes)
                
                // Display scanned barcode
                if let barcode = barcode {
                    Text("Scanned Barcode: \(barcode)")
                        .foregroundColor(.blue)
                }
                
                NavigationLink(destination: BarcodeScanScreen(scannedCode: $barcode)) {
                    Text("Scan Barcode")
                        .foregroundColor(.green)
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                Button("Save") {
                    saveItem()
                }
            }
            .onChange(of: barcode) { newBarcode in
                if let barcode = newBarcode {
                    lookupItem(by: barcode)
                }
            }
        }
    }
    
    // ✅ CoreData Lookup for Existing Barcode
    private func lookupItem(by barcode: String) {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "barcode == %@", barcode)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let matchedItem = results.first {
                self.itemName = matchedItem.name ?? ""
                self.itemCategory = matchedItem.category ?? ""
                self.itemNotes = matchedItem.notes ?? ""
            } else {
                fetchMovieDetailsFromAPI(barcode: barcode)  // If not found, fetch from movie API
            }
        } catch {
            print("Failed to fetch item with barcode: \(error)")
        }
    }
    
    // ✅ Fetch Movie Details via UPC API → OMDb API
    private func fetchMovieDetailsFromAPI(barcode: String) {
        let upcApiURL = "https://api.barcodelookup.com/v3/products?barcode=\(barcode)&formatted=y&key=YOUR_UPC_API_KEY"
        
        guard let upcURL = URL(string: upcApiURL) else { return }
        
        URLSession.shared.dataTask(with: upcURL) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let products = json?["products"] as? [[String: Any]], let movieTitle = products.first?["title"] as? String {
                    fetchMovieFromOMDb(title: movieTitle)
                }
            } catch {
                print("Error fetching movie title from UPC: \(error)")
            }
        }.resume()
    }
    
    // ✅ Fetch movie details from OMDb API
    private func fetchMovieFromOMDb(title: String) {
        let omdbApiURL = "https://www.omdbapi.com/?t=\(title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&apikey=YOUR_OMDB_API_KEY"
        
        guard let url = URL(string: omdbApiURL) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                DispatchQueue.main.async {
                    let director = json?["Director"] as? String ?? "Unknown"
                    let plot = json?["Plot"] as? String ?? "No description available."
                    
                    self.itemNotes = "Director: \(director)\nPlot: \(plot)"
                }

            } catch {
                print("Error fetching movie details: \(error)")
            }
        }.resume()
    }
    
    private func saveItem() {
        let newItem = Item(context: viewContext)
        newItem.id = UUID()
        newItem.name = itemName
        newItem.category = itemCategory
        newItem.notes = itemNotes
        newItem.barcode = barcode
        newItem.dateAdded = Date()
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to save new item: \(error)")
        }
    }
}

// ✅ SwiftUI Preview
struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        return AddItemView().environment(\.managedObjectContext, context)
    }
}
