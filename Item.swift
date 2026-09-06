//
//  Item.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-28.
//

import Foundation
import SwiftData

@Model
final class Item {
    var id: UUID
    var name: String
    var itemDescription: String
    var category: String
    var subcategory: String
    var colorName: String
    var fabricContent: String
    var activity: String
    var size: String
    var brand: String
    var storeName: String
    var price: Double?
    var photoFileName: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        itemDescription: String = "",
        category: String = "Uncategorized",
        subcategory: String = "",
        colorName: String = "",
        fabricContent: String = "",
        activity: String = "",
        size: String = "",
        brand: String = "",
        storeName: String = "",
        price: Double? = nil,
        photoFileName: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.itemDescription = itemDescription
        self.category = category
        self.subcategory = subcategory
        self.colorName = colorName
        self.fabricContent = fabricContent
        self.activity = activity
        self.size = size
        self.brand = brand
        self.storeName = storeName
        self.price = price
        self.photoFileName = photoFileName
        self.createdAt = createdAt
    }
}
