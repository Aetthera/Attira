//
//  CollectionsView.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-30.
//

import SwiftUI

struct CollectionsView: View {
    var body: some View {
        CollectionsListView()
    }
}

#Preview {
    CollectionsView()
        .environmentObject(ItemStore())
        .environmentObject(CollectionStore())
}

