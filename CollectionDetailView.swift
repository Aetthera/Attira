//
//  CollectionDetailView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-09-06.
//

import SwiftUI

struct CollectionDetailView: View {
    let collection: Collection
    let items: [Item]
    let onEdit: () -> Void
    let onDeleteItem: (Item) -> Void
    let onAddItem: (Item) -> Void
    
    @State private var showingEdit = false
    @State private var showingAddPicker = false
    @State private var selectedItem: Item?
    
    var body: some View {
        VStack {
            List {
                Section {
                    HStack {
                        Text(collection.name)
                            .font(.headline)
                        Spacer()
                        Button("Edit") {
                            showingEdit = true
                        }
                        .font(.subheadline)
                    }
                    if let desc = collection.description, !desc.isEmpty {
                        Text(desc)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Items") {
                    ForEach(items) { item in
                        Button {
                            selectedItem = item
                        } label: {
                            HStack {
                                if let url = item.imageUrl,
                                   let uiImage = UIImage(contentsOfFile: url) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(6)
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(6)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.subheadline)
                                    Text(item.category)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(role: .destructive) {
                                    onDeleteItem(item)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
            }
            
            Button {
                showingAddPicker = true
            } label: {
                Label("Add item to collection", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Collection")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditCollectionView(collection: collection)
        }
        .sheet(isPresented: $showingAddPicker) {
            AddItemToCollectionPicker(
                items: items,
                allItems: [], // you can pass full item list from parent if needed
                collection: collection,
                onAdd: onAddItem
            )
        }
        .fullScreenCover(item: $selectedItem) { item in
            ItemNoteDetailView(item: item)
        }
    }
}

// Simple picker to choose an item to add to this collection
struct AddItemToCollectionPicker: View {
    let items: [Item]
    let allItems: [Item]
    let collection: Collection
    let onAdd: (Item) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(allItems.filter { !items.contains(where: { $0.id == $0.id }) }) { item in
                Button {
                    onAdd(item)
                    dismiss()
                } label: {
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text(item.category)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add item")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Full-screen item detail with note editing
struct ItemNoteDetailView: View {
    @State var item: Item
    @EnvironmentObject var itemStore: ItemStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item") {
                    Text(item.name)
                    Text(item.category)
                }
                
                Section("Note") {
                    TextEditor(text: $item.note)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle(item.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        if let index = itemStore.items.firstIndex(where: { $0.id == item.id }) {
                            itemStore.items[index] = item
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CollectionDetailView(
        collection: Collection(name: "Work"),
        items: [],
        onEdit: {},
        onDeleteItem: { _ in },
        onAddItem: { _ in }
    )
    .environmentObject(ItemStore())
    .environmentObject(CollectionStore())
}
