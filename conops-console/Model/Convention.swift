//
//  Convention.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
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
    var footerExtras: String?
    var contactEmailAddress: String?
    var slackWebHook: String?
    var postmarkServerToken: String?
    var twilioAccountSID: String?
    var twilioAuthToken: String?
    var twilioOutgoingNumber: String?
    var compareTo: UUID?
    var minBadgeNumber: UInt32
    var dealersDenPresent: Bool
    var dealersDenRegText: String?
    var paypalAPIUserName: String?
    var paypalAPIPassword: String?
    var paypalAPISignature: String?

    // For membershipLevels, shirtSizes, and mailTemplates,
    // SwiftData might require special handling.
    // For now, let's just keep them as direct properties
    var membershipLevels: [MembershipLevel]
    var shirtSizes: [ShirtSize]
    var mailTemplates: [String: String]

    // One to many, hopefully every covention has lots of these!
    @Relationship(deleteRule: .cascade, inverse: \Attendee.convention)
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
        footerExtras: String? = nil,
        contactEmailAddress: String? = nil,
        slackWebHook: String? = nil,
        postmarkServerToken: String? = nil,
        twilioAccountSID: String? = nil,
        twilioAuthToken: String? = nil,
        twilioOutgoingNumber: String? = nil,
        compareTo: UUID? = nil,
        minBadgeNumber: UInt32,
        dealersDenPresent: Bool,
        dealersDenRegText: String? = nil,
        paypalAPIUserName: String? = nil,
        paypalAPIPassword: String? = nil,
        paypalAPISignature: String? = nil,
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
        self.footerExtras = footerExtras
        self.contactEmailAddress = contactEmailAddress
        self.slackWebHook = slackWebHook
        self.postmarkServerToken = postmarkServerToken
        self.twilioAccountSID = twilioAccountSID
        self.twilioAuthToken = twilioAuthToken
        self.twilioOutgoingNumber = twilioOutgoingNumber
        self.compareTo = compareTo
        self.minBadgeNumber = minBadgeNumber
        self.dealersDenPresent = dealersDenPresent
        self.dealersDenRegText = dealersDenRegText
        self.paypalAPIUserName = paypalAPIUserName
        self.paypalAPIPassword = paypalAPIPassword
        self.paypalAPISignature = paypalAPISignature
        self.membershipLevels = membershipLevels
        self.shirtSizes = shirtSizes
        self.mailTemplates = mailTemplates
    }
}


// MARK: - DTO conversions
extension Convention {

    static func fromDTO(_ dto: ConventionDTO) -> Convention {
        return Convention(
            id: dto.id,
            lastModified: dto.lastModified,
            active: dto.active,
            longName: dto.longName,
            shortName: dto.shortName,
            startDate: dto.startDate,
            endDate: dto.endDate,
            preRegStartDate: dto.preRegStartDate,
            preRegEndDate: dto.preRegEndDate,
            registrationOpen: dto.registrationOpen,
            headerExtras: dto.headerExtras,
            footerExtras: dto.footerExtras,
            contactEmailAddress: dto.contactEmailAddress,
            slackWebHook: dto.slackWebHook,
            postmarkServerToken: dto.postmarkServerToken,
            twilioAccountSID: dto.twilioAccountSID,
            twilioAuthToken: dto.twilioAuthToken,
            twilioOutgoingNumber: dto.twilioOutgoingNumber,
            compareTo: dto.compareTo,
            minBadgeNumber: dto.minBadgeNumber,
            dealersDenPresent: dto.dealersDenPresent,
            dealersDenRegText: dto.dealersDenRegText,
            paypalAPIUserName: dto.paypalAPIUserName,
            paypalAPIPassword: dto.paypalAPIPassword,
            paypalAPISignature: dto.paypalAPISignature,
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
            startDate: self.startDate,
            endDate: self.endDate,
            preRegStartDate: self.preRegStartDate,
            preRegEndDate: self.preRegEndDate,
            registrationOpen: self.registrationOpen,
            headerExtras: self.headerExtras,
            footerExtras: self.footerExtras,
            contactEmailAddress: self.contactEmailAddress,
            slackWebHook: self.slackWebHook,
            postmarkServerToken: self.postmarkServerToken,
            twilioAccountSID: self.twilioAccountSID,
            twilioAuthToken: self.twilioAuthToken,
            twilioOutgoingNumber: self.twilioOutgoingNumber,
            compareTo: self.compareTo,
            minBadgeNumber: self.minBadgeNumber,
            dealersDenPresent: self.dealersDenPresent,
            dealersDenRegText: self.dealersDenRegText,
            paypalAPIUserName: self.paypalAPIUserName,
            paypalAPIPassword: self.paypalAPIPassword,
            paypalAPISignature: self.paypalAPISignature,
            membershipLevels: self.membershipLevels,
            shirtSizes: self.shirtSizes,
            mailTemplates: self.mailTemplates
        )
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
                    id: UUID(),
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
                    footerExtras: Optional<String>.none,
                    contactEmailAddress: "bunny\(i)@example.com",
                    slackWebHook: Optional<String>.none,
                    postmarkServerToken: Optional<String>.none,
                    twilioAccountSID: Optional<String>.none,
                    twilioAuthToken: Optional<String>.none,
                    twilioOutgoingNumber: Optional<String>.none,
                    compareTo: Optional<UUID>.none,
                    minBadgeNumber: UInt32(i),
                    dealersDenPresent: false,
                    dealersDenRegText: Optional<String>.none,
                    paypalAPIUserName: Optional<String>.none,
                    paypalAPIPassword: Optional<String>.none,
                    paypalAPISignature: Optional<String>.none,
                    membershipLevels: [],
                    shirtSizes: [],
                    mailTemplates: [:]
                )
            )
        }

        return container
    }
}


// MARK: - Mock
extension Convention {
    static func mock() -> Convention {
        return Convention(
            id: UUID(),
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
            footerExtras: "Thanks for joining us!",
            contactEmailAddress: "contact@mockcon.com",
            slackWebHook: nil,
            postmarkServerToken: nil,
            twilioAccountSID: nil,
            twilioAuthToken: nil,
            twilioOutgoingNumber: nil,
            compareTo: nil,
            minBadgeNumber: 1000,
            dealersDenPresent: false,
            dealersDenRegText: nil,
            paypalAPIUserName: nil,
            paypalAPIPassword: nil,
            paypalAPISignature: nil,
            membershipLevels: [MembershipLevel.mock()],
            shirtSizes: [ShirtSize.mock()],
            mailTemplates: ["welcome": "Welcome to MockCon!"]
        )
    }
}
