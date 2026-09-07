
//
//  Collection.swift
//  Attira
//
//  Created by Alena Belova  on 2026-09-06.
//

// Collection.swift
import Foundation

struct Collection: Identifiable, Codable {
    var id: UUID
    var name: String
    var description: String?
    var itemIDs: [UUID]
    
    init(id: UUID = UUID(), name: String, description: String? = nil, itemIDs: [UUID] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.itemIDs = itemIDs
    }
}
