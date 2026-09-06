//
//  SettingsView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-30.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedIcon: AppIcon = AppIcon.current
    @State private var iconChangeError: String?

    var body: some View {
        NavigationStack {
            List {
                Section("App Icon") {
                    ForEach(AppIcon.allCases) { icon in
                        Button {
                            updateAppIcon(to: icon)
                        } label: {
                            HStack(spacing: 14) {
                                Image(icon.previewImageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(icon.displayName)
                                        .foregroundStyle(.primary)

                                    if icon == .primary {
                                        Text("Default icon")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                if selectedIcon == icon {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section("Launch Screen") {
                    Text("Use your pink Attira artwork as the launch screen background in Xcode.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .alert("Couldn’t change app icon", isPresented: Binding(
                get: { iconChangeError != nil },
                set: { if !$0 { iconChangeError = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(iconChangeError ?? "Unknown error")
            }
        }
    }

    private func updateAppIcon(to icon: AppIcon) {
        guard UIApplication.shared.supportsAlternateIcons else {
            iconChangeError = "This device does not support alternate app icons."
            return
        }

        UIApplication.shared.setAlternateIconName(icon.iconName) { error in
            if let error {
                iconChangeError = error.localizedDescription
            } else {
                selectedIcon = icon
            }
        }
    }
}

enum AppIcon: String, CaseIterable, Identifiable {
    case primary
    case bunny
    case cherry
    case heart
    case flower

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .primary:
            return "Classic Attira"
        case .bunny:
            return "Bunny"
        case .cherry:
            return "Cherry"
        case .heart:
            return "Heart"
        case .flower:
            return "Flower"
        }
    }

    var iconName: String? {
        switch self {
        case .primary:
            return nil
        case .bunny:
            return "BunnyIcon"
        case .cherry:
            return "CherryIcon"
        case .heart:
            return "HeartIcon"
        case .flower:
            return "FlowerIcon"
        }
    }

    var previewImageName: String {
        switch self {
        case .primary:
            return "AppIconPreviewPrimary"
        case .bunny:
            return "AppIconPreviewBunny"
        case .cherry:
            return "AppIconPreviewCherry"
        case .heart:
            return "AppIconPreviewHeart"
        case .flower:
            return "AppIconPreviewFlower"
        }
    }

    static var current: AppIcon {
        switch UIApplication.shared.alternateIconName {
        case nil:
            return .primary
        case "BunnyIcon":
            return .bunny
        case "CherryIcon":
            return .cherry
        case "HeartIcon":
            return .heart
        case "FlowerIcon":
            return .flower
        default:
            return .primary
        }
    }
}
