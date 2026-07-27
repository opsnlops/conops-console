//
//  ConventionDTO.swift
//  Conops Console
//
//  Created by April White on 1/5/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation

struct ConventionDTO: Codable, Identifiable, Comparable, Hashable, Sendable {
    let id: ConventionIdentifier
    let lastModified: Date
    let active: Bool
    let longName: String
    let shortName: String
    let startDate: String  // YYYY-MM-DD format (date-only, no timezone issues)
    let endDate: String  // YYYY-MM-DD format (date-only, no timezone issues)
    let preRegStartDate: Date
    let preRegEndDate: Date
    let registrationOpen: Bool
    let headerExtras: String?
    let headerGraphic: String?
    let styleSheet: String?
    let footerExtras: String?
    let badgeClass: String?
    let contactEmailAddress: String?
    let replicationMode: String?
    // Third-party service credentials (Slack / Postmark / Twilio / PayPal /
    // generic messaging) are deliberately absent from this DTO. The server
    // may still include them in its JSON response; Codable ignores unknown
    // keys, which is exactly what we want — they never land on the client.
    // Corollary: the PUT body for updateConvention won't include these fields
    // either, so the server must treat missing credential fields as
    // "unchanged" rather than null-out.
    let compareTo: ConventionIdentifier?
    let minBadgeNumber: UInt32
    let dealersDenPresent: Bool
    let dealersDenRegText: String?
    let timeZone: String
    let membershipLevels: [MembershipLevel]
    let shirtSizes: [ShirtSize]
    let mailTemplates: [String: String]

    enum CodingKeys: String, CodingKey {
        case id
        case lastModified = "last_modified"
        case active
        case longName = "long_name"
        case shortName = "short_name"
        case startDate = "start_date"
        case endDate = "end_date"
        case preRegStartDate = "pre_reg_start_date"
        case preRegEndDate = "pre_reg_end_date"
        case registrationOpen = "registration_open"
        case headerExtras = "header_extras"
        case headerGraphic = "header_graphic"
        case styleSheet = "style_sheet"
        case footerExtras = "footer_extras"
        case badgeClass = "badge_class"
        case contactEmailAddress = "contact_email_address"
        case replicationMode = "replication_mode"
        case compareTo = "compare_to"
        case minBadgeNumber = "min_badge_number"
        case dealersDenPresent = "dealers_den_present"
        case dealersDenRegText = "dealers_den_reg_text"
        case timeZone = "time_zone"
        case membershipLevels = "membership_levels"
        case shirtSizes = "shirt_sizes"
        case mailTemplates = "mail_templates"
    }

    static func < (lhs: ConventionDTO, rhs: ConventionDTO) -> Bool {
        lhs.shortName.localizedCaseInsensitiveCompare(rhs.shortName) == .orderedAscending
    }

    // Helper to format Date as YYYY-MM-DD string
    private static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    static func formatDateOnly(_ date: Date) -> String {
        dateOnlyFormatter.string(from: date)
    }

    static func parseDateOnly(_ string: String) -> Date? {
        dateOnlyFormatter.date(from: string)
    }

    static func mock() -> ConventionDTO {
        ConventionDTO(
            id: ConventionIdentifier(),
            lastModified: Date(),
            active: true,
            longName: "Mock Convention",
            shortName: "MockCon",
            startDate: formatDateOnly(Date()),
            endDate: formatDateOnly(Date().addingTimeInterval(60 * 60 * 24 * 3)),
            preRegStartDate: Date().addingTimeInterval(-60 * 60 * 24 * 30),
            preRegEndDate: Date().addingTimeInterval(-60 * 60 * 24 * 5),
            registrationOpen: true,
            headerExtras: "Mock Header",
            headerGraphic: "mock-header.png",
            styleSheet: "mock-style.css",
            footerExtras: "Mock Footer",
            badgeClass: "standard",
            contactEmailAddress: "mock@convention.com",
            replicationMode: "primary",
            compareTo: nil,
            minBadgeNumber: 100,
            dealersDenPresent: false,
            dealersDenRegText: nil,
            timeZone: "America/Chicago",
            membershipLevels: [MembershipLevel.mock()],
            shirtSizes: [ShirtSize.mock()],
            mailTemplates: ["welcome": "Welcome to MockCon!"]
        )
    }
}
