//
//  AddOptionsModalView.swift
//  Stash House
//
//  Created by Justin Trubela on 4/8/25.
//

import SwiftUI

enum AddOption: String, CaseIterable, Identifiable {
    case scan = "Scan Barcode"
    case manual = "Add Manually"
    case search = "Search Online"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
            case .scan: return "barcode.viewfinder"
            case .manual: return "square.and.pencil"
            case .search: return "magnifyingglass"
        }
    }
}

struct AddOptionsModalView: View {
    @Binding var selectedOption: AddOption?
    @Binding var isScanning: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep: Step = .chooseMethod
    @State private var selectedCategoryName: String? = nil
    
    enum Step {
        case chooseMethod
        case chooseTemplate
        case input
    }
    
    var body: some View {
        VStack(spacing: 24) {
            headerTitle
            
            Divider()
            
            switch currentStep {
                case .chooseMethod:
                    methodPicker
                case .chooseTemplate:
                    templatePicker
                case .input:
                    if let category = selectedCategoryName {
                        NavigationStack {
                            TemplateFormView(template: CategoryTemplates.forCategory(category))
                        }
                    } else {
                        Text("No category selected.")
                    }
            }
            
            Spacer()
        }
        .padding()
        .presentationDetents([.large])
    }
    
    private var headerTitle: some View {
        HStack {
            if currentStep != .chooseMethod {
                Button(action: {
                    if currentStep == .input {
                        currentStep = .chooseTemplate
                    } else {
                        currentStep = .chooseMethod
                        selectedOption = nil
                        selectedCategoryName = nil
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
            }
            Spacer()
            Text(titleForCurrentStep)
                .font(.title2)
                .bold()
            Spacer()
            if currentStep != .chooseMethod {
                Spacer()
            }
        }
    }
    
    private var titleForCurrentStep: String {
        switch currentStep {
            case .chooseMethod: return "How would you like to add?"
            case .chooseTemplate: return "Select Item Type"
            case .input: return "Add New Item"
        }
    }
    
    private var methodPicker: some View {
        VStack(spacing: 16) {
            ForEach(AddOption.allCases) { option in
                Button(action: {
                    selectedOption = option
                    switch option {
                        case .manual:
                            currentStep = .chooseTemplate
                        case .scan:
                            isScanning = true
                            dismiss()
                        case .search:
                            currentStep = .input
                    }
                }) {
                    Label(option.rawValue, systemImage: option.icon)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private var templatePicker: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(templateOptions, id: \.label) { template in
                    Button(action: {
                        selectedCategoryName = template.label
                        currentStep = .input
                    }) {
                        VStack {
                            Image(systemName: template.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .foregroundColor(.blue)
                            
                            Text(template.label)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, minHeight: 80)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.top)
        }
    }
    
    private var templateOptions: [(label: String, icon: String)] {
        [
            ("Custom", "square.grid.2x2"),
            ("Books", "book"),
            ("Games", "gamecontroller"),
            ("Music", "music.note"),
            ("Movies", "film"),
            ("TV Shows", "tv"),
            ("Toys", "puzzlepiece.extension"),
            ("Trading Card", "rectangle.stack"),
            ("Contacts", "person.crop.circle"),
            ("Expenses", "wallet.pass"),
            ("Subscriptions", "clock.arrow.circlepath"),
            ("Credentials", "key"),
            ("Inventory", "archivebox"),
            ("Notes", "note.text"),
            ("School", "graduationcap")
        ]
    }
}

#Preview {
    AddOptionsModalPreview()
}

private struct AddOptionsModalPreview: View {
    @State private var selectedOption: AddOption? = nil
    @State private var isScanning = false
    
    var body: some View {
        NavigationStack {
            AddOptionsModalView(
                selectedOption: $selectedOption,
                isScanning: $isScanning
            )
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
