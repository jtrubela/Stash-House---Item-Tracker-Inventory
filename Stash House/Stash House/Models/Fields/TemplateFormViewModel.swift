//
//  TemplateFormViewModel.swift
//  Stash House
//
//  Created by Justin Trubela on 4/8/25.
//


import SwiftUI

class TemplateFormViewModel: ObservableObject {
    @Published var stringValues: [String: String] = [:]
    @Published var boolValues: [String: Bool] = [:]
    @Published var dateValues: [String: Date] = [:]
    @Published var imageData: [String: Data] = [:]
    
    // MARK: Text Binding
    func binding(for key: String, default value: String = "") -> Binding<String> {
        Binding(
            get: { self.stringValues[key, default: value] },
            set: { self.stringValues[key] = $0 }
        )
    }
    
    // MARK: Boolean Binding
    func binding(for key: String, default value: Bool) -> Binding<Bool> {
        Binding(
            get: { self.boolValues[key, default: value] },
            set: { self.boolValues[key] = $0 }
        )
    }
    
    // MARK: Date Binding
    func binding(for key: String, default value: Date) -> Binding<Date> {
        Binding(
            get: { self.dateValues[key, default: value] },
            set: { self.dateValues[key] = $0 }
        )
    }
    
    // MARK: Image Data Binding
    func bindImageData(_ key: String) -> Binding<Data?> {
        Binding(
            get: { self.imageData[key] },
            set: { self.imageData[key] = $0 }
        )
    }
}

//import SwiftUI

struct TemplateFormView: View {
    let template: TemplateModel
    @StateObject private var viewModel = TemplateFormViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // Used to trigger image picker sheet for a specific image field
    @State private var activeImageField: FieldKeyWrapper?

    var body: some View {
        Form {
            Section(header: Text(template.description)) {
                ForEach(template.fields) { field in
                    switch field.type {
                        case .image:
                            imageFieldSection(for: field)
                            
                        case .selection:
                            if let options = field.options {
                                HStack {
                                    Image(systemName: field.icon).foregroundColor(.blue)
                                    Picker(field.label, selection: viewModel.binding(for: field.key)) {
                                        ForEach(options, id: \.self) {
                                            Text($0)
                                        }
                                    }
                                }
                            }
                            
                        default:
                            fieldRow(for: field)
                    }
                }
            }
        }
        .navigationTitle(template.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { saveItem() }
            }
        }
        .sheet(item: $activeImageField) { wrapper in
            ImageSourceActionSheet(selectedImageData: viewModel.bindImageData(wrapper.id))
        }

    }
    
    // MARK: - Image Field UI
    @ViewBuilder
    private func imageFieldSection(for field: FieldDefinition) -> some View {
        Section(header: HStack {
            Image(systemName: field.icon).foregroundColor(.blue)
            Text(field.label)
        }) {
            Button(action: {
                activeImageField = FieldKeyWrapper(id: field.key)
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Choose Image")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            }
            
            if let data = viewModel.imageData[field.key],
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Default Field UI
    @ViewBuilder
    private func fieldRow(for field: FieldDefinition) -> some View {
        HStack(alignment: .center) {
            Image(systemName: field.icon).foregroundColor(.blue)
            
            switch field.type {
                case .text, .email, .url, .phone, .barcode, .qrCode:
                    TextField(field.label, text: viewModel.binding(for: field.key))
                    
                case .richText:
                    TextEditor(text: viewModel.binding(for: field.key))
                        .frame(height: 120)
                    
                case .integer, .decimal:
                    TextField(field.label, text: viewModel.binding(for: field.key))
                        .keyboardType(.decimalPad)
                    
                case .boolean:
                    Toggle(field.label, isOn: viewModel.binding(for: field.key, default: false))
                    
                case .date:
                    DatePicker(field.label, selection: viewModel.binding(for: field.key, default: Date()), displayedComponents: .date)
                    
                case .dateTime:
                    DatePicker(field.label, selection: viewModel.binding(for: field.key, default: Date()), displayedComponents: [.date, .hourAndMinute])
                    
                case .time:
                    DatePicker(field.label, selection: viewModel.binding(for: field.key, default: Date()), displayedComponents: .hourAndMinute)
                    
                    // Not implemented
                case .file, .documentReference, .location, .timeInterval, .color:
                    Text("[\(field.type.rawValue.capitalized) Field Not Yet Implemented]")
                        .foregroundColor(.gray)
                    
                case .image, .selection:
                    EmptyView() // handled elsewhere
            }
        }
    }
    
    // MARK: - Save Logic
    private func saveItem() {
        let newItem = Item(context: viewContext)
        newItem.id = UUID()
        newItem.timestamp = Date()
        newItem.category = template.name
        
        newItem.title = viewModel.stringValues["title"]
        newItem.barcode = viewModel.stringValues["barcode"]
        newItem.notes = viewModel.stringValues["notes"]
        
        if let imageField = template.fields.first(where: { $0.type == .image }) {
            newItem.image = viewModel.imageData[imageField.key]
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("❌ Failed to save item: \(error.localizedDescription)")
        }
    }
}

struct FieldKeyWrapper: Identifiable {
    let id: String
}

#Preview {
    NavigationStack {
        TemplateFormView(template: TemplateModel(
            name: "Games",
            description: "Manage your video game collection.",
            fields: [
                FieldDefinition(key: "title", label: "Title", icon: "textformat", type: .text),
                FieldDefinition(key: "cover", label: "Cover Image", icon: "photo", type: .image),
                FieldDefinition(key: "platform", label: "Platform", icon: "desktopcomputer", type: .selection, options: ["PS5", "Xbox", "Switch"]),
                FieldDefinition(key: "genre", label: "Genre", icon: "music.note.list", type: .text),
                FieldDefinition(key: "releaseDate", label: "Release Date", icon: "calendar", type: .date),
                FieldDefinition(key: "summary", label: "Summary", icon: "text.justify", type: .richText)
            ]
        ))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
