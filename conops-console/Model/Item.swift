//
//  Item.swift
//  conops-console
//
//  Created by April White on 1/4/25.
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
