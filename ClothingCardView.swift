//
//  ClothingCardCiew.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-28.
//

import SwiftUI

struct ClothingCardView: View {
    let item: Item
    var isSelected: Bool = false
    var isEditing: Bool = false

    private let cardHeight: CGFloat = 214
    private let imageHeight: CGFloat = 118

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            imageBlock

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name.isEmpty ? "Unnamed Item" : item.name)
                    .font(.headline)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight, alignment: .top)
        .background(backgroundFill)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .overlay(alignment: .topTrailing) {
            if isEditing {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 28, height: 28)

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isSelected ? .blue : .gray)
                }
                .padding(10)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private var imageBlock: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))

            if let image = ImageStore.loadImage(from: item.photoFileName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: imageHeight)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardColor)
                    .overlay {
                        Image(systemName: "tshirt.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white.opacity(0.9))
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: imageHeight)
        .clipped()
    }

    private var backgroundFill: Color {
        isSelected ? Color.blue.opacity(0.10) : Color(.secondarySystemBackground)
    }

    private var cardColor: Color {
        switch item.colorName.lowercased() {
        case "black": return .black
        case "white": return .gray.opacity(0.35)
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        case "pink": return .pink
        case "beige": return .brown.opacity(0.45)
        case "brown": return .brown
        case "grey", "gray": return .gray
        default: return .purple.opacity(0.65)
        }
    }
}

#Preview {
    ClothingCardView(
        item: Item(
            name: "Black Sweater",
            itemDescription: "Soft knit sweater",
            category: "Tops",
            colorName: "Black",
            fabricContent: "Cotton",
            activity: "Everyday",
            size: "M",
            brand: "Zara",
            storeName: "Montreal",
            price: 49.99
        ),
        isSelected: true,
        isEditing: true
    )
}
