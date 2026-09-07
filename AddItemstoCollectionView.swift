//
//  AddItemstoCollectionView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-09-07.
//

import SwiftUI
import SwiftData

struct AddItemsToCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Item.createdAt, order: .reverse)
    private var allItems: [Item]
    
    let collection: ClothingCollection
    
    private var availableItems: [Item] {
        allItems.filter { item in
            !collection.items.contains {
                $0.persistentModelID == item.persistentModelID
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if availableItems.isEmpty {
                    ContentUnavailableView(
                        "No Available Items",
                        systemImage: "tshirt",
                        description: Text(
                            "All wardrobe items have already been added to this collection."
                        )
                    )
                } else {
                    List(availableItems) { item in
                        Button {
                            collection.items.append(item)
                        } label: {
                            HStack(spacing: 12) {
                                AddItemRowImage(item: item)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .foregroundStyle(.primary)
                                    
                                    Text(item.category)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct AddItemRowImage: View {
    let item: Item
    
    var body: some View {
        if let imageID = item.imageID,
           let image = ImageStore.shared.loadImage(id: imageID) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 9))
        } else {
            Image(systemName: "tshirt")
                .foregroundStyle(.secondary)
                .frame(width: 52, height: 52)
                .background(Color.secondary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 9))
        }
    }
}

