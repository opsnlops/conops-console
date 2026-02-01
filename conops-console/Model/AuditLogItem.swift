//
//  AuditLogItem.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation

struct AuditLogItem: Codable, Identifiable, Comparable, Hashable, Sendable {
    let id: Int
    let lastModified: Date
    let timestamp: Date
    let conventionID: ConventionIdentifier
    let systemProduced: Bool
    let userName: String?
    let action: String

    enum CodingKeys: String, CodingKey {
        case id
        case lastModified = "last_modified"
        case timestamp
        case conventionID = "convention_id"
        case systemProduced = "system_produced"
        case userName = "user_name"
        case action
    }

    static func < (lhs: AuditLogItem, rhs: AuditLogItem) -> Bool {
        lhs.timestamp < rhs.timestamp
    }

    static func mock() -> AuditLogItem {
        AuditLogItem(
            id: 0,
            lastModified: Date(),
            timestamp: Date(),
            conventionID: ConventionIdentifier(),
            systemProduced: true,
            userName: "Mock User",
            action: "Mock action performed"
        )
    }
}
