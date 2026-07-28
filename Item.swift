//
//  Item.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-28.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
