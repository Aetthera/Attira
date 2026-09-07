
//
//  Collection.swift
//  Attira
//
//  Created by Alena Belova  on 2026-09-06.
//

// Collection.swift
import Foundation
import SwiftData

@Model
final class ClothingCollection {
    var id: UUID
    var name: String
    var collectionDescription: String
    var createdAt: Date
    
    @Relationship
    var items: [Item]
    
    init(
        id: UUID = UUID(),
        name: String,
        collectionDescription: String = "",
        createdAt: Date = .now,
        items: [Item] = []
    ) {
        self.id = id
        self.name = name
        self.collectionDescription = collectionDescription
        self.createdAt = createdAt
        self.items = items
    }
}
