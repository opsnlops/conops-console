//
//  MembershipLevel.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation

struct MembershipLevel: Codable, Identifiable, Comparable, Hashable, Sendable {
    let id: UUID
    let lastModified: Date
    let longName: String
    let shortName: String
    let price: Float
    let showOnWeb: Bool
    let prePrinted: Bool
    let shirtIncluded: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case lastModified = "last_modified"
        case longName = "long_name"
        case shortName = "short_name"
        case price
        case showOnWeb = "show_on_web"
        case prePrinted = "pre_printed"
        case shirtIncluded = "shirt_included"
    }

    static func < (lhs: MembershipLevel, rhs: MembershipLevel) -> Bool {
        lhs.longName.localizedCaseInsensitiveCompare(rhs.longName) == .orderedAscending
    }

    static func mock() -> MembershipLevel {
        MembershipLevel(
            id: UUID(),
            lastModified: Date(),
            longName: "Mock Membership",
            shortName: "Mock",
            price: 49.99,
            showOnWeb: true,
            prePrinted: false,
            shirtIncluded: true
        )
    }
}
