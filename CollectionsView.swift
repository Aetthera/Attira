//
//  CollectionsView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-30.
//

import SwiftUI

struct CollectionsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "No collections yet",
                systemImage: "square.stack.3d.up",
                description: Text("Create collections later for trips, outfits, seasonal picks, and more.")
            )
            .navigationTitle("Collections")
        }
    }
}

#Preview {
    CollectionsView()
}
