//
//  MembershipLevel.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation

struct MembershipLevel: Codable, Identifiable, Comparable, Hashable, Sendable {
    var id: UUID
    var lastModified: Date
    var longName: String
    var shortName: String
    var price: Float
    var showOnWeb: Bool
    var prePrinted: Bool
    var shirtIncluded: Bool

    init(
        id: UUID = UUID(),
        lastModified: Date = Date(),
        longName: String = "Unknown Level",
        shortName: String = "???",
        price: Float = 0.0,
        showOnWeb: Bool = true,
        prePrinted: Bool = false,
        shirtIncluded: Bool = false
    ) {
        self.id = id
        self.lastModified = lastModified
        self.longName = longName
        self.shortName = shortName
        self.price = price
        self.showOnWeb = showOnWeb
        self.prePrinted = prePrinted
        self.shirtIncluded = shirtIncluded
    }

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
        lhs.longName.localizedCaseInsensitiveCompare(rhs.longName)
            == .orderedAscending
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

/// Make sure that things that are lower cased are suppose to be lower case
extension MembershipLevel {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Encode the UUID as a lower-case string
        try container.encode(id.uuidString.lowercased(), forKey: .id)
        try container.encode(lastModified, forKey: .lastModified)
        try container.encode(longName, forKey: .longName)
        try container.encode(shortName, forKey: .shortName)
        try container.encode(price, forKey: .price)
        try container.encode(showOnWeb, forKey: .showOnWeb)
        try container.encode(prePrinted, forKey: .prePrinted)
        try container.encode(shirtIncluded, forKey: .shirtIncluded)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode the UUID from the lower-case string
        let idString = try container.decode(String.self, forKey: .id)
        guard let uuid = UUID(uuidString: idString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .id,
                in: container,
                debugDescription: "Invalid UUID string"
            )
        }
        id = uuid
        lastModified = try container.decode(Date.self, forKey: .lastModified)
        longName = try container.decode(String.self, forKey: .longName)
        shortName = try container.decode(String.self, forKey: .shortName)
        price = try container.decode(Float.self, forKey: .price)
        showOnWeb = try container.decode(Bool.self, forKey: .showOnWeb)
        prePrinted = try container.decode(Bool.self, forKey: .prePrinted)
        shirtIncluded = try container.decode(Bool.self, forKey: .shirtIncluded)
    }
}


extension MembershipLevel: CustomStringConvertible {
    var description: String {
        """
        MembershipLevel(
            id: \(id),
            lastModified: \(lastModified),
            membershipLongName: "\(longName)",
            shortName: "\(shortName)",
            price: \(price),
            showOnWeb: \(showOnWeb),
            prePrinted: \(prePrinted),
            shirtIncluded: \(shirtIncluded)
        )
        """
    }
}
