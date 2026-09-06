//
//  ClothingDetailView.swift
//  Attira
//
//  Created by Alena Belova on 2026-07-28.
//

import SwiftUI
import SwiftData
import UIKit

struct ClothingDetailView: View {
    let item: Item

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @State private var showingFullScreenPhoto = false

    var body: some View {
        List {
            if let image = itemImage {
                Section {
                    Button {
                        showingFullScreenPhoto = true
                    } label: {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 260)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                }
            }

            Section("Overview") {
                detailRow("Name", item.name)
                detailRow("Category", item.category)
                detailRow("Subcategory", item.subcategory)
                detailRow("Color", item.colorName)
                detailRow("Fabric", item.fabricContent)
                detailRow("Activity", item.activity)
                detailRow("Size", item.size)
                detailRow("Brand", item.brand)
                detailRow("Store", item.storeName)
                detailRow("Price", formattedPrice)
            }

            if !item.itemDescription.isEmpty {
                Section("Description") {
                    Text(item.itemDescription)
                }
            }

            Section {
                HStack {
                    Spacer()

                    Text("Added on \(formattedCreatedAt)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .padding(.vertical, 4)
            }

            Section {
                Button("Delete Item", role: .destructive) {
                    showingDeleteAlert = true
                }
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditItemView(item: item)
        }
        .fullScreenCover(isPresented: $showingFullScreenPhoto) {
            if let image = itemImage {
                ZoomablePhotoView(image: image)
            }
        }
        .alert("Delete this item?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    @ViewBuilder
    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value.isEmpty ? "—" : value)
                .multilineTextAlignment(.trailing)
        }
    }

    private var formattedPrice: String {
        if let price = item.price {
            return String(format: "$%.2f", price)
        } else {
            return "—"
        }
    }

    private var formattedCreatedAt: String {
        item.createdAt.formatted(.dateTime.day().month(.abbreviated).year())
    }

    private var itemImage: UIImage? {
        guard
            let fileName = item.photoFileName,
            let image = try? ImageStore.loadImage(from: fileName)
        else {
            return nil
        }

        return image
    }

    private func deleteItem() {
        modelContext.delete(item)
        dismiss()
    }
}

private struct ZoomablePhotoView: View {
    let image: UIImage

    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var dismissOffsetX: CGFloat = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black
                .ignoresSafeArea()

            GeometryReader { geometry in
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            maxWidth: geometry.size.width,
                            maxHeight: geometry.size.height
                        )
                        .scaleEffect(scale)
                        .offset(
                            x: offset.width + dismissOffsetX,
                            y: offset.height
                        )
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height,
                            alignment: .center
                        )
                        .gesture(
                            magnificationGesture.simultaneously(
                                with: dragGesture.simultaneously(with: swipeToDismissGesture)
                            )
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if scale > 1 {
                                    scale = 1
                                    lastScale = 1
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    scale = 2
                                    lastScale = 1
                                }
                            }
                        }
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    alignment: .center
                )
            }

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white.opacity(0.95))
                    .padding(20)
            }
        }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = min(max(scale * delta, 1), 5)
            }
            .onEnded { _ in
                lastScale = 1

                if scale <= 1 {
                    withAnimation(.easeOut(duration: 0.2)) {
                        scale = 1
                        offset = .zero
                        lastOffset = .zero
                    }
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1 else { return }

                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                guard scale > 1 else {
                    offset = .zero
                    lastOffset = .zero
                    return
                }

                lastOffset = offset
            }
    }

    private var swipeToDismissGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale == 1 else { return }
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                guard value.translation.width > 0 else { return }

                dismissOffsetX = value.translation.width
            }
            .onEnded { value in
                guard scale == 1 else {
                    dismissOffsetX = 0
                    return
                }

                if value.translation.width > 120 {
                    dismiss()
                } else {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                        dismissOffsetX = 0
                    }
                }
            }
    }
}


#Preview {
    ClothingDetailView(
        item: Item(
            name: "Black Sweater",
            itemDescription: "Soft and warm sweater for colder days.",
            category: "Tops",
            subcategory: "Sweater",
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
