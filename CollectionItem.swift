//
//  CollectoinItem.swift
//  Attira
//
//  Created by Alena Belova  on 2026-09-06.
//

import Foundation

struct CollectionItem: Identifiable {
    let id: UUID
    let name: String
    let category: String
    let imageUrl: String?
    let isFavorite: Bool
    let dateAdded: Date
    let lastWorn: Date?
    let timesWorn: Int
    var note: String
    
    init(item: Item, note: String = "") {
        self.id = item.id
        self.name = item.name
        self.category = item.category
        self.imageUrl = item.imageUrl
        self.isFavorite = item.isFavorite
        self.dateAdded = item.dateAdded
        self.lastWorn = item.lastWorn
        self.timesWorn = item.timesWorn
        self.note = note
    }
}

