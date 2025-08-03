//
//  Item.swift
//  faizhesapla
//
//  Created by özgün güngör on 3.08.2025.
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
