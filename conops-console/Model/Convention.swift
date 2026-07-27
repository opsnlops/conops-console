//
//  Convention.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation
import SwiftData

/// This struct (or class) is your local SwiftData model.
/// It's intentionally separate from the DTO.
@Model
final class Convention {
    // SwiftData typically wants `var` so it can mutate these properties
    @Attribute(.unique) var id: ConventionIdentifier
    var lastModified: Date
    var active: Bool
    var longName: String
    @Attribute(.unique) var shortName: String
    var startDate: Date
    var endDate: Date
    var preRegStartDate: Date
    var preRegEndDate: Date
    var registrationOpen: Bool
    var headerExtras: String?
    var headerGraphic: String?
    var styleSheet: String?
    var footerExtras: String?
    var badgeClass: String?
    var contactEmailAddress: String?
    var replicationMode: String?
    // Third-party service credentials (Slack, Postmark, Twilio, PayPal, generic
    // messaging service) are intentionally not persisted on the client. They
    // were previously synced in plaintext to SwiftData, which exposed working
    // credentials to anyone with physical access to a staff device.
    var compareTo: ConventionIdentifier?
    var minBadgeNumber: UInt32
    var dealersDenPresent: Bool
    var dealersDenRegText: String?
    var timeZone: String

    // For membershipLevels, shirtSizes, and mailTemplates,
    // SwiftData might require special handling.
    // For now, let's just keep them as direct properties
    var membershipLevels: [MembershipLevel]
    var shirtSizes: [ShirtSize]
    var mailTemplates: [String: String]

    // One to many, hopefully every covention has lots of these!
    @Relationship(deleteRule: .cascade)
    var attendees = [Attendee]()


    // MARK: - Simple init
    init(
        id: ConventionIdentifier,
        lastModified: Date,
        active: Bool,
        longName: String,
        shortName: String,
        startDate: Date,
        endDate: Date,
        preRegStartDate: Date,
        preRegEndDate: Date,
        registrationOpen: Bool,
        headerExtras: String? = nil,
        headerGraphic: String? = nil,
        styleSheet: String? = nil,
        footerExtras: String? = nil,
        badgeClass: String? = nil,
        contactEmailAddress: String? = nil,
        replicationMode: String? = nil,
        compareTo: ConventionIdentifier? = nil,
        minBadgeNumber: UInt32,
        dealersDenPresent: Bool,
        dealersDenRegText: String? = nil,
        timeZone: String = "America/Chicago",
        membershipLevels: [MembershipLevel],
        shirtSizes: [ShirtSize],
        mailTemplates: [String: String]
    ) {
        self.id = id
        self.lastModified = lastModified
        self.active = active
        self.longName = longName
        self.shortName = shortName
        self.startDate = startDate
        self.endDate = endDate
        self.preRegStartDate = preRegStartDate
        self.preRegEndDate = preRegEndDate
        self.registrationOpen = registrationOpen
        self.headerExtras = headerExtras
        self.headerGraphic = headerGraphic
        self.styleSheet = styleSheet
        self.footerExtras = footerExtras
        self.badgeClass = badgeClass
        self.contactEmailAddress = contactEmailAddress
        self.replicationMode = replicationMode
        self.compareTo = compareTo
        self.minBadgeNumber = minBadgeNumber
        self.dealersDenPresent = dealersDenPresent
        self.dealersDenRegText = dealersDenRegText
        self.timeZone = timeZone
        self.membershipLevels = membershipLevels
        self.shirtSizes = shirtSizes
        self.mailTemplates = mailTemplates
    }
}


// MARK: - DTO conversions
extension Convention {

    static func fromDTO(_ dto: ConventionDTO) -> Convention {
        // Parse date-only strings (YYYY-MM-DD) to Date, defaulting to current date if invalid
        let startDate = ConventionDTO.parseDateOnly(dto.startDate) ?? Date()
        let endDate = ConventionDTO.parseDateOnly(dto.endDate) ?? Date()

        return Convention(
            id: dto.id,
            lastModified: dto.lastModified,
            active: dto.active,
            longName: dto.longName,
            shortName: dto.shortName,
            startDate: startDate,
            endDate: endDate,
            preRegStartDate: dto.preRegStartDate,
            preRegEndDate: dto.preRegEndDate,
            registrationOpen: dto.registrationOpen,
            headerExtras: dto.headerExtras,
            headerGraphic: dto.headerGraphic,
            styleSheet: dto.styleSheet,
            footerExtras: dto.footerExtras,
            badgeClass: dto.badgeClass,
            contactEmailAddress: dto.contactEmailAddress,
            replicationMode: dto.replicationMode,
            compareTo: dto.compareTo,
            minBadgeNumber: dto.minBadgeNumber,
            dealersDenPresent: dto.dealersDenPresent,
            dealersDenRegText: dto.dealersDenRegText,
            timeZone: dto.timeZone,
            membershipLevels: dto.membershipLevels,
            shirtSizes: dto.shirtSizes,
            mailTemplates: dto.mailTemplates
        )

    }

    func toDTO() -> ConventionDTO {
        ConventionDTO(
            id: self.id,
            lastModified: self.lastModified,
            active: self.active,
            longName: self.longName,
            shortName: self.shortName,
            startDate: ConventionDTO.formatDateOnly(self.startDate),
            endDate: ConventionDTO.formatDateOnly(self.endDate),
            preRegStartDate: self.preRegStartDate,
            preRegEndDate: self.preRegEndDate,
            registrationOpen: self.registrationOpen,
            headerExtras: self.headerExtras,
            headerGraphic: self.headerGraphic,
            styleSheet: self.styleSheet,
            footerExtras: self.footerExtras,
            badgeClass: self.badgeClass,
            contactEmailAddress: self.contactEmailAddress,
            replicationMode: self.replicationMode,
            compareTo: self.compareTo,
            minBadgeNumber: self.minBadgeNumber,
            dealersDenPresent: self.dealersDenPresent,
            dealersDenRegText: self.dealersDenRegText,
            timeZone: self.timeZone,
            membershipLevels: self.membershipLevels,
            shirtSizes: self.shirtSizes,
            mailTemplates: self.mailTemplates
        )
    }
}

// MARK: - Update helper
extension Convention {
    func update(from updated: Convention) {
        self.lastModified = updated.lastModified
        self.active = updated.active
        self.longName = updated.longName
        self.shortName = updated.shortName
        self.startDate = updated.startDate
        self.endDate = updated.endDate
        self.preRegStartDate = updated.preRegStartDate
        self.preRegEndDate = updated.preRegEndDate
        self.registrationOpen = updated.registrationOpen
        self.headerExtras = updated.headerExtras
        self.headerGraphic = updated.headerGraphic
        self.styleSheet = updated.styleSheet
        self.footerExtras = updated.footerExtras
        self.badgeClass = updated.badgeClass
        self.contactEmailAddress = updated.contactEmailAddress
        self.replicationMode = updated.replicationMode
        self.compareTo = updated.compareTo
        self.minBadgeNumber = updated.minBadgeNumber
        self.dealersDenPresent = updated.dealersDenPresent
        self.dealersDenRegText = updated.dealersDenRegText
        self.timeZone = updated.timeZone
        self.membershipLevels = updated.membershipLevels
        self.shirtSizes = updated.shirtSizes
        self.mailTemplates = updated.mailTemplates
    }
}

// MARK: - Preview
extension Convention {

    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(
            for: Convention.self,
            configurations: ModelConfiguration(
                isStoredInMemoryOnly: true)
        )

        for i in 0..<10 {

            let number = Double(i)

            container.mainContext.insert(
                Convention(
                    id: ConventionIdentifier(),
                    lastModified: Date(),
                    active: true,
                    longName: "Sample Convention \(i)",
                    shortName: "SC\(i)",
                    startDate: Date().addingTimeInterval(60 * 60 * 24 * number),
                    endDate: Date().addingTimeInterval(60 * 60 * 24 * (10 * number)),
                    preRegStartDate: Date().addingTimeInterval(60 * 60 * 24 * (20 * number)),
                    preRegEndDate: Date().addingTimeInterval(60 * 60 * 24 * (30 * number)),
                    registrationOpen: true,
                    headerExtras: Optional<String>.none,
                    headerGraphic: Optional<String>.none,
                    styleSheet: Optional<String>.none,
                    footerExtras: Optional<String>.none,
                    badgeClass: Optional<String>.none,
                    contactEmailAddress: "bunny\(i)@example.com",
                    replicationMode: Optional<String>.none,
                    compareTo: Optional<ConventionIdentifier>.none,
                    minBadgeNumber: UInt32(i),
                    dealersDenPresent: false,
                    dealersDenRegText: Optional<String>.none,
                    membershipLevels: [],
                    shirtSizes: [],
                    mailTemplates: [:]
                )
            )
        }

        return container
    }
}

// MARK: - Encoding / Decoding
extension Convention: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case lastModified
        case active
        case longName
        case shortName
        case startDate
        case endDate
        case preRegStartDate
        case preRegEndDate
        case registrationOpen
        case headerExtras
        case headerGraphic
        case styleSheet
        case footerExtras
        case badgeClass
        case contactEmailAddress
        case replicationMode
        case compareTo
        case minBadgeNumber
        case dealersDenPresent
        case dealersDenRegText
        case timeZone
        case membershipLevels
        case shirtSizes
        case mailTemplates
        case attendees
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(lastModified, forKey: .lastModified)
        try container.encode(active, forKey: .active)
        try container.encode(longName, forKey: .longName)
        try container.encode(shortName, forKey: .shortName)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(preRegStartDate, forKey: .preRegStartDate)
        try container.encode(preRegEndDate, forKey: .preRegEndDate)
        try container.encode(registrationOpen, forKey: .registrationOpen)
        try container.encode(headerExtras, forKey: .headerExtras)
        try container.encode(headerGraphic, forKey: .headerGraphic)
        try container.encode(styleSheet, forKey: .styleSheet)
        try container.encode(footerExtras, forKey: .footerExtras)
        try container.encode(badgeClass, forKey: .badgeClass)
        try container.encode(contactEmailAddress, forKey: .contactEmailAddress)
        try container.encode(replicationMode, forKey: .replicationMode)
        try container.encode(compareTo, forKey: .compareTo)
        try container.encode(minBadgeNumber, forKey: .minBadgeNumber)
        try container.encode(dealersDenPresent, forKey: .dealersDenPresent)
        try container.encode(dealersDenRegText, forKey: .dealersDenRegText)
        try container.encode(timeZone, forKey: .timeZone)
        try container.encode(membershipLevels, forKey: .membershipLevels)
        try container.encode(shirtSizes, forKey: .shirtSizes)
        try container.encode(mailTemplates, forKey: .mailTemplates)
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(ConventionIdentifier.self, forKey: .id)
        let lastModified = try container.decode(Date.self, forKey: .lastModified)
        let active = try container.decode(Bool.self, forKey: .active)
        let longName = try container.decode(String.self, forKey: .longName)
        let shortName = try container.decode(String.self, forKey: .shortName)
        let startDate = try container.decode(Date.self, forKey: .startDate)
        let endDate = try container.decode(Date.self, forKey: .endDate)
        let preRegStartDate = try container.decode(Date.self, forKey: .preRegStartDate)
        let preRegEndDate = try container.decode(Date.self, forKey: .preRegEndDate)
        let registrationOpen = try container.decode(Bool.self, forKey: .registrationOpen)
        let headerExtras = try container.decodeIfPresent(String.self, forKey: .headerExtras)
        let headerGraphic = try container.decodeIfPresent(String.self, forKey: .headerGraphic)
        let styleSheet = try container.decodeIfPresent(String.self, forKey: .styleSheet)
        let footerExtras = try container.decodeIfPresent(String.self, forKey: .footerExtras)
        let badgeClass = try container.decodeIfPresent(String.self, forKey: .badgeClass)
        let contactEmailAddress = try container.decodeIfPresent(
            String.self, forKey: .contactEmailAddress)
        let replicationMode = try container.decodeIfPresent(String.self, forKey: .replicationMode)
        let compareTo = try container.decodeIfPresent(ConventionIdentifier.self, forKey: .compareTo)
        let minBadgeNumber = try container.decode(UInt32.self, forKey: .minBadgeNumber)
        let dealersDenPresent = try container.decode(Bool.self, forKey: .dealersDenPresent)
        let dealersDenRegText = try container.decodeIfPresent(
            String.self, forKey: .dealersDenRegText)
        let timeZone =
            try container.decodeIfPresent(String.self, forKey: .timeZone) ?? "America/Chicago"
        let membershipLevels = try container.decode(
            [MembershipLevel].self, forKey: .membershipLevels)
        let shirtSizes = try container.decode([ShirtSize].self, forKey: .shirtSizes)
        let mailTemplates = try container.decode([String: String].self, forKey: .mailTemplates)

        self.init(
            id: id,
            lastModified: lastModified,
            active: active,
            longName: longName,
            shortName: shortName,
            startDate: startDate,
            endDate: endDate,
            preRegStartDate: preRegStartDate,
            preRegEndDate: preRegEndDate,
            registrationOpen: registrationOpen,
            headerExtras: headerExtras,
            headerGraphic: headerGraphic,
            styleSheet: styleSheet,
            footerExtras: footerExtras,
            badgeClass: badgeClass,
            contactEmailAddress: contactEmailAddress,
            replicationMode: replicationMode,
            compareTo: compareTo,
            minBadgeNumber: minBadgeNumber,
            dealersDenPresent: dealersDenPresent,
            dealersDenRegText: dealersDenRegText,
            timeZone: timeZone,
            membershipLevels: membershipLevels,
            shirtSizes: shirtSizes,
            mailTemplates: mailTemplates
        )
        self.attendees = attendees
    }
}


// MARK: - Mock
extension Convention {
    static func mock() -> Convention {
        return Convention(
            id: ConventionIdentifier(),
            lastModified: Date(),
            active: true,
            longName: "Mock Convention",
            shortName: "MockCon",
            startDate: Date().addingTimeInterval(60 * 60 * 24 * 30),  // 30 days from now
            endDate: Date().addingTimeInterval(60 * 60 * 24 * 33),  // 3 days duration
            preRegStartDate: Date().addingTimeInterval(-60 * 60 * 24 * 60),  // 60 days ago
            preRegEndDate: Date().addingTimeInterval(-60 * 60 * 24 * 10),  // 10 days ago
            registrationOpen: true,
            headerExtras: "Welcome to MockCon!",
            headerGraphic: "mock-header.png",
            styleSheet: "mock-style.css",
            footerExtras: "Thanks for joining us!",
            badgeClass: "standard",
            contactEmailAddress: "contact@mockcon.com",
            replicationMode: "primary",
            compareTo: nil,
            minBadgeNumber: 1000,
            dealersDenPresent: false,
            dealersDenRegText: nil,
            timeZone: "America/Chicago",
            membershipLevels: [
                MembershipLevel.mock(), MembershipLevel.mock(), MembershipLevel.mock(),
                MembershipLevel.mock(),
            ],
            shirtSizes: [ShirtSize.mock()],
            mailTemplates: ["welcome": "Welcome to MockCon!"]
        )
    }
}
