//
//  CollectionsListView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-09-06.
//
import SwiftUI

struct CollectionsListView: View {
    @EnvironmentObject var collectionStore: CollectionStore
    @EnvironmentObject var itemStore: ItemStore
    
    @State private var showingCreate = false
    @State private var selectedCollection: Collection?
    
    var body: some View {
        NavigationView {
            if collectionStore.collections.isEmpty {
                ContentUnavailableView(
                    "No collections yet",
                    systemImage: "folder",
                    description: Text("Tap + to create your first collection.")
                )
            } else {
                List(collectionStore.collections) { collection in
                    NavigationLink(destination: collectionDetailView(for: collection)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(collection.name)
                                .font(.headline)
                            if let desc = collection.description, !desc.isEmpty {
                                Text(desc)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            Text("\(collection.itemIDs.count) items")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            collectionStore.deleteCollection(collection)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Collections")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreate = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreate) {
                CreateCollectionView()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    private func collectionDetailView(for collection: Collection) -> some View {
        CollectionDetailView(
            collection: collection,
            items: itemsInCollection(collection),
            onEdit: {
                // optional: open edit sheet
            },
            onDeleteItem: { item in
                collectionStore.removeItemFromCollection(item.id, collectionID: collection.id)
            },
            onAddItem: { item in
                collectionStore.addItemToCollection(item.id, collectionID: collection.id)
            }
        )
    }
    
    private func itemsInCollection(_ collection: Collection) -> [Item] {
        itemStore.items.filter { collection.itemIDs.contains($0.id) }
    }
}

#Preview {
    CollectionsListView()
        .environmentObject(ItemStore())
        .environmentObject(CollectionStore())
}
