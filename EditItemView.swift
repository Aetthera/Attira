//
//  EditItemView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-28.
//

import SwiftUI
import SwiftData

struct EditItemView: View {
    let item: Item

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var itemDescription: String
    @State private var selectedCategory: String
    @State private var selectedColor: String
    @State private var fabricContent: String
    @State private var selectedActivity: String
    @State private var size: String
    @State private var brand: String
    @State private var storeName: String
    @State private var price: String

    private let categories = [
        "Tops", "Bottoms", "Dresses", "Outerwear",
        "Shoes", "Accessories", "Sleepwear", "Sportswear", "Other"
    ]

    private let colors = [
        "Black", "White", "Blue", "Red", "Green",
        "Pink", "Beige", "Brown", "Grey", "Other"
    ]

    private let activities = [
        "Everyday", "Work", "Sports", "Sleeping",
        "Horse Riding", "Going Out", "Other"
    ]

    init(item: Item) {
        self.item = item
        _name = State(initialValue: item.name)
        _itemDescription = State(initialValue: item.itemDescription)
        _selectedCategory = State(initialValue: item.category)
        _selectedColor = State(initialValue: item.colorName)
        _fabricContent = State(initialValue: item.fabricContent)
        _selectedActivity = State(initialValue: item.activity)
        _size = State(initialValue: item.size)
        _brand = State(initialValue: item.brand)
        _storeName = State(initialValue: item.storeName)
        _price = State(initialValue: item.price.map { String($0) } ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Item name", text: $name)

                    TextField("Description", text: $itemDescription, axis: .vertical)
                        .lineLimit(3...5)
                }

                Section("Details") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }

                    Picker("Color", selection: $selectedColor) {
                        ForEach(colors, id: \.self) { color in
                            Text(color)
                        }
                    }

                    TextField("Fabric content", text: $fabricContent)

                    Picker("Activity", selection: $selectedActivity) {
                        ForEach(activities, id: \.self) { activity in
                            Text(activity)
                        }
                    }

                    TextField("Size", text: $size)
                    TextField("Brand", text: $brand)
                    TextField("Store name", text: $storeName)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveChanges() {
        item.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        item.itemDescription = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        item.category = selectedCategory
        item.colorName = selectedColor
        item.fabricContent = fabricContent.trimmingCharacters(in: .whitespacesAndNewlines)
        item.activity = selectedActivity
        item.size = size.trimmingCharacters(in: .whitespacesAndNewlines)
        item.brand = brand.trimmingCharacters(in: .whitespacesAndNewlines)
        item.storeName = storeName.trimmingCharacters(in: .whitespacesAndNewlines)
        item.price = Double(price.replacingOccurrences(of: ",", with: "."))

        dismiss()
    }
}

#Preview {
    EditItemView(
        item: Item(
            name: "Black Sweater",
            itemDescription: "Soft and warm sweater",
            category: "Tops",
            colorName: "Black",
            fabricContent: "Cotton",
            activity: "Everyday",
            size: "M",
            brand: "Zara",
            storeName: "Montreal",
            price: 49.99
        )
    )
}
