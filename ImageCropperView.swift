//
//  ImageCropperView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-29.
//


import SwiftUI
import UIKit

struct ImageCropperView: View {
    let originalImage: UIImage
    let onCancel: () -> Void
    let onCropped: (UIImage) -> Void

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    private let cropAspectRatio: CGFloat = 1.0
    private let horizontalPadding: CGFloat = 24

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let availableWidth = max(geometry.size.width - (horizontalPadding * 2), 1)
                let cropWidth = max(availableWidth, 1)
                let cropHeight = max(cropWidth / cropAspectRatio, 1)

                ZStack {
                    Color.black.ignoresSafeArea()

                    VStack(spacing: 24) {
                        Spacer()

                        cropArea(cropWidth: cropWidth, cropHeight: cropHeight)

                        Spacer()
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            onCancel()
                        }
                        .foregroundStyle(.white)
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Use Crop") {
                            let cropped = renderCroppedImage(
                                cropSize: CGSize(width: cropWidth, height: cropHeight)
                            )
                            onCropped(cropped)
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    @ViewBuilder
    private func cropArea(cropWidth: CGFloat, cropHeight: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.45))

            Image(uiImage: originalImage)
                .resizable()
                .scaledToFill()
                .scaleEffect(scale)
                .offset(offset)
                .frame(width: cropWidth, height: cropHeight)
                .clipped()
                .gesture(dragGesture)
                .simultaneousGesture(magnificationGesture)

            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: 2)
                .frame(width: cropWidth, height: cropHeight)
        }
        .frame(width: cropWidth, height: cropHeight)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(alignment: .bottom) {
            Text("Move and zoom the image to fit the frame")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.9))
                .padding(.top, 12)
                .offset(y: 34)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = max(1, lastScale * value)
            }
            .onEnded { _ in
                lastScale = scale
            }
    }

    private func renderCroppedImage(cropSize: CGSize) -> UIImage {
        let safeWidth = max(cropSize.width, 1)
        let safeHeight = max(cropSize.height, 1)
        let safeCropSize = CGSize(width: safeWidth, height: safeHeight)

        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale

        let renderer = UIGraphicsImageRenderer(size: safeCropSize, format: format)

        return renderer.image { _ in
            let baseSize = originalImage.size
            let widthRatio = safeCropSize.width / max(baseSize.width, 1)
            let heightRatio = safeCropSize.height / max(baseSize.height, 1)
            let fillScale = max(widthRatio, heightRatio)

            let finalScale = fillScale * max(scale, 1)
            let scaledImageSize = CGSize(
                width: baseSize.width * finalScale,
                height: baseSize.height * finalScale
            )

            let drawOrigin = CGPoint(
                x: (safeCropSize.width - scaledImageSize.width) / 2 + offset.width,
                y: (safeCropSize.height - scaledImageSize.height) / 2 + offset.height
            )

            originalImage.draw(in: CGRect(origin: drawOrigin, size: scaledImageSize))
        }
    }
}

#Preview {
    ImageCropperView(
        originalImage: UIImage(systemName: "photo") ?? UIImage(),
        onCancel: {},
        onCropped: { _ in }
    )
}
