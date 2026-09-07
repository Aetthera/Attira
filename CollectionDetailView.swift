//
//  CollectionDetailView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-09-06.
//
import SwiftUI
import SwiftData

struct CollectionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let collection: ClothingCollection
    
    @State private var showingEditCollection = false
    @State private var showingAddItems = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        List {
            if !collection.collectionDescription.isEmpty {
                Section("Description") {
                    Text(collection.collectionDescription)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section {
                if collection.items.isEmpty {
                    ContentUnavailableView(
                        "No Items Yet",
                        systemImage: "tshirt",
                        description: Text(
                            "Use the Add Items button below to add clothing to this collection."
                        )
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(collection.items) { item in
                        NavigationLink {
                            ClothingDetailView(item: item)
                        } label: {
                            CollectionItemRow(item: item)
                        }
                    }
                    .onDelete(perform: removeItems)
                }
            } header: {
                Text("Items (\(collection.items.count))")
            }
        }
        .navigationTitle(collection.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingEditCollection = true
                    } label: {
                        Label("Edit Collection", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Collection", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                showingAddItems = true
            } label: {
                Label("Add Items", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.bar)
        }
        .sheet(isPresented: $showingEditCollection) {
            EditCollectionView(collection: collection)
        }
        .sheet(isPresented: $showingAddItems) {
            AddItemsToCollectionView(collection: collection)
        }
        .alert("Delete Collection?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(collection)
                dismiss()
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(
                "This deletes the collection only. The clothing items remain in your wardrobe."
            )
        }
    }
    
    private func removeItems(at offsets: IndexSet) {
        for index in offsets {
            let item = collection.items[index]
            collection.items.removeAll { $0.persistentModelID == item.persistentModelID }
        }
    }
}

private struct CollectionItemRow: View {
    let item: Item
    
    var body: some View {
        HStack(spacing: 12) {
            CollectionItemImage(item: item)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 3)
    }
}

private struct CollectionItemImage: View {
    let item: Item
    
    var body: some View {
        if let imageID = item.imageID,
           let image = ImageStore.shared.loadImage(id: imageID) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 58, height: 58)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            Image(systemName: "tshirt")
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 58, height: 58)
                .background(Color.secondary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
