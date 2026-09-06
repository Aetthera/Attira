//
//  AddNewItemView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-28.
//

import Foundation
import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct AddNewItemView: View {
    @Environment(\.modelContext) private var modelContext

    @AppStorage("customCategoriesData") private var customCategoriesData: Data = Data()
    @AppStorage("customActivitiesData") private var customActivitiesData: Data = Data()

    @State private var name = ""
    @State private var itemDescription = ""
    @State private var selectedCategory = "Tops"
    @State private var subcategory = ""
    @State private var selectedColor = "Black"
    @State private var fabricContent = ""
    @State private var selectedActivity = "Everyday"
    @State private var size = ""
    @State private var brand = ""
    @State private var storeName = ""
    @State private var price = ""

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var imageForCropping: UIImage?
    @State private var showingCropper = false

    @State private var showingCamera = false
    @State private var cameraImage: UIImage?

    @State private var showSavedBanner = false
    @State private var errorMessage: String?

    @State private var showingAddCategoryAlert = false
    @State private var newCategoryName = ""

    @State private var showingAddActivityAlert = false
    @State private var newActivityName = ""
    
    @State private var imageForBackgroundRemoval: UIImage?
    @State private var showingBackgroundRemoval = false

    private let defaultCategories = [
        "Tops", "Bottoms", "Dresses", "Outerwear",
        "Shoes", "Accessories", "Sleepwear", "Sportswear", "Other"
    ]

    private let defaultColors = [
        "Black", "White", "Blue", "Red", "Green",
        "Pink", "Beige", "Brown", "Grey", "Other"
    ]

    private let defaultActivities = [
        "Everyday", "Work", "Sports", "Sleeping",
        "Horse Riding", "Going Out", "Other"
    ]

    private var categories: [String] {
        let custom = loadStringArray(from: customCategoriesData)
        return Array(Set(defaultCategories + custom)).sorted()
    }

    private var activities: [String] {
        let custom = loadStringArray(from: customActivitiesData)
        return Array(Set(defaultActivities + custom)).sorted()
    }

    private var isSaveDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Form {
                    photoSection
                    basicInfoSection
                    detailsSection
                    bottomSpacingSection
                }

                if showSavedBanner {
                    savedBanner
                }
            }
            .navigationTitle("Add New")
            .scrollDismissesKeyboard(.interactively)
            .task(id: selectedPhotoItem) {
                await loadSelectedPhoto()
            }
            .onChange(of: cameraImage) { _, newImage in
                guard let newImage else { return }
                imageForCropping = newImage
                showingCropper = true
                cameraImage = nil
            }
            .animation(.easeInOut(duration: 0.25), value: showSavedBanner)
            .safeAreaInset(edge: .bottom) {
                bottomSaveBar
            }
            .sheet(isPresented: $showingCropper) {
                if let imageForCropping {
                    ImageCropperView(
                        originalImage: imageForCropping,
                        onCancel: {
                            showingCropper = false
                            self.imageForCropping = nil
                            selectedPhotoItem = nil
                        },
                        onCropped: { croppedImage in
                            showingCropper = false
                            self.imageForCropping = nil
                            imageForBackgroundRemoval = croppedImage
                            showingBackgroundRemoval = true
                        }
                    )
                }
            }
            .sheet(isPresented: $showingBackgroundRemoval) {
                if let imageForBackgroundRemoval {
                    BackgroundRemovalView(
                        originalImage: imageForBackgroundRemoval,
                        onSkip: {
                            selectedImage = imageForBackgroundRemoval
                            self.imageForBackgroundRemoval = nil
                            showingBackgroundRemoval = false
                        },
                        onApply: { processedImage in
                            selectedImage = processedImage
                            self.imageForBackgroundRemoval = nil
                            showingBackgroundRemoval = false
                        }
                    )
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraPickerView(selectedImage: $cameraImage)
            }
            .alert("Photo Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
            .alert("Add New Category", isPresented: $showingAddCategoryAlert) {
                TextField("Category name", text: $newCategoryName)

                Button("Cancel", role: .cancel) {
                    newCategoryName = ""
                }

                Button("Add") {
                    addCategory()
                }
            } message: {
                Text("Create your own category.")
            }
            .alert("Add New Activity", isPresented: $showingAddActivityAlert) {
                TextField("Activity name", text: $newActivityName)

                Button("Cancel", role: .cancel) {
                    newActivityName = ""
                }

                Button("Add") {
                    addActivity()
                }
            } message: {
                Text("Create your own activity.")
            }
        }
    }

    private var photoSection: some View {
        Section("Photo") {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.purple.opacity(0.08))
                        .frame(height: 200)

                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(6)
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 34))
                                .foregroundStyle(.purple)

                            Text("No photo selected")
                                .font(.headline)

                            Text("Choose a photo or take one now.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                HStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title3)

                            Text("Choose Photo")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)

                    Button {
                        showingCamera = true
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "camera")
                                .font(.title3)

                            Text("Take a Photo")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background(Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var basicInfoSection: some View {
        Section("Basic Info") {
            TextField("Item name", text: $name)

            TextField("Description", text: $itemDescription, axis: .vertical)
                .lineLimit(3...5)
        }
    }

    private var detailsSection: some View {
        Section("Details") {
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }

            Button("Add New Category") {
                showingAddCategoryAlert = true
            }

            TextField("Subcategory (e.g. Sweater)", text: $subcategory)

            Picker("Color", selection: $selectedColor) {
                ForEach(defaultColors, id: \.self) { color in
                    Text(color)
                }
            }

            TextField("Fabric content", text: $fabricContent)

            Picker("Activity", selection: $selectedActivity) {
                ForEach(activities, id: \.self) { activity in
                    Text(activity).tag(activity)
                }
            }

            Button("Add New Activity") {
                showingAddActivityAlert = true
            }

            TextField("Size", text: $size)
            TextField("Brand", text: $brand)
            TextField("Store name", text: $storeName)
            TextField("Price", text: $price)
                .keyboardType(.decimalPad)
        }
    }

    private var bottomSpacingSection: some View {
        Section {
            Color.clear
                .frame(height: 90)
                .listRowBackground(Color.clear)
        }
    }

    private var savedBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.white)

            Text("Clothing item added")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.green)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 8)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(1)
    }

    private var bottomSaveBar: some View {
        VStack {
            Button {
                saveItem()
            } label: {
                Text("Save Item")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSaveDisabled ? Color.gray : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(isSaveDisabled)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
    }

    @MainActor
    private func loadSelectedPhoto() async {
        guard let selectedPhotoItem else { return }

        do {
            if let data = try await selectedPhotoItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                imageForCropping = image
                showingCropper = true
            } else {
                errorMessage = "The selected photo could not be loaded."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func saveItem() {
        let parsedPrice = Double(price.replacingOccurrences(of: ",", with: "."))

        do {
            let fileName = try selectedImage.map { try ImageStore.saveImage($0) }

            let newItem = Item(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                itemDescription: itemDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                category: selectedCategory,
                subcategory: subcategory.trimmingCharacters(in: .whitespacesAndNewlines),
                colorName: selectedColor,
                fabricContent: fabricContent.trimmingCharacters(in: .whitespacesAndNewlines),
                activity: selectedActivity,
                size: size.trimmingCharacters(in: .whitespacesAndNewlines),
                brand: brand.trimmingCharacters(in: .whitespacesAndNewlines),
                storeName: storeName.trimmingCharacters(in: .whitespacesAndNewlines),
                price: parsedPrice,
                photoFileName: fileName
            )

            modelContext.insert(newItem)
            resetForm()
            showTemporaryBanner()
        } catch {
            errorMessage = "The image could not be saved locally."
        }
    }

    private func resetForm() {
        name = ""
        itemDescription = ""
        selectedCategory = categories.first ?? "Tops"
        subcategory = ""
        selectedColor = "Black"
        fabricContent = ""
        selectedActivity = activities.first ?? "Everyday"
        size = ""
        brand = ""
        storeName = ""
        price = ""
        selectedPhotoItem = nil
        selectedImage = nil
        imageForCropping = nil
        showingCropper = false
        showingCamera = false
        cameraImage = nil
    }

    private func showTemporaryBanner() {
        showSavedBanner = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            showSavedBanner = false
        }
    }

    

    private func addCategory() {
        let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var current = loadStringArray(from: customCategoriesData)
        if !current.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            current.append(trimmed)
            saveStringArray(current, to: &customCategoriesData)
        }

        selectedCategory = trimmed
        newCategoryName = ""
    }

    private func addActivity() {
        let trimmed = newActivityName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var current = loadStringArray(from: customActivitiesData)
        if !current.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            current.append(trimmed)
            saveStringArray(current, to: &customActivitiesData)
        }

        selectedActivity = trimmed
        newActivityName = ""
    }

    private func loadStringArray(from data: Data) -> [String] {
        guard let array = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return array
    }

    private func saveStringArray(_ array: [String], to storage: inout Data) {
        guard let data = try? JSONEncoder().encode(array) else { return }
        storage = data
    }
}

#Preview {
    AddNewItemView()
}
