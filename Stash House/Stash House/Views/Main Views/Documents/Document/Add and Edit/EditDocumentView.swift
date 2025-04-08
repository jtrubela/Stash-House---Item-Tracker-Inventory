//
//  EditDocumentView.swift
//  Stash House
//
//  Created by Justin Trubela on 4/8/25.
//

import SwiftUI

struct EditDocumentView: View {
    @ObservedObject var item: Item
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: Category?

    
    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                TextField("Title", text: Binding($item.title, default: ""))
                TextField("Barcode", text: Binding($item.barcode, default: ""))
                Section(header: Text("Category")) {
                    Text(item.categoryEntity?.name ?? "Uncategorized")
                }
            }
            
            Section(header: Text("Notes")) {
                TextEditor(text: Binding($item.notes, default: ""))
                    .frame(height: 100)
            }
            
            Section {
                Button("Save Changes") {
                    saveItem()
                }
                .foregroundColor(.blue)
            }
        }
        .navigationTitle("Edit Collectible")
    }
    
    func saveItem() {
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("❌ Error saving changes: \(error.localizedDescription)")
        }
    }
}

extension Binding {
    init(_ source: Binding<Value?>, default defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}
