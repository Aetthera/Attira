//
//  GalleryFilterView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-30.
//

//
//  GalleryFilterView.swift
//  Attira
//
//  Created by Alena Belova on 2026-07-30.
//

import SwiftUI

struct GalleryFilterView: View {
    @Binding var filters: GalleryView.FilterState

    let availableCategories: [String]
    let availableSubcategories: [String]
    let availableActivities: [String]
    let availableColors: [String]
    let availableBrands: [String]
    let availableStores: [String]
    let availableSizes: [String]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                filterSection(title: "Category", options: availableCategories, selection: $filters.categories)
                filterSection(title: "Subcategory", options: availableSubcategories, selection: $filters.subcategories)
                filterSection(title: "Activity", options: availableActivities, selection: $filters.activities)
                filterSection(title: "Color", options: availableColors, selection: $filters.colors)
                filterSection(title: "Brand", options: availableBrands, selection: $filters.brands)
                filterSection(title: "Store", options: availableStores, selection: $filters.stores)
                filterSection(title: "Size", options: availableSizes, selection: $filters.sizes)

                Section("Fabric") {
                    TextField("Enter keyword, e.g. cotton", text: $filters.fabricKeyword)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear All") {
                        filters.clear()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func filterSection(
        title: String,
        options: [String],
        selection: Binding<Set<String>>
    ) -> some View {
        Section(title) {
            if options.isEmpty {
                Text("No options yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(options, id: \.self) { option in
                    Button {
                        toggle(option, in: selection)
                    } label: {
                        HStack {
                            Text(option)
                                .foregroundStyle(.primary)

                            Spacer()

                            if selection.wrappedValue.contains(option) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
        }
    }

    private func toggle(_ option: String, in selection: Binding<Set<String>>) {
        if selection.wrappedValue.contains(option) {
            selection.wrappedValue.remove(option)
        } else {
            selection.wrappedValue.insert(option)
        }
    }
}

