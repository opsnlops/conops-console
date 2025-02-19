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
    var contactEmailAddress: String
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
        footerExtras: String? = nil,
        contactEmailAddress: String,
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
            id: UUID(uuidString: self.id.uuidString.lowercased())!,
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
        case footerExtras
        case contactEmailAddress
        case slackWebHook
        case postmarkServerToken
        case twilioAccountSID
        case twilioAuthToken
        case twilioOutgoingNumber
        case compareTo
        case minBadgeNumber
        case dealersDenPresent
        case dealersDenRegText
        case paypalAPIUserName
        case paypalAPIPassword
        case paypalAPISignature
        case membershipLevels
        case shirtSizes
        case mailTemplates
        case attendees
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Convert the UUID to a lower-case string.
        try container.encode(id.uuidString.lowercased(), forKey: .id)
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
        try container.encode(footerExtras, forKey: .footerExtras)
        try container.encode(contactEmailAddress, forKey: .contactEmailAddress)
        try container.encode(slackWebHook, forKey: .slackWebHook)
        try container.encode(postmarkServerToken, forKey: .postmarkServerToken)
        try container.encode(twilioAccountSID, forKey: .twilioAccountSID)
        try container.encode(twilioAuthToken, forKey: .twilioAuthToken)
        try container.encode(twilioOutgoingNumber, forKey: .twilioOutgoingNumber)
        try container.encode(compareTo, forKey: .compareTo)
        try container.encode(minBadgeNumber, forKey: .minBadgeNumber)
        try container.encode(dealersDenPresent, forKey: .dealersDenPresent)
        try container.encode(dealersDenRegText, forKey: .dealersDenRegText)
        try container.encode(paypalAPIUserName, forKey: .paypalAPIUserName)
        try container.encode(paypalAPIPassword, forKey: .paypalAPIPassword)
        try container.encode(paypalAPISignature, forKey: .paypalAPISignature)
        try container.encode(membershipLevels, forKey: .membershipLevels)
        try container.encode(shirtSizes, forKey: .shirtSizes)
        try container.encode(mailTemplates, forKey: .mailTemplates)
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode the lower-case id string and convert it to a UUID.
        let idString = try container.decode(String.self, forKey: .id)
        guard let uuid = UUID(uuidString: idString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .id,
                in: container,
                debugDescription: "Invalid UUID string")
        }
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
        let footerExtras = try container.decodeIfPresent(String.self, forKey: .footerExtras)
        let contactEmailAddress = try container.decode(String.self, forKey: .contactEmailAddress)
        let slackWebHook = try container.decodeIfPresent(String.self, forKey: .slackWebHook)
        let postmarkServerToken = try container.decodeIfPresent(
            String.self, forKey: .postmarkServerToken)
        let twilioAccountSID = try container.decodeIfPresent(String.self, forKey: .twilioAccountSID)
        let twilioAuthToken = try container.decodeIfPresent(String.self, forKey: .twilioAuthToken)
        let twilioOutgoingNumber = try container.decodeIfPresent(
            String.self, forKey: .twilioOutgoingNumber)
        let compareTo = try container.decodeIfPresent(UUID.self, forKey: .compareTo)
        let minBadgeNumber = try container.decode(UInt32.self, forKey: .minBadgeNumber)
        let dealersDenPresent = try container.decode(Bool.self, forKey: .dealersDenPresent)
        let dealersDenRegText = try container.decodeIfPresent(
            String.self, forKey: .dealersDenRegText)
        let paypalAPIUserName = try container.decodeIfPresent(
            String.self, forKey: .paypalAPIUserName)
        let paypalAPIPassword = try container.decodeIfPresent(
            String.self, forKey: .paypalAPIPassword)
        let paypalAPISignature = try container.decodeIfPresent(
            String.self, forKey: .paypalAPISignature)
        let membershipLevels = try container.decode(
            [MembershipLevel].self, forKey: .membershipLevels)
        let shirtSizes = try container.decode([ShirtSize].self, forKey: .shirtSizes)
        let mailTemplates = try container.decode([String: String].self, forKey: .mailTemplates)

        self.init(
            id: uuid,
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
            footerExtras: footerExtras,
            contactEmailAddress: contactEmailAddress,
            slackWebHook: slackWebHook,
            postmarkServerToken: postmarkServerToken,
            twilioAccountSID: twilioAccountSID,
            twilioAuthToken: twilioAuthToken,
            twilioOutgoingNumber: twilioOutgoingNumber,
            compareTo: compareTo,
            minBadgeNumber: minBadgeNumber,
            dealersDenPresent: dealersDenPresent,
            dealersDenRegText: dealersDenRegText,
            paypalAPIUserName: paypalAPIUserName,
            paypalAPIPassword: paypalAPIPassword,
            paypalAPISignature: paypalAPISignature,
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
            membershipLevels: [
                MembershipLevel.mock(), MembershipLevel.mock(), MembershipLevel.mock(),
                MembershipLevel.mock(),
            ],
            shirtSizes: [ShirtSize.mock()],
            mailTemplates: ["welcome": "Welcome to MockCon!"]
        )
    }
}
