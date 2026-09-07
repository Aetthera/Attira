//
//  CoreateCollectionView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-09-06.
//

import SwiftUI
import SwiftData

struct CreateCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var description = ""
    
    private var cleanedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var cleanedDescription: String {
        description.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Collection details") {
                    TextField("Collection name", text: $name)
                    
                    TextField(
                        "Description (optional)",
                        text: $description,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }
            }
            .navigationTitle("New Collection")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let collection = ClothingCollection(
                            name: cleanedName,
                            collectionDescription: cleanedDescription
                        )
                        
                        modelContext.insert(collection)
                        dismiss()
                    }
                    .disabled(cleanedName.isEmpty)
                }
            }
        }
    }
}
