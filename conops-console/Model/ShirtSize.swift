//
//  ShirtSize.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation

struct ShirtSize: Codable, Identifiable, Comparable, Hashable {
    let id: UUID
    let size: String
    let displayOrder: UInt32
    let initialInventory: UInt32

    enum CodingKeys: String, CodingKey {
        case id
        case size
        case displayOrder = "display_order"
        case initialInventory = "initial_inventory"
    }

    static func < (lhs: ShirtSize, rhs: ShirtSize) -> Bool {
        lhs.displayOrder < rhs.displayOrder
    }

    static func mock() -> ShirtSize {
        ShirtSize(
            id: UUID(),
            size: "Medium",
            displayOrder: 1,
            initialInventory: 100
        )
    }
}
