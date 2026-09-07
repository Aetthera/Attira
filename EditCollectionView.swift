//
//  EditColectionView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-09-06.
//

import SwiftUI

struct EditCollectionView: View {
    let collection: Collection
    @EnvironmentObject var collectionStore: CollectionStore
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var description: String
    
    init(collection: Collection) {
        self.collection = collection
        _name = State(initialValue: collection.name)
        _description = State(initialValue: collection.description ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Description (optional)", text: $description)
                }
            }
            .navigationTitle("Edit Collection")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        var updated = collection
                        updated.name = name.trimmingCharacters(in: .whitespaces)
                        updated.description = description.trimmingCharacters(in: .whitespaces).isEmpty
                            ? nil
                            : description.trimmingCharacters(in: .whitespaces)
                        collectionStore.updateCollection(updated)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    EditCollectionView(collection: Collection(name: "Test"))
        .environmentObject(CollectionStore())
}
