//
//  BackgroundRemovalView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-30.
//

import SwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

struct BackgroundRemovalView: View {
    let originalImage: UIImage
    let onSkip: () -> Void
    let onApply: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var processedImage: UIImage?
    @State private var isProcessing = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Group {
                    if let processedImage {
                        Image(uiImage: processedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 380)
                    } else {
                        Image(uiImage: originalImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 380)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))

                if isProcessing {
                    ProgressView("Removing background...")
                        .padding(.top, 8)
                } else if errorMessage != nil {
                    Text("Background removal was not available for this image.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Text("Choose Apply to use the background-removed photo, or Skip to keep the original cropped image.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                HStack(spacing: 12) {
                    Button("Skip") {
                        onSkip()
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Button("Apply") {
                        onApply(processedImage ?? originalImage)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .disabled(isProcessing)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Background Removal")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await removeBackground()
            }
        }
    }

    @MainActor
    private func removeBackground() async {
        do {
            processedImage = try await BackgroundRemovalService.removeBackground(from: originalImage)
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }
}

