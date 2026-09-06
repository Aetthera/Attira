//
//  RootTabView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-28.
//

import Foundation
import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "square.grid.2x2")
                }

            AddNewItemView()
                .tabItem {
                    Label("Add New", systemImage: "plus.circle")
                }
            
            CollectionsView()
                    .tabItem {
                        Label("Collections", systemImage: "square.stack.3d.up")
                    }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.pie")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

