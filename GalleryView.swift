//
//  GalleryView.swift
//  Attira
//
//  Created by Alena Belova on 2026-07-28.
//

import SwiftUI
import SwiftData

struct GalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.createdAt, order: .reverse) private var items: [Item]

    enum SortMode: String, CaseIterable {
        case none
        case newestDate
        case oldestDate
    }

    struct FilterState: Equatable {
        var categories: Set<String> = []
        var subcategories: Set<String> = []
        var activities: Set<String> = []
        var brands: Set<String> = []
        var stores: Set<String> = []
        var colors: Set<String> = []
        var sizes: Set<String> = []
        var fabricKeyword: String = ""

        var hasActiveFilters: Bool {
            !categories.isEmpty ||
            !subcategories.isEmpty ||
            !activities.isEmpty ||
            !brands.isEmpty ||
            !stores.isEmpty ||
            !colors.isEmpty ||
            !sizes.isEmpty ||
            !fabricKeyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        mutating func clear() {
            categories.removeAll()
            subcategories.removeAll()
            activities.removeAll()
            brands.removeAll()
            stores.removeAll()
            colors.removeAll()
            sizes.removeAll()
            fabricKeyword = ""
        }

        var activeFilterCount: Int {
            var count = 0
            if !categories.isEmpty { count += 1 }
            if !subcategories.isEmpty { count += 1 }
            if !activities.isEmpty { count += 1 }
            if !brands.isEmpty { count += 1 }
            if !stores.isEmpty { count += 1 }
            if !colors.isEmpty { count += 1 }
            if !sizes.isEmpty { count += 1 }
            if !fabricKeyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { count += 1 }
            return count
        }
    }

    @State private var isEditing = false
    @State private var selectedItemIDs: Set<UUID> = []
    @State private var showingDeleteConfirmation = false
    @State private var searchText = ""
    @State private var collapsedGroups: Set<String> = []
    @State private var selectedSortMode: SortMode = .none
    @State private var showingFilters = false
    @State private var filters = FilterState()

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private var availableCategories: [String] {
        uniqueValues { $0.category }
    }

    private var availableSubcategories: [String] {
        uniqueValues { $0.subcategory }
    }

    private var availableActivities: [String] {
        uniqueValues { $0.activity }
    }

    private var availableBrands: [String] {
        uniqueValues { $0.brand }
    }

    private var availableStores: [String] {
        uniqueValues { $0.storeName }
    }

    private var availableColors: [String] {
        uniqueValues { $0.colorName }
    }

    private var availableSizes: [String] {
        uniqueValues { $0.size }
    }

    private var filteredItems: [Item] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFabricKeyword = filters.fabricKeyword.trimmingCharacters(in: .whitespacesAndNewlines)

        return items.filter { item in
            let matchesSearch =
                trimmedSearch.isEmpty ||
                item.name.localizedCaseInsensitiveContains(trimmedSearch) ||
                item.category.localizedCaseInsensitiveContains(trimmedSearch) ||
                item.subcategory.localizedCaseInsensitiveContains(trimmedSearch) ||
                item.brand.localizedCaseInsensitiveContains(trimmedSearch) ||
                item.fabricContent.localizedCaseInsensitiveContains(trimmedSearch) ||
                item.activity.localizedCaseInsensitiveContains(trimmedSearch) ||
                item.size.localizedCaseInsensitiveContains(trimmedSearch) ||
                item.itemDescription.localizedCaseInsensitiveContains(trimmedSearch) ||
                item.colorName.localizedCaseInsensitiveContains(trimmedSearch) ||
                item.storeName.localizedCaseInsensitiveContains(trimmedSearch)

            let matchesCategory =
                filters.categories.isEmpty || filters.categories.contains(item.category)

            let matchesSubcategory =
                filters.subcategories.isEmpty || filters.subcategories.contains(item.subcategory)

            let matchesActivity =
                filters.activities.isEmpty || filters.activities.contains(item.activity)

            let matchesBrand =
                filters.brands.isEmpty || filters.brands.contains(item.brand)

            let matchesStore =
                filters.stores.isEmpty || filters.stores.contains(item.storeName)

            let matchesColor =
                filters.colors.isEmpty || filters.colors.contains(item.colorName)

            let matchesSize =
                filters.sizes.isEmpty || filters.sizes.contains(item.size)

            let matchesFabric =
                trimmedFabricKeyword.isEmpty ||
                item.fabricContent.localizedCaseInsensitiveContains(trimmedFabricKeyword)

            return
                matchesSearch &&
                matchesCategory &&
                matchesSubcategory &&
                matchesActivity &&
                matchesBrand &&
                matchesStore &&
                matchesColor &&
                matchesSize &&
                matchesFabric
        }
    }

    private var groupedItems: [(groupTitle: String, items: [Item])] {
        switch selectedSortMode {
        case .none:
            let groups = Dictionary(grouping: filteredItems) { item in
                let trimmed = item.category.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? "Uncategorized" : trimmed
            }

            return groups
                .map { (groupTitle: $0.key, items: $0.value) }
                .sorted {
                    $0.groupTitle.localizedCaseInsensitiveCompare($1.groupTitle) == .orderedAscending
                }

        case .newestDate, .oldestDate:
            let grouped = Dictionary(grouping: sortedItemsByDate) { item in
                formattedDate(item.createdAt)
            }

            let orderedKeys = grouped.keys.sorted { lhs, rhs in
                guard
                    let leftDate = dateFormatter.date(from: lhs),
                    let rightDate = dateFormatter.date(from: rhs)
                else {
                    return lhs < rhs
                }

                switch selectedSortMode {
                case .none:
                    return lhs < rhs
                case .newestDate:
                    return leftDate > rightDate
                case .oldestDate:
                    return leftDate < rightDate
                }
            }

            return orderedKeys.map { key in
                (groupTitle: key, items: grouped[key] ?? [])
            }
        }
    }

    private var sortedItemsByDate: [Item] {
        switch selectedSortMode {
        case .none:
            return filteredItems
        case .newestDate:
            return filteredItems.sorted { $0.createdAt > $1.createdAt }
        case .oldestDate:
            return filteredItems.sorted { $0.createdAt < $1.createdAt }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if items.isEmpty {
                        ContentUnavailableView(
                            "No clothes yet",
                            systemImage: "tshirt",
                            description: Text("Add your first clothing item in Add New.")
                        )
                    } else if filteredItems.isEmpty {
                        ContentUnavailableView(
                            "No matching items",
                            systemImage: "line.3.horizontal.decrease.circle",
                            description: Text("Try adjusting your search or filters.")
                        )
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 20) {
                                ForEach(groupedItems, id: \.groupTitle) { group in
                                    VStack(alignment: .leading, spacing: 12) {
                                        groupHeader(for: group)

                                        if !collapsedGroups.contains(group.groupTitle) {
                                            LazyVGrid(columns: columns, alignment: .center, spacing: 18) {
                                                ForEach(group.items) { item in
                                                    if isEditing {
                                                        Button {
                                                            toggleSelection(for: item)
                                                        } label: {
                                                            ClothingCardView(
                                                                item: item,
                                                                isSelected: selectedItemIDs.contains(item.id),
                                                                isEditing: true
                                                            )
                                                        }
                                                        .buttonStyle(.plain)
                                                    } else {
                                                        NavigationLink {
                                                            ClothingDetailView(item: item)
                                                        } label: {
                                                            ClothingCardView(
                                                                item: item,
                                                                isSelected: false,
                                                                isEditing: false
                                                            )
                                                        }
                                                        .buttonStyle(.plain)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                            .padding(.bottom, isEditing ? 120 : 100)
                        }
                    }
                }
                .navigationTitle("Gallery")
                .searchable(text: $searchText, prompt: "Search clothes")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            Button("By newer date") {
                                selectedSortMode = .newestDate
                                collapsedGroups.removeAll()
                            }

                            Button("By oldest date") {
                                selectedSortMode = .oldestDate
                                collapsedGroups.removeAll()
                            }

                            Button("Clear Sort") {
                                selectedSortMode = .none
                                collapsedGroups.removeAll()
                            }
                        } label: {
                            Text("Sort")
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        if !filteredItems.isEmpty {
                            Button(isEditing ? "Done" : "Edit") {
                                if isEditing {
                                    isEditing = false
                                    selectedItemIDs.removeAll()
                                } else {
                                    isEditing = true
                                }
                            }
                        }
                    }
                }

                if isEditing && !filteredItems.isEmpty {
                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        Text(
                            selectedItemIDs.isEmpty
                            ? "Select Items to Delete"
                            : "Delete Selected (\(selectedItemIDs.count))"
                        )
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedItemIDs.isEmpty ? Color.gray : Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    }
                    .disabled(selectedItemIDs.isEmpty)
                } else {
                    filterButton
                }
            }
            .sheet(isPresented: $showingFilters) {
                GalleryFilterView(
                    filters: $filters,
                    availableCategories: availableCategories,
                    availableSubcategories: availableSubcategories,
                    availableActivities: availableActivities,
                    availableColors: availableColors,
                    availableBrands: availableBrands,
                    availableStores: availableStores,
                    availableSizes: availableSizes
                )
            }
            .alert("Delete selected items?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteSelectedItems()
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private var filterButton: some View {
        Button {
            showingFilters = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .font(.title3)

                Text("Filter")
                    .font(.headline)

                if filters.hasActiveFilters {
                    Text("\(filters.activeFilterCount)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(Color.blue)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
    }

    private func groupHeader(for group: (groupTitle: String, items: [Item])) -> some View {
        Button {
            toggleGroup(group.groupTitle)
        } label: {
            HStack(spacing: 10) {
                Text(group.groupTitle)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("\(group.items.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: collapsedGroups.contains(group.groupTitle) ? "chevron.down" : "chevron.up")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func toggleGroup(_ title: String) {
        if collapsedGroups.contains(title) {
            collapsedGroups.remove(title)
        } else {
            collapsedGroups.insert(title)
        }
    }

    private func toggleSelection(for item: Item) {
        if selectedItemIDs.contains(item.id) {
            selectedItemIDs.remove(item.id)
        } else {
            selectedItemIDs.insert(item.id)
        }
    }

    private func deleteSelectedItems() {
        let itemsToDelete = items.filter { selectedItemIDs.contains($0.id) }

        for item in itemsToDelete {
            modelContext.delete(item)
        }

        selectedItemIDs.removeAll()
        isEditing = false
    }

    private func formattedDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }

    private func uniqueValues(for keyPath: (Item) -> String) -> [String] {
        Array(
            Set(
                items
                    .map(keyPath)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            )
        )
        .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }
}

#Preview {
    GalleryView()
}
