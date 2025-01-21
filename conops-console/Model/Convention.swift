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
class Convention {
    // SwiftData typically wants `var` so it can mutate these properties
    var id: UUID
    var lastModified: Date
    var active: Bool
    var longName: String
    var shortName: String
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
    // (You might convert them to separate @Model references or transformable data).
    var membershipLevels: [MembershipLevel]
    var shirtSizes: [ShirtSize]
    var mailTemplates: [String: String]

    // MARK: - Simple init
    init(
        id: UUID,
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
