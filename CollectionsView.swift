//
//  CollectionsView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-30.
//

import SwiftUI
import SwiftData

struct CollectionsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        sort: \ClothingCollection.createdAt,
        order: .reverse
    )
    private var collections: [ClothingCollection]
    
    @State private var showingCreateCollection = false
    
    var body: some View {
        NavigationStack {
            Group {
                if collections.isEmpty {
                    ContentUnavailableView(
                        "No Collections Yet",
                        systemImage: "folder",
                        description: Text(
                            "Tap the plus button to create a collection."
                        )
                    )
                } else {
                    List {
                        ForEach(collections) { collection in
                            NavigationLink {
                                CollectionDetailView(collection: collection)
                            } label: {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(collection.name)
                                        .font(.headline)
                                    
                                    Text("\(collection.items.count) item\(collection.items.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: deleteCollections)
                    }
                }
            }
            .navigationTitle("Collections")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateCollection = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Create collection")
                }
            }
            .sheet(isPresented: $showingCreateCollection) {
                CreateCollectionView()
            }
        }
    }
    
    private func deleteCollections(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(collections[index])
        }
    }
}
