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
    let membershipLongName: String
    let shortName: String
    let price: Float
    let showOnWeb: Bool
    let prePrinted: Bool
    let shirtIncluded: Bool

    init(
        id: UUID = UUID(),
        lastModified: Date = Date(),
        membershipLongName: String = "Unknown Level",
        shortName: String = "???",
        price: Float = 0.0,
        showOnWeb: Bool = true,
        prePrinted: Bool = false,
        shirtIncluded: Bool = false
    ) {
        self.id = id
        self.lastModified = lastModified
        self.membershipLongName = membershipLongName
        self.shortName = shortName
        self.price = price
        self.showOnWeb = showOnWeb
        self.prePrinted = prePrinted
        self.shirtIncluded = shirtIncluded
    }

    enum CodingKeys: String, CodingKey {
        case id
        case lastModified = "last_modified"
        case membershipLongName = "long_name"
        case shortName = "short_name"
        case price
        case showOnWeb = "show_on_web"
        case prePrinted = "pre_printed"
        case shirtIncluded = "shirt_included"
    }

    static func < (lhs: MembershipLevel, rhs: MembershipLevel) -> Bool {
        lhs.membershipLongName.localizedCaseInsensitiveCompare(rhs.membershipLongName)
            == .orderedAscending
    }

    static func mock() -> MembershipLevel {
        MembershipLevel(
            id: UUID(),
            lastModified: Date(),
            membershipLongName: "Mock Membership",
            shortName: "Mock",
            price: 49.99,
            showOnWeb: true,
            prePrinted: false,
            shirtIncluded: true
        )
    }
}


extension MembershipLevel: CustomStringConvertible {
    var description: String {
        """
        MembershipLevel(
            id: \(id),
            lastModified: \(lastModified),
            membershipLongName: "\(membershipLongName)",
            shortName: "\(shortName)",
            price: \(price),
            showOnWeb: \(showOnWeb),
            prePrinted: \(prePrinted),
            shirtIncluded: \(shirtIncluded)
        )
        """
    }
}
