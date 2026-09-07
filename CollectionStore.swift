//
//  CollectionStore.swift
//  Attira
//
//  Created by Alena Belova  on 2026-09-06.
//

import Foundation
import SwiftUI
import Combine


class CollectionStore: ObservableObject {
    @Published var collections: [Collection] = []
    
    private let saveKey = "collections"
    
    init() {
        load()
    }
    
    func addCollection(name: String, description: String?) {
        let newCollection = Collection(name: name, description: description)
        collections.append(newCollection)
        save()
    }
    
    func updateCollection(_ collection: Collection) {
        if let index = collections.firstIndex(where: { $0.id == collection.id }) {
            collections[index] = collection
            save()
        }
    }
    
    func deleteCollection(_ collection: Collection) {
        collections.removeAll { $0.id == collection.id }
        save()
    }
    
    func addItemToCollection(_ itemID: UUID, collectionID: UUID) {
        if let index = collections.firstIndex(where: { $0.id == collectionID }) {
            if !collections[index].itemIDs.contains(itemID) {
                collections[index].itemIDs.append(itemID)
                save()
            }
        }
    }
    
    func removeItemFromCollection(_ itemID: UUID, collectionID: UUID) {
        if let index = collections.firstIndex(where: { $0.id == collectionID }) {
            collections[index].itemIDs.removeAll { $0 == itemID }
            save()
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(collections) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Collection].self, from: data) {
            collections = decoded
        }
    }
}
